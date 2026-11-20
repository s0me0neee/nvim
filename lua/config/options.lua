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
-- copilot as inline ghost text, not a blink menu entry
vim.g.ai_cmp = false

-- launcher-started nvim lacks zshrc's PATH, and the TS 7 tsc lives in bun's bin
local bun_bin = vim.fn.expand("~/.bun/bin")
if not vim.env.PATH:find(bun_bin, 1, true) then
	vim.env.PATH = bun_bin .. ":" .. vim.env.PATH
end

--require("vim._core.ui2").enable({})

-- set here, before plugins load, so it applies before the first LSP attach
vim.lsp.config("harper_ls", {
	filetypes = { "markdown" },
	-- harper errors on every configuration request without a settings object
	settings = { ["harper-ls"] = {} },
})
