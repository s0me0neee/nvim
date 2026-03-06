return {
	"TheLazyCat00/runner-nvim",
	opts = {}, -- This is required to call setup()
	keys = {
		{
			"<leader>re",
			function()
				require("runner-nvim").runLast()
			end,
			desc = "Run last cmd",
		},
		{
			"<leader>rr",
			function()
				require("runner-nvim").run()
			end,
			desc = "Run cmd",
		},
		{
			"<leader>rt",
			function()
				require("runner-nvim").toggle()
			end,
			desc = "Toggle terminal",
		},
	},
}
