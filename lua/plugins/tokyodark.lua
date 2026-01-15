return {
	{
		"tiagovla/tokyodark.nvim",
		lazy = true,
		opts = {
			transparent_background = false,
		},
		config = function(_, opts)
			require("tokyodark").setup(opts) -- calling setup is optional
		end,
	},
}
