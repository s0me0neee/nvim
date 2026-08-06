-- lua/keymap_dump.lua
-- :KeymapDump [path]   -> markdown dump of every keymap, grouped by owner.
-- Includes lazy.nvim `keys = {}` specs for plugins that aren't loaded yet.

local M = {}

local MODES = { "n", "x", "s", "o", "i", "c", "t" }

local lazy_root = (function()
	local ok, cfg = pcall(require, "lazy.core.config")
	return ok and cfg.options.root or nil
end)()

local cfg_dir = vim.fn.stdpath("config")

---Resolve the script id of a mapping to a plugin name.
local function owner_of(sid)
	if not sid or sid <= 0 then
		return "unknown (vimscript / :map)"
	end
	local info = vim.fn.getscriptinfo({ sid = sid })
	local name = info and info[1] and info[1].name
	if not name then
		return "unknown"
	end
	if lazy_root then
		local plug = name:match(vim.pesc(lazy_root) .. "/([^/]+)")
		if plug then
			return plug
		end
	end
	if name:find(cfg_dir, 1, true) then
		return "user config"
	end
	if vim.env.VIMRUNTIME and name:find(vim.env.VIMRUNTIME, 1, true) then
		return "$VIMRUNTIME"
	end
	return name
end

---Mappings that actually exist right now (global + current buffer).
local function collect_active()
	local out = {}
	for _, mode in ipairs(MODES) do
		local maps = vim.api.nvim_get_keymap(mode)
		vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, mode))
		for _, m in ipairs(maps) do
			out[#out + 1] = {
				owner = owner_of(m.sid),
				mode = mode,
				lhs = m.lhs,
				desc = m.desc or m.rhs or (m.callback and "<lua callback>") or "",
				tag = m.buffer == 1 and "[buf] " or "",
			}
		end
	end
	return out
end

---Mappings lazy.nvim has registered as lazy-load triggers but not yet realised.
local function collect_pending()
	local out = {}
	local ok, Config = pcall(require, "lazy.core.config")
	if not ok then
		return out
	end
	for name, plugin in pairs(Config.plugins) do
		if not (plugin._ and plugin._.loaded) then
			local keys = plugin._ and plugin._.handlers and plugin._.handlers.keys or {}
			for _, k in pairs(keys) do
				local modes = type(k.mode) == "table" and k.mode or { k.mode or "n" }
				for _, mode in ipairs(modes) do
					out[#out + 1] = {
						owner = name,
						mode = mode,
						lhs = k.lhs,
						desc = k.desc or (type(k[2]) == "string" and k[2]) or "",
						tag = "[lazy] ",
					}
				end
			end
		end
	end
	return out
end

function M.dump(path)
	path = path ~= "" and path or nil
	path = path or (vim.fn.stdpath("state") .. "/keymaps.md")
	path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")

	local all = collect_active()
	vim.list_extend(all, collect_pending())

	local groups = {}
	for _, e in ipairs(all) do
		groups[e.owner] = groups[e.owner] or {}
		table.insert(groups[e.owner], e)
	end

	local names = vim.tbl_keys(groups)
	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)

	local lines = {
		"# Keymaps",
		"",
		("Generated %s — %d mappings across %d owners."):format(os.date("%Y-%m-%d %H:%M"), #all, #names),
		"",
	}

	for _, name in ipairs(names) do
		local entries = groups[name]
		table.sort(entries, function(a, b)
			if a.lhs == b.lhs then
				return a.mode < b.mode
			end
			return a.lhs < b.lhs
		end)

		local w = 0
		for _, e in ipairs(entries) do
			w = math.max(w, #e.lhs)
		end

		vim.list_extend(lines, { ("## %s  (%d)"):format(name, #entries), "", "```" })
		for _, e in ipairs(entries) do
			local desc = tostring(e.desc):gsub("%s+", " ")
			lines[#lines + 1] = ("%-2s  %-" .. w .. "s  %s%s"):format(e.mode, e.lhs, e.tag, desc)
		end
		vim.list_extend(lines, { "```", "" })
	end

	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(lines, path)
	vim.notify(("keymaps → %s (%d)"):format(path, #all))
	return path
end

vim.api.nvim_create_user_command("KeymapDump", function(o)
	M.dump(o.args)
end, { nargs = "?", complete = "file", desc = "Dump all keymaps to a markdown file" })

return M
