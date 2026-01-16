-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- vim.opt.winbar = "%=%m %f"

-- vim.opt.clipboard = ""
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = false -- Use actual tab characters, not spaces
vim.opt.tabstop = 4 -- Display width of tab characters
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indentation
vim.opt.softtabstop = 4 -- Number of spaces tab key inserts/deletes
vim.opt.swapfile = false
vim.opt.cursorline = false

---- Add semicolon at end of line and jump to end
vim.keymap.set({ "i", "n" }, "<C-;>", function()
	if vim.fn.mode() == "i" then
		return "<Esc>A;<Esc>"
	else
		return "A;<Esc>"
	end
end, { expr = true, desc = "Add semicolon at end of line" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "nim",
	callback = function()
		-- Use spaces instead of tabs and don't coalesce 4 spaces as one tab step
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 0
	end,
})

-- In Rust files, use Rust-specific documentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<leader>r", function()
			vim.cmd.RustLsp({ "runnables", bang = false })
		end, { buffer = true, desc = "Show Rust runnables with args" })
	end,
})

-- In Rust files, use Rust-specific documentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<leader>k", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, { buffer = true, desc = "Show Rust documentation" })
	end,
})
vim.keymap.set("n", "<leader>P", ":NeovimProjectHistory<CR>")

vim.keymap.set("n", "<leader>ml", ":MarksListBuf<CR>")
vim.keymap.set("n", "<leader>fv", ":VenvSelect<CR>")
vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })

vim.lsp.config("harper_ls", {
	filetypes = { "markdown", "text" },
})

-- vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_lsp = "pyright"

vim.keymap.set("n", "<leader>h", ":lua Snacks.dashboard.open()<CR>")
vim.keymap.set("n", "<leader>t", ":Themery<CR>")

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			timeout = 500, -- Duration in milliseconds
			higroup = "IncSearch", -- Highlight group to use (default is IncSearch)
		})
	end,
})
