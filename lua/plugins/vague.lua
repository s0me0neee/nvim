return {

	{
		"vague-theme/vague.nvim",
		lazy = true,
		config = function()
			require("vague").setup({
				transparent = true, -- don't set background
			})
		end,
		lazy = false,
	},
}
