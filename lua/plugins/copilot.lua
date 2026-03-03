return {
	"zbirenbaum/copilot.lua",
	lazy = true,
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = { enabled = false },
		})
	end,
}
