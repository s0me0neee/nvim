return {
	{
		"AetherSyscall/AetherAmethyst.nvim",
		priority = 1000,
		config = function()
			require("aetheramethyst").setup({
				transparent = false, -- Enable transparent background
			})
		end,
	},
}
