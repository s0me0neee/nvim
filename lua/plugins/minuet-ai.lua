-- Cached: the prompt hook runs on every request, and debounce is 25ms.
local dir_cache = {}

local function dir_listing(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		return ""
	end
	local dir = vim.fs.dirname(file)
	local hit = dir_cache[dir]
	if hit and vim.uv.now() - hit.at < 30000 then
		return hit.text
	end

	local names = {}
	for name, type_ in vim.fs.dir(dir) do
		if not name:match("^%.") then
			names[#names + 1] = type_ == "directory" and name .. "/" or name
		end
		if #names >= 40 then
			break
		end
	end
	table.sort(names)

	local text = #names > 0 and "sibling files: " .. table.concat(names, ", ") or ""
	dir_cache[dir] = { at = vim.uv.now(), text = text }
	return text
end

-- Declaration signatures from nvim-treesitter-textobjects' queries, so there is
-- no hand-maintained node-type list to keep in sync per language.
local outline_cache = {}

-- @function.outer also captures inline callbacks. A real declaration binds a
-- name on itself or a same-row wrapper (`const x = useCallback(() => {})`), or
-- sits at the file's top level. Climbing out of JSX is what would let
-- `onClick={() => ...}` borrow a name from its element, so stop there. Together
-- this keeps 71 declarations of App.tsx's 356 captures, with no noise lines.
local function decl_row(node)
	for _ = 1, 4 do
		local parent = node:parent()
		if node:field("name")[1] or (parent and parent:parent() == nil) then
			return node:start()
		end
		if not parent or parent:start() ~= node:start() or parent:type():find("jsx", 1, true) then
			return nil
		end
		node = parent
	end
end

local function declarations(bufnr, from, to)
	local items = {}

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return items
	end
	local ok_query, query = pcall(vim.treesitter.query.get, parser:lang(), "textobjects")
	if not ok_query or not query then
		return items
	end
	-- Incremental, so ~0.15ms once the highlighter has parsed this tick.
	local trees = parser:parse()
	if not trees or not trees[1] then
		return items
	end

	local seen = {}
	for id, node in query:iter_captures(trees[1]:root(), bufnr, from, to) do
		local capture = query.captures[id]
		if capture == "function.outer" or capture == "class.outer" then
			local srow = decl_row(node)
			if srow and not seen[srow] then
				seen[srow] = true
				local _, _, erow = node:range()
				local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
				local item = { srow = srow, erow = erow, text = vim.trim(line):sub(1, 100) }

				-- A type's signature line is useless on its own: DeepSeek invented
				-- `position`/`duration` from `interface PlaybackStateView {` and got
				-- every field right once the body was there. Short ones travel whole.
				if capture == "class.outer" and erow - srow <= 12 then
					item.body = vim.api.nvim_buf_get_lines(bufnr, srow, math.min(erow + 1, srow + 12), false)
					for i, l in ipairs(item.body) do
						item.body[i] = l:sub(1, 100)
					end
				end

				items[#items + 1] = item
			end
		end
	end

	return items
end

-- Querying the whole file costs 22ms on 2500 lines of TSX, which is too much per
-- keystroke, so the outline scan is windowed and reused for a couple of seconds.
-- The scope chain is queried separately at the cursor row: exact, and 0.25ms.
local function nearby_declarations(bufnr, row)
	local hit = outline_cache[bufnr]
	if hit and vim.uv.now() - hit.at < 2000 and math.abs(row - hit.row) < 200 then
		return hit.items
	end

	local items = declarations(bufnr, math.max(0, row - 400), row + 400)
	outline_cache[bufnr] = { at = vim.uv.now(), row = row, items = items }
	return items
end

-- Scope chain plus the signatures of declarations minuet is *not* already
-- sending verbatim, which is where an outline actually earns its tokens.
local function structure(bufnr, prefix, suffix, budget)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local first = row - select(2, prefix:gsub("\n", ""))
	local last = row + select(2, suffix:gsub("\n", ""))

	local scope = {}
	for _, it in ipairs(declarations(bufnr, row, row + 1)) do
		scope[#scope + 1] = it.text
	end

	local types, funcs = {}, {}
	for _, it in ipairs(nearby_declarations(bufnr, row)) do
		-- Skip what the cursor is in, and what minuet already sends verbatim.
		local encloses = it.srow <= row and row <= it.erow
		if not encloses and (it.srow < first or it.srow > last) then
			table.insert(it.body and types or funcs, it)
		end
	end

	-- Nearest first: on a long file the declarations by the cursor beat the ones
	-- at the top, which is all a document-order cut would ever reach.
	local function by_distance(a, b)
		return math.abs(a.srow - row) < math.abs(b.srow - row)
	end
	table.sort(types, by_distance)
	table.sort(funcs, by_distance)

	-- Types get first claim on the budget: their signature line alone is useless
	-- (DeepSeek invented field names from it) and the body is what made the
	-- completion correct, so pay for them before any function signature.
	local outline = {}
	for _, it in ipairs(types) do
		local cost = 0
		for _, l in ipairs(it.body) do
			cost = cost + #l
		end
		if cost > budget then
			break
		end
		outline[#outline + 1] = it
		budget = budget - cost
	end

	-- Boilerplate families (audit_step_1 .. audit_step_26) say nothing the first
	-- of them doesn't, and 26 of them ate the whole budget in testing, burying
	-- the one helper the completion actually needed.
	local shapes = {}
	for _, it in ipairs(funcs) do
		local shape = it.text:gsub("%d+", "#")
		if budget <= 0 then
			break
		elseif not shapes[shape] then
			shapes[shape] = true
			outline[#outline + 1] = it
			budget = budget - #it.text
		end
	end

	table.sort(outline, function(a, b)
		return a.srow < b.srow
	end)

	local lines = {}
	if #scope > 0 then
		lines[#lines + 1] = "cursor is inside: " .. table.concat(scope, " > ")
	end
	if #outline > 0 then
		lines[#lines + 1] = "nearby declarations in this file:"
		for _, it in ipairs(outline) do
			vim.list_extend(lines, it.body or { it.text })
		end
	end
	return lines
end

local function commented(lines)
	local cs = vim.bo.commentstring
	if cs == nil or cs == "" then
		cs = "# %s"
	end
	if not cs:find("%%s") then
		cs = cs .. " %s"
	end

	local out = {}
	for _, l in ipairs(lines) do
		if l ~= "" then
			out[#out + 1] = (cs:gsub("%%s", function()
				return l
			end))
		end
	end
	return table.concat(out, "\n")
end

-- Shared by both FIM providers: they take the same prompt/suffix pair, so the
-- header must not end up attached to only one of them.
local function fim_prompt(prefix, suffix, _)
	local mu = require("minuet.utils")
	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

	local header = { path ~= "" and "path: " .. path or "", dir_listing(bufnr) }
	-- Char budget for the outline; the rest of the header is a few lines.
	vim.list_extend(header, structure(bufnr, prefix, suffix, 600))

	return mu.add_language_comment() .. "\n" .. mu.add_tab_comment() .. "\n" .. commented(header) .. "\n" .. prefix
end

return {
	"milanglacier/minuet-ai.nvim",
	-- textobjects supplies the queries the prompt hook reads declarations from;
	-- it is lazy-loaded otherwise, and its queries resolve only once loaded.
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter-textobjects" },
	enabled = true,
	opts = {
		context_window = 2048,
		context_ratio = 0.7,
		-- Minuet fires one request per completion; there's no prev/next key to
		-- cycle them anyway.
		n_completions = 1,
		-- The default 1000ms throttle skips the request after you stop typing if
		-- one was sent less than a second earlier, leaving an old suggestion.
		throttle = 25,
		debounce = 25,
		add_single_line_entry = true,
		-- Switch between "codestral" and "openai_fim_compatible" (DeepSeek) to compare.
		provider = "openai_fim_compatible",
		provider_options = {
			codestral = {
				api_key = "MISTRAL_API_KEY",
				-- Free endpoint; https://api.mistral.ai/v1/fim/completions is ~0.1s faster but billed.
				end_point = "https://codestral.mistral.ai/v1/fim/completions",
				model = "codestral-latest",
				template = { prompt = fim_prompt },
				optional = { max_tokens = 64, top_p = 0.7 },
			},
			openai_fim_compatible = {
				api_key = "DEEPSEEK_API_KEY",
				name = "deepseek",
				-- FIM Completion (Beta): /beta/completions takes prompt+suffix,
				-- unlike the chat endpoint. Pinned so a plugin default change
				-- can't silently move it.
				end_point = "https://api.deepseek.com/beta/completions",
				model = "deepseek-flash",
				stream = false,
				template = {
					-- `suffix` stays at its default: dropping it would turn
					-- /beta/completions from FIM into plain continuation.
					prompt = fim_prompt,
				},
				-- A cap, not a stop sequence: `stop = {"\n\n"}` bounds the tail too but
				-- clips legitimate multi-line completions, and Codestral runs away
				-- without either (p50 4346ms, worst 5907ms, 3 of 5 runs hitting 512
				-- tokens). At 128 the worst case measured 1311ms with no accuracy
				-- change; drop to 64 to halve the tail again if single lines suffice.
				optional = {
					max_tokens = 64,
					top_p = 0.7,
				},
			},
		},

		virtualtext = {
			auto_trigger_ft = { "*" },
			show_on_completion_menu = true,
			keymap = {
				accept = "<Tab>",
				accept_line = "<S-Tab>",
				accept_n_lines = nil,
				prev = nil,
				next = nil,
				dismiss = nil,
			},
		},
	},
	config = function(_, opts)
		require("minuet").setup(opts)

		-- Minuet shows a response even if you kept typing while it was in flight,
		-- which puts a suggestion meant for an earlier cursor position at the
		-- current one. Drop responses once the buffer or cursor has changed.
		local backend = require("minuet.backends." .. opts.provider)
		local complete = backend.complete
		backend.complete = function(context, callback)
			local buf = vim.api.nvim_get_current_buf()
			local tick = vim.api.nvim_buf_get_changedtick(buf)
			local cursor = vim.api.nvim_win_get_cursor(0)
			complete(context, function(data)
				if
					vim.api.nvim_get_current_buf() ~= buf
					or vim.api.nvim_buf_get_changedtick(buf) ~= tick
					or not vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor)
				then
					return
				end
				callback(data)
			end)
		end
	end,
}
