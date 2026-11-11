-- LazyVim's <esc> plus closing noice's hover/signature popup, which only auto-closes on cursor move
vim.keymap.set("n", "<esc>", function()
	vim.cmd("noh")
	LazyVim.cmp.actions.snippet_stop()
	local docs = package.loaded["noice.lsp.docs"]
	if docs then
		for _, message in pairs(docs._messages) do
			if message:win() then
				docs.hide(message)
			end
		end
	end
	return "<esc>"
end, { expr = true, desc = "Escape, clear hlsearch, close hover" })
