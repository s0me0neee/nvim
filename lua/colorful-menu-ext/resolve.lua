-- tsc only sends a signature on completionItem/resolve, so resolve the on-screen blink items and redraw
local M = {}

local SERVERS = { tsc = true, tsgo = true }

-- weak keys: blink keeps the same item tables while filtering one response
local resolved = setmetatable({}, { __mode = "k" })
local pending = setmetatable({}, { __mode = "k" })

-- blink adds its own fields to items, which some servers refuse to decode
local LSP_FIELDS = {
	"label",
	"labelDetails",
	"kind",
	"tags",
	"detail",
	"documentation",
	"deprecated",
	"preselect",
	"sortText",
	"filterText",
	"insertText",
	"insertTextFormat",
	"insertTextMode",
	"textEdit",
	"textEditText",
	"additionalTextEdits",
	"commitCharacters",
	"command",
	"data",
}

local function lsp_item(item)
	local out = {}
	for _, field in ipairs(LSP_FIELDS) do
		out[field] = item[field]
	end
	return out
end

local function blink_menu()
	local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
	if ok and menu.win and menu.win:is_open() and menu.renderer and menu.context then
		return menu
	end
end

---@return string?
function M.detail(item)
	return resolved[item] or nil
end

local redraw_queued = false
local function redraw()
	if redraw_queued then
		return
	end
	redraw_queued = true
	vim.schedule(function()
		redraw_queued = false
		local menu = blink_menu()
		if not menu then
			return
		end
		local win = menu.win:get_win()
		local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
		pcall(function()
			menu.renderer:draw(menu.context, menu.win:get_buf(), menu.items)
			menu.update_position()
		end)
		vim.api.nvim_win_call(win, function()
			vim.fn.winrestview(view)
		end)
	end)
end

-- Function, Method, Constructor; auto-imports resolve to just 'Add import from "x"'
local KINDS = { [2] = true, [3] = true, [4] = true }

local function resolve(item)
	if resolved[item] ~= nil or pending[item] or type(item.client_id) ~= "number" then
		return
	end
	if not KINDS[item.kind] or vim.tbl_get(item, "labelDetails", "description") then
		resolved[item] = false
		return
	end
	local client = vim.lsp.get_client_by_id(item.client_id)
	if not client or not SERVERS[client.name] or client:is_stopped() then
		return
	end
	pending[item] = true
	local ok = client:request("completionItem/resolve", lsp_item(item), function(err, result)
		pending[item] = nil
		resolved[item] = (not err and result and type(result.detail) == "string") and result.detail or false
		if resolved[item] then
			redraw()
		end
	end)
	if not ok then
		pending[item] = nil
		resolved[item] = false
	end
end

local visible_queued = false
-- runs while blink draws, before the window is open or scrolled
function M.resolve_visible()
	if visible_queued then
		return
	end
	visible_queued = true
	vim.schedule(function()
		visible_queued = false
		local menu = blink_menu()
		if not menu then
			return
		end
		local win = menu.win:get_win()
		for i = vim.fn.line("w0", win), vim.fn.line("w$", win) do
			if menu.items[i] then
				resolve(menu.items[i])
			end
		end
	end)
end

local augroup = vim.api.nvim_create_augroup("colorful-menu-ext-resolve", { clear = true })
vim.api.nvim_create_autocmd("User", {
	group = augroup,
	pattern = { "BlinkCmpMenuOpen", "BlinkCmpListSelect" },
	callback = M.resolve_visible,
})
vim.api.nvim_create_autocmd("WinScrolled", {
	group = augroup,
	callback = function()
		local menu = blink_menu()
		if menu and vim.v.event[tostring(menu.win:get_win())] then
			M.resolve_visible()
		end
	end,
})

return M
