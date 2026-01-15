return {
	{
		"eero-lehtinen/oklch-color-picker.nvim",
		event = "VeryLazy",
		keys = {
			-- One handed keymap recommended, you will be using the mouse
			{
				"<leader>cq",
				function()
					require("oklch-color-picker").pick_under_cursor()
				end,
				desc = "Color pick under cursor",
			},
		},
		---@type oklch.Opts
		opts = {},
	},
}
