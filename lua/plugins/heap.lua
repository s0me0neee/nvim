return {
	"valonmulolli/heap.nvim",
	priority = 1000,
	config = function()
		require("heap").setup({
			variant = "default", -- "default" or "dark"
			transparent = false,
		})
	end,
}
