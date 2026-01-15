-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.clipboard = ""
vim.opt.termguicolors = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = false -- Use actual tab characters, not spaces
vim.opt.tabstop = 4 -- Display width of tab characters
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indentation
vim.opt.softtabstop = 4 -- Number of spaces tab key inserts/deletes
vim.opt.swapfile = false
vim.opt.cursorline = false

if vim.g.neovide then
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", "<C-R>+") -- Paste insert mode
	vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+Pi', { noremap = true })
	vim.o.guifont = "FiraCode Nerd Font:h18:w0"
	vim.opt.linespace = 1
	-- -- Helper function for transparency formatting
	local alpha = function()
		return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
	end
	-- g:neovide_opacity should be 0 if you want to unify transparency of content and title bar.
	-- vim.g.neovide_opacity = 0.1
	vim.g.neovide_normal_opacity = 0.2

	vim.g.transparency = 0.6

	vim.g.neovide_background_color = "#0d0d13" .. alpha()
	vim.g.neovide_window_blurred = false
	vim.g.neovide_show_border = false
	vim.g.neovide_floating_blur_amount_x = 3
	vim.g.neovide_floating_blur_amount_y = 3
	vim.g.neovide_macos_simple_fullscreen = false
end

require("config.cmp")
require("config.lualine")
require("krust").render()
require("config.inline_diag")
require("themery").setup({
	themes = {
		"gruvbox-material",
		"gruvbox-baby",
		{ name = "tokyonight", colorscheme = "tokyonight", before = [[require("config.tokyonight")]] },
		"tokyodark",
		"catppuccin-mocha",
		"vague",
		"lackluster-hack",
		"kanagawa",
		"kanagawa-paper-ink",
		"kanagawa-dragon",
		"everforest",
		"rose-pine",
		{
			name = "sakura",
			colorscheme = "sakura",
			before = [[vim.opt.background = "dark"]],
		},
	},
	livePreview = true,
})

-- vim.api.nvim_set_hl(0, "normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- -- Make which-key borders transparent
-- vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })
-- vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
--
-- -- You might also want to make these transparent for consistency
-- vim.api.nvim_set_hl(0, "normalfloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
