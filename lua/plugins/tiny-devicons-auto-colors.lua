return {
	"rachartier/tiny-devicons-auto-colors.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		-- themery switches colorschemes often, so re-derive the palette each time
		autoreload = true,
	},
}
