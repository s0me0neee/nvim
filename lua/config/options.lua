-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.cursorline = false
vim.opt.background = "dark"

vim.g.lazyvim_python_lsp = "ty"
vim.g.lazyvim_ts_lsp = "tsc"

--require("vim._core.ui2").enable({})

-- set here, before plugins load, so it applies before the first LSP attach
vim.lsp.config("harper_ls", {
	filetypes = { "markdown" },
	-- harper errors on every configuration request without a settings object
	settings = { ["harper-ls"] = {} },
})
