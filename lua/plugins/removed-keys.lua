-- LazyVim plugin keys I don't use or that duplicate another key
-- (core LazyVim and Neovim default maps are removed in config/keymaps.lua)
return {
	{
		"folke/snacks.nvim",
		keys = {
			{ "<leader>ff", false }, -- = <leader><space>
			{ "<leader>,", false }, -- = <leader>fb
			{ "<leader>sl", false },
			{ "<leader>sa", false },
			{ "<leader>sH", false },
			{ "<leader>sp", false },
			{ "<leader>gi", false },
			{ "<leader>gI", false },
			{ "<leader>gp", false },
			{ "<leader>gP", false },
			{ "<leader>dps", false },
			{ "<leader>sC", false },
			{ "<leader>s/", false },
			{ "<leader>sj", false },
			{ "<leader>gS", false },
			{ "<leader>.", false },
			{ "<leader>:", false },
			-- one key to open/close the scratch buffer, replacing LazyVim's <leader>. and scratch select
			{
				"<leader>S",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
		},
	},
	{
		"folke/persistence.nvim",
		keys = {
			{ "<leader>qd", false },
		},
	},
	{
		"folke/which-key.nvim",
		keys = {
			{ "<c-w><space>", false },
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = {
			{ "<leader>fe", false },
			{ "<leader>fE", false },
			-- LazyVim's <leader>e only remaps to <leader>fe, so give it the action directly
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
				end,
				desc = "Explorer NeoTree (Root Dir)",
			},
		},
	},
	{
		"folke/trouble.nvim",
		keys = {
			{ "<leader>xQ", false },
			{ "<leader>xL", false },
		},
	},
	{
		"folke/noice.nvim",
		keys = {
			{ "<leader>snd", false }, -- = <leader>un
		},
	},
	{
		"stevearc/conform.nvim",
		keys = {
			{ "<leader>cF", false, mode = { "n", "x" } },
		},
	},
	{
		"akinsho/bufferline.nvim",
		keys = {
			{ "[b", false }, -- = H
			{ "]b", false }, -- = L
			{ "[B", false },
			{ "]B", false },
			{ "<leader>bP", false },
			{ "<leader>bl", false },
			{ "<leader>br", false },
			{ "<leader>bj", false },
		},
	},
}
