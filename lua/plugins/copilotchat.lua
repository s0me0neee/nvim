return {
	-- "CopilotC-Nvim/CopilotChat.nvim",
	-- lazy = true,
	-- dependencies = {
	-- 	{ "zbirenbaum/copilot.lua" }, -- Your existing copilot.lua
	-- 	{ "nvim-lua/plenary.nvim" }, -- For curl, log wrapper
	-- },
	-- build = "make tiktoken", -- Only if you want token counting (optional)
	-- opts = {
	-- 	window = {
	-- 		layout = "vertical", -- 'vertical', 'horizontal', 'float', 'replace'
	-- 		width = 0.3, -- fractional width of parent
	-- 	},
	-- },
	-- keys = {
	-- 	{ "<leader>co", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
	-- 	{ "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
	-- },
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		opts = {
			provider = "copilot", -- Set Copilot as the default AI
		},
		dependencies = { "zbirenbaum/copilot.lua", ... },
	},
}
