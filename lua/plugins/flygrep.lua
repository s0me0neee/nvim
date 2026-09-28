return {
	{
		"wsdjeg/flygrep.nvim",
		dependencies = { "wsdjeg/job.nvim" },
		cmd = "FlyGrep",
		keys = {
			{
				"<leader>sg",
				-- :FlyGrep greps getcwd(); open() takes the root dir explicitly
				function()
					require("flygrep").open({ cwd = LazyVim.root() })
					-- mappings.next_item takes a single key; alias C-j/C-k onto Tab/S-Tab in the prompt buffer
					vim.keymap.set("i", "<C-j>", "<Tab>", { buffer = 0, remap = true })
					vim.keymap.set("i", "<C-k>", "<S-Tab>", { buffer = 0, remap = true })
				end,
				desc = "Grep (Root Dir)",
			},
		},
		opts = {
			enable_preview = true, -- off by default, unlike the picker it replaces
		},
	},

	-- LazyVim's snacks_picker extra owns <leader>sg; drop it so FlyGrep wins
	{
		"snacks.nvim",
		keys = {
			{ "<leader>sg", false },
		},
	},
}
