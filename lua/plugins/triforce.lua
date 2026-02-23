return {
	{
		"gisketch/triforce.nvim",
		lazy = false,
		dependencies = {
			"nvzone/volt",
		},
		config = function()
			require("triforce").setup({
				keymap = {
					show_profile = "<leader>T", -- Open profile with <leader>tp
				},
			})
		end,
	},
}
