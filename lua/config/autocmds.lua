-- Auto-loaded by LazyVim (lazyvim.config.init).

require("config.term-jump").setup()

-- true when every signature in the strings has an empty "()" right after `label`
local function takes_no_params(label, texts)
	local found = false
	for _, s in ipairs(texts) do
		if type(s) == "string" then
			local init = 1
			while true do
				local b, e = s:find(label, init, true)
				if not b then
					break
				end
				init = e + 1
				-- "strip" inside "rstrip()" isn't this function
				if b == 1 or not s:sub(b - 1, b - 1):match("[%w_$]") then
					local after = s:sub(e + 1):gsub("^%b<>", ""):gsub("^%b[]", "")
					if after:match("^%(%)") then
						found = true
					elseif after:match("^%(") then
						return false
					end
				end
			end
			-- ty describes some callables without their name: "(..) -> R", "Overload[() -> A, () -> B]"
			if not s:find(label, 1, true) then
				for args in s:gmatch("(%b())%s*%->") do
					if args ~= "()" then
						return false
					end
					found = true
				end
			end
		end
	end
	return found
end

-- blink's auto-brackets leave the cursor inside "()" even when the function takes no params
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("blink_skip_empty_parens", { clear = true }),
	pattern = "BlinkCmpAccept",
	callback = function(ev)
		local item = ev.data.item
		if not item or (item.kind ~= 2 and item.kind ~= 3 and item.kind ~= 4) then
			return
		end
		-- event data is a stripped copy; the menu still holds the original with its resolved signature
		local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
		for _, it in ipairs(ok and menu.items or {}) do
			if
				it.label == item.label
				and it.kind == item.kind
				and it.client_id == item.client_id
				and it.sortText == item.sortText
			then
				item = it
				break
			end
		end
		local texts = {
			-- tsc only has the signature after resolve, which colorful-menu-ext did for on-screen rows
			require("colorful-menu-ext.resolve").detail(item) or item.detail,
			vim.tbl_get(item, "labelDetails", "description"),
			vim.tbl_get(item, "labelDetails", "detail"),
		}
		if not takes_no_params(item.label, texts) then
			return
		end
		local col = vim.api.nvim_win_get_cursor(0)[2]
		if vim.api.nvim_get_current_line():sub(col - 1, col) ~= "()" then
			return
		end
		-- blink steps into the parens with queued <C-g>U<Left> keys; queue a <Right> after them
		local right = vim.api.nvim_replace_termcodes("<C-g>U<Right>", true, true, true)
		vim.api.nvim_feedkeys(right, "n", false)
	end,
})

-- Force-kill every LSP client on exit. Neovim's graceful shutdown gives servers
-- only a short window; a busy rust-analyzer (mid-index) misses it and the
-- process orphans (survives `:q`).
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("lsp_force_exit", { clear = true }),
	callback = function()
		for _, client in ipairs(vim.lsp.get_clients()) do
			client:stop(true)
		end
	end,
})
