-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- require("keymap_dump")

if not vim.g.vscode then
	require("config.run")
	require("config.lualine")
	-- before transparent.nvim loads (VeryLazy), so its ColorScheme hook reads Normal's bg before it's cleared
	require("word-gradient").setup()
	require("themery").setup({
		themes = {
			"ashfeather",
			-- catppuccin (bare duplicates the configured flavour; latte omitted)
			"catppuccin-mocha",
			"cendre",
			-- kanagawa (bare duplicates wave; lotus light variant omitted)
			"kanagawa-wave",
			"kanagawa-dragon",
			-- kanagawa-paper (bare is _theme="auto"; the canvas light variant is omitted)
			"kanagawa-paper-ink",
			-- lackluster (bare is its own theme, not an alias)
			"lackluster",
			"lackluster-hack",
			-- meowsoot (bare = the "night" variant; dawn omitted)
			"meowsoot-moon",
			-- monokai-pro (bare = the "pro" filter, distinct from those below)
			"monokai-pro",
			"monokai-pro-octagon",
			-- onedark ships one colorscheme; its styles come from setup() (light omitted)
			{ name = "onedark", colorscheme = "onedark", before = [[require("onedark").setup({ style = "dark" })]] },
			{
				name = "onedark warm",
				colorscheme = "onedark",
				before = [[require("onedark").setup({ style = "warm" })]],
			},
			-- rose-pine (bare is sticky: it keeps the last-used variant; dawn omitted)
			"rose-pine-moon",
			"sora",
			-- tokyonight (bare duplicates the configured style; day omitted)
			"tokyonight-night",
			"tokyonight-storm",
			-- single-variant themes
			"tokyodark",
			"sakura",
			"vague",
		},
		livePreview = true,
	})
end
