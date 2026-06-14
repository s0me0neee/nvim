return {
	"stevearc/oil.nvim",
	enabled = false,
	opts = {
		keymaps = {
			["g?"] = { "actions.show_help", mode = "n" },
			["l"] = "actions.select",
			["<C-p>"] = "actions.preview",
			["<C-r>"] = "actions.refresh",
			["h"] = { "actions.parent", mode = "n" },
			["0"] = { "actions.open_cwd", mode = "n" },
			["q"] = { "actions.close", mode = "n" },
			["."] = { "actions.cd", mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["H"] = { "actions.toggle_hidden", mode = "n" },
		},
	},
	lazy = false,
}
