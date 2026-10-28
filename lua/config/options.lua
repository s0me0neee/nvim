-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.autochdir = true
vim.opt.smartindent = true
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.cursorline = false
vim.g.bigfile_disable = false
vim.opt.background = "dark"

vim.g.lazyvim_python_lsp = "ty"
vim.g.lazyvim_ts_lsp = "tsc"

--require("vim._core.ui2").enable({})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nim", "mermaid" },
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 0
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<leader>r", function()
			vim.cmd.RustLsp({ "runnables", bang = false })
		end, { buffer = true, desc = " Rust runnables" })
		vim.keymap.set("n", "<leader>ck", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, { buffer = true, desc = " Rust hover actions" })
		vim.keymap.set("n", "<leader>cx", function()
			vim.cmd.RustLsp("expandMacro")
		end, { buffer = true, desc = " Expand macro" })
	end,
})

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = " Projects" })

vim.lsp.config("harper_ls", {
	filetypes = { "markdown" },
	-- harper errors on every configuration request without a settings object
	settings = { ["harper-ls"] = {} },
})

vim.keymap.set("n", "<leader>h", function()
	Snacks.dashboard.open()
end, { desc = "Dashboard" })
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("Themery")
end, { desc = " Themes" })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ timeout = 500, higroup = "IncSearch" })
	end,
})

vim.keymap.set("n", "<leader>E", function()
	vim.cmd("Neotree")
end, { desc = "File exp" })

vim.keymap.set("n", "<leader>cG", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })

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

vim.keymap.set("n", "<leader>uU", function()
	-- Enable transparency - set backgrounds to none
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })
	vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
	vim.g.transparent_enabled = true
	vim.notify("Transparency enabled", vim.log.levels.INFO)
end, { desc = "Enable theme transparency" })
