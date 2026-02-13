return {
	{
		"gisketch/triforce.nvim",
		lazy = true,
		dependencies = {
			"nvzone/volt",
		},
		config = function()
			require("triforce").setup({
				-- Optional: Add your configuration here
				keymap = {
					show_profile = "<leader>T", -- Open profile with <leader>tp
				},
			})
		end,
	},
}
