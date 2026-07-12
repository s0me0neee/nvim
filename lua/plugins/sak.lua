return {
	"anAcc22/sakura.nvim",
	lazy = true,
	dependencies = "rktjmp/lush.nvim",
	opts = {
		transparent = false, -- don't set background
	},
	config = function()
		vim.opt.background = "dark" -- or "light"
	end,
}
