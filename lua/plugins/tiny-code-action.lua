return {
	"rachartier/tiny-code-action.nvim",
	dependencies = { "folke/snacks.nvim" },
	event = "LspAttach",
	opts = {
		backend = "delta",
		picker = "snacks",
	},
}
