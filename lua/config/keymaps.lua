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

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = " Projects" })

vim.keymap.set("n", "<leader>h", function()
	Snacks.dashboard.open()
end, { desc = "Dashboard" })

vim.keymap.set("n", "<leader>t", "<cmd>Themery<cr>", { desc = " Themes" })

vim.keymap.set("n", "<leader>E", "<cmd>Neotree<cr>", { desc = "File exp" })

vim.keymap.set("n", "<leader>R", function()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local pat = [[\V\<]] .. vim.fn.escape(word, [[\/]]) .. [[\>]]
	local hits = vim.fn.matchbufline(buf, pat, 1, "$")
	local match = vim.fn.matchadd("Search", pat)
	local ns = vim.api.nvim_create_namespace("substitute_preview")
	local conceallevel = vim.wo[win].conceallevel
	-- bare one-line input over the statusline instead of noice's popup or the :s command
	local input = Snacks.input({
		prompt = "",
		icon = "",
		prompt_pos = "left",
		expand = false,
		win = {
			row = vim.o.lines - 1,
			col = 0,
			width = 0,
			border = "none",
			keys = { i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true } },
		},
	}, function(repl)
		pcall(vim.fn.matchdelete, match, win)
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.wo[win].conceallevel = conceallevel
		if repl then
			vim.cmd(("keeppatterns %%s/%s/%s/g"):format(pat, vim.fn.escape(repl, [[\/&~]])))
		end
	end)
	-- snacks pads the input with a statuscolumn even without a prompt
	vim.wo[input.win].statuscolumn = ""
	-- live preview: conceal each match and draw the typed text inline in its place
	input:on("TextChangedI", function()
		local text = input:text()
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.wo[win].conceallevel = text == "" and conceallevel or 2
		if text == "" then
			return
		end
		for _, hit in ipairs(hits) do
			vim.api.nvim_buf_set_extmark(buf, ns, hit.lnum - 1, hit.byteidx, {
				end_col = hit.byteidx + #hit.text,
				conceal = "",
				virt_text = { { text, "Search" } },
				virt_text_pos = "inline",
			})
		end
	end, { buf = true })
end, { desc = "Substitute word under cursor" })
