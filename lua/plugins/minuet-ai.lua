local OPENERS = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local CLOSERS = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

-- Applies `text` to `stack` (array of currently-open bracket chars, outermost
-- first), respecting basic string literals. Mutates and returns `stack`.
local function bracket_walk(text, stack)
	local in_string, escaped = nil, false
	for i = 1, #text do
		local c = text:sub(i, i)
		if in_string then
			if escaped then
				escaped = false
			elseif c == "\\" then
				escaped = true
			elseif c == in_string then
				in_string = nil
			end
		elseif c == '"' or c == "'" or c == "`" then
			in_string = c
		elseif OPENERS[c] then
			table.insert(stack, c)
		elseif CLOSERS[c] and stack[#stack] == CLOSERS[c] then
			table.remove(stack)
		end
	end
	return stack
end

local function copy_stack(t)
	local r = {}
	for i, v in ipairs(t) do
		r[i] = v
	end
	return r
end

-- Longest prefix of `a` that matches a suffix of `b`.
local function longest_overlap(a, b)
	for len = math.min(#a, #b), 1, -1 do
		if a:sub(1, len) == b:sub(-len) then
			return len
		end
	end
	return 0
end

-- Closes brackets a completion left open, but only if the suffix (the rest of
-- the buffer past the cursor) won't close them itself -- and trims any
-- trailing bracket/paren the completion already wrote that just duplicates
-- what the suffix supplies right after. Both prefix and suffix are needed to
-- do this correctly, which is why this wraps the backend's complete()
-- instead of using minuet's context-blind get_text_fn hook.
local function smart_close(prefix, completion, suffix)
	local base_stack = bracket_walk(prefix, {})
	local base = #base_stack

	-- Trim a trailing duplicate of the suffix from the model's own text FIRST,
	-- before anything is appended -- otherwise a later append can get mistaken
	-- for a duplicate of the suffix and get trimmed right back off. Allow a
	-- little trailing slack (e.g. a stray ";" the model appended after an
	-- already-redundant closer, as in "0);" when the suffix is just ")") so
	-- the duplicate is still found even when it isn't the literal last char.
	local best_removed = 0
	for k = 0, math.min(#completion, 3) do
		local candidate = completion:sub(1, #completion - k)
		local overlap = longest_overlap(suffix, candidate)
		if overlap > 0 and (k + overlap) > best_removed then
			best_removed = k + overlap
		end
	end
	if best_removed > 0 then
		completion = completion:sub(1, #completion - best_removed)
	end

	local after_stack = bracket_walk(completion, copy_stack(base_stack))

	if #after_stack > base then
		local sim = copy_stack(after_stack)
		local suffix_closes_it = false
		local in_string, escaped = nil, false
		for i = 1, #suffix do
			local c = suffix:sub(i, i)
			if in_string then
				if escaped then
					escaped = false
				elseif c == "\\" then
					escaped = true
				elseif c == in_string then
					in_string = nil
				end
			elseif c == '"' or c == "'" or c == "`" then
				in_string = c
			elseif OPENERS[c] then
				table.insert(sim, c)
			elseif CLOSERS[c] and sim[#sim] == CLOSERS[c] then
				table.remove(sim)
			end
			if #sim <= base then
				suffix_closes_it = true
				break
			end
		end

		if not suffix_closes_it then
			local missing = {}
			for i = #after_stack, base + 1, -1 do
				table.insert(missing, OPENERS[after_stack[i]])
			end
			completion = completion .. table.concat(missing)
		end
	end

	return completion
end

-- Pings the FIM endpoint's /v1/models and reports whether the server is up
-- and the configured model is actually loaded there, via vim.notify.
local function notify_minuet_connection()
	local opts = require("minuet").config.provider_options.openai_fim_compatible
	local base_url = opts.end_point:gsub("/v1/.*$", "")
	local model = opts.model

	vim.system({ "curl", "-s", "-m", "3", base_url .. "/v1/models" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 or not result.stdout or result.stdout == "" then
				vim.notify(
					("Minuet AI: could not reach %s at %s"):format(opts.name, base_url),
					vim.log.levels.WARN,
					{ title = "Minuet AI" }
				)
				return
			end

			local ok, decoded = pcall(vim.json.decode, result.stdout)
			local has_model = ok and vim.iter(decoded.data or {}):any(function(m)
				return m.id == model
			end)

			if has_model then
				vim.notify(
					("Minuet AI connected — %s (%s)"):format(opts.name, model),
					vim.log.levels.INFO,
					{ title = "Minuet AI" }
				)
			elseif ok then
				vim.notify(
					("Minuet AI: %s is running but model '%s' is not available"):format(opts.name, model),
					vim.log.levels.WARN,
					{ title = "Minuet AI" }
				)
			else
				vim.notify(
					("Minuet AI: unexpected response from %s"):format(base_url),
					vim.log.levels.WARN,
					{ title = "Minuet AI" }
				)
			end
		end)
	end)
end

return {
	"milanglacier/minuet-ai.nvim",
	enabled = false,
	config = function()
		require("minuet").setup({
			-- small context window: good starting point for local model compute (raise if it's fast enough)
			context_window = 512,
			-- request a single completion candidate instead of the default 3
			n_completions = 1,
			-- wait less after the last keystroke before firing a request (default 400)
			debounce = 50,
			provider = "openai_fim_compatible",
			provider_options = {
				openai_fim_compatible = {
					-- Ollama doesn't require auth; TERM is just a placeholder env var that's always set
					api_key = "TERM",
					name = "Ollama",
					end_point = "http://localhost:11434/v1/completions",
					model = "qwen2.5-coder:1.5b-base",
					stream = false,
					optional = {
						max_tokens = 40,
						top_p = 0.9,
						-- stop at the first newline: request a single line/statement
						-- instead of a whole block or function body
						stop = { "\n" },
					},
				},
			},
			virtualtext = {
				auto_trigger_ft = { "*" },
				-- keep showing ghost text even while blink.cmp's LSP popup is
				-- open; otherwise the popup (which shows on every keyword
				-- keystroke, see blink.lua) suppresses the ghost text for
				-- basically the entire time you're typing a word
				show_on_completion_menu = true,
				keymap = {},
			},
		})

		-- Wrap the backend so smart_close sees the real prefix/suffix around the
		-- cursor, not just the isolated completion text.
		local backend = require("minuet.backends.openai_fim_compatible")
		local orig_complete = backend.complete
		backend.complete = function(context, callback)
			orig_complete(context, function(items)
				items = vim.tbl_map(function(text)
					return smart_close(context.lines_before, text, context.lines_after)
				end, items or {})
				callback(items)
			end)
		end

		-- Confirm the local Ollama server (and configured model) is reachable
		-- once startup settles, rather than silently failing on first completion.
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = notify_minuet_connection,
		})

		-- Tab accepts a visible suggestion; otherwise falls back to a normal tab.
		vim.keymap.set("i", "<Tab>", function()
			local virtualtext = require("minuet.virtualtext")
			if virtualtext.action.is_visible() then
				virtualtext.action.accept()
				return ""
			end
			return "<Tab>"
		end, { expr = true, silent = true })
	end,
}
