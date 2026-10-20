return {
	{
		"DrKJeff16/triforce.nvim",
		dependencies = { "nvzone/volt" },
		keys = {
			{
				"<leader>T",
				function()
					require("triforce").show_profile()
				end,
			},
		},
		opts = {},
	},
}
