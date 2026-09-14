-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", "<C-R>+") -- Paste insert mode
	vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+Pi', { noremap = true })
	vim.o.guifont = "FiraCode Nerd Font Mono:h14:w0"
	vim.opt.linespace = 1
	vim.g.neovide_normal_opacity = 0.5
	vim.g.transparency = 0.2
	vim.g.neovide_window_blurred = true
	vim.g.neovide_show_border = false
	vim.g.neovide_floating_blur_amount_x = 3
	vim.g.neovide_floating_blur_amount_y = 3
	vim.g.neovide_macos_simple_fullscreen = false
end

-- require("keymap_dump")

if not vim.g.vscode then
	require("config.run")
	require("config.lualine")
	require("themery").setup({
		themes = {
			-- custom: derived from Pictures/wallpaper/78036181_p0.jpg
			"ashfeather",
			-- ayu (bare "ayu" follows &background; ayu-light omitted)
			"ayu-dark",
			"ayu-mirage",
			-- catppuccin (bare duplicates the configured flavour; latte omitted)
			"catppuccin-mocha",
			-- "catppuccin-macchiato",
			-- "catppuccin-frappe",
			-- kanagawa (bare duplicates wave; lotus light variant omitted)
			"kanagawa-wave",
			"kanagawa-dragon",
			-- kanagawa-paper (bare is _theme="auto"; the canvas light variant is omitted)
			"kanagawa-paper-ink",
			-- lackluster (bare is its own theme, not an alias)
			"lackluster",
			"lackluster-dark",
			"lackluster-hack",
			"lackluster-mint",
			"lackluster-night",
			-- meowsoot (bare = the "night" variant; dawn omitted)
			"meowsoot",
			"meowsoot-moon",
			-- monokai-pro (bare = the "pro" filter, distinct from those below)
			"monokai-pro",
			-- "monokai-pro-classic",
			-- "monokai-pro-machine",
			"monokai-pro-octagon",
			-- "monokai-pro-ristretto",
			"monokai-pro-spectrum",
			-- neopywal (bare follows &background; the light variant is omitted)
			"neopywal-dark",
			-- onedark ships one colorscheme; its styles come from setup() (light omitted)
			{ name = "onedark", colorscheme = "onedark", before = [[require("onedark").setup({ style = "dark" })]] },
			-- {
			-- 	name = "onedark darker",
			-- 	colorscheme = "onedark",
			-- 	before = [[require("onedark").setup({ style = "darker" })]],
			-- },
			-- {
			-- 	name = "onedark cool",
			-- 	colorscheme = "onedark",
			-- 	before = [[require("onedark").setup({ style = "cool" })]],
			-- },
			-- {
			-- 	name = "onedark deep",
			-- 	colorscheme = "onedark",
			-- 	before = [[require("onedark").setup({ style = "deep" })]],
			-- },
			{
				name = "onedark warm",
				colorscheme = "onedark",
				before = [[require("onedark").setup({ style = "warm" })]],
			},
			-- {
			-- 	name = "onedark warmer",
			-- 	colorscheme = "onedark",
			-- 	before = [[require("onedark").setup({ style = "warmer" })]],
			-- },
			-- rose-pine (bare is sticky: it keeps the last-used variant; dawn omitted)
			"rose-pine-main",
			"rose-pine-moon",
			-- tokyonight (bare duplicates the configured style; day omitted)
			"tokyonight-night",
			"tokyonight-storm",
			-- "tokyonight-moon",
			-- single-variant themes
			"tokyodark",
			"sakura",
			"vague",
		},
		livePreview = true,
	})
end
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
