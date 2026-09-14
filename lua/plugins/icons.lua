return {
	-- The real thing. LazyVim never installs this: it ships mini.icons and has
	-- it mock the nvim-web-devicons module instead (lazyvim/plugins/ui.lua).
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		opts = {},
	},

	-- Disabling mini.icons is what actually flips the provider, in two ways:
	--
	--   1. Consumers that `require("nvim-web-devicons")` -- neo-tree, bufferline,
	--      lualine -- currently get the mock, because LazyVim's mini.icons spec
	--      sets `package.preload["nvim-web-devicons"]` in its `init`. A disabled
	--      spec's `init` never runs, so the preload hook is gone and the require
	--      resolves to the plugin above.
	--
	--   2. Consumers that probe `MiniIcons` first and fall back to devicons --
	--      snacks (util/init.lua) and trouble (format.lua) -- find no MiniIcons
	--      global and take the devicons branch.
	{ "nvim-mini/mini.icons", enabled = false },
}
