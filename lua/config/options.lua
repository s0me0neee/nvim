-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.g.mapleader = " "
vim.g.copilot_enabled = true
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "nim",
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
		end, { buffer = true, desc = "Show Rust runnables with args" })
		vim.keymap.set("n", "<leader>ck", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, { buffer = true, desc = "Show Rust documentation" })
		vim.keymap.set("n", "<leader>cx", function()
			vim.cmd.RustLsp("expandMacro")
		end, { buffer = true, desc = "Expand macro" })
	end,
})

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })

vim.lsp.config("harper_ls", {
	filetypes = { "markdown", "text" },
})

vim.g.lazyvim_python_lsp = "pyright"

vim.keymap.set("n", "<leader>h", function() Snacks.dashboard.open() end)
vim.keymap.set("n", "<leader>t", function() vim.cmd("Themery") end)

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ timeout = 500, higroup = "IncSearch" })
	end,
})
