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

if vim.g.neovide then
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", "<C-R>+") -- Paste insert mode
	vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+Pi', { noremap = true })
	vim.o.guifont = "Maple Mono NF:h16.5:w1.5"
	vim.g.neovide_opacity = 1
	vim.g.neovide_scale_factor = 1.0
	vim.g.neovide_normal_opacity = 0.5
	vim.g.transparency = 0.2
	vim.g.neovide_window_blurred = false
	vim.g.neovide_padding_top = 3
	vim.o.linespace = 6
	-- noice draws the cmdline; needs Neovide >= 0.17.2 or the statusline stretches into the bottom gap
	vim.o.cmdheight = 0
	vim.g.neovide_show_border = false
	vim.g.neovide_floating_blur_amount_x = 3
	vim.g.neovide_floating_blur_amount_y = 3
	vim.g.neovide_macos_simple_fullscreen = false
	-- the see-through title bar draws the title over the grid; a blank title hides it
	vim.o.title = true
	vim.o.titlestring = " "
end

-- set here, before plugins load, so it applies before the first LSP attach
vim.lsp.config("harper_ls", {
	filetypes = { "markdown" },
	-- harper errors on every configuration request without a settings object
	settings = { ["harper-ls"] = {} },
})
