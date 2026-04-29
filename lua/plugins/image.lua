return {
	{
		"3rd/image.nvim",
		lazy = false,
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			markdown = {
				enabled = false,
			},
			backend = "kitty",
			processor = "magick_cli",
			max_width_window_percentage = nil,
			max_height_window_percentage = 75,
		},
	},
}
