return {
	-- lazy
	"sontungexpt/witch",
	priority = 1000,
	lazy = true,
	config = function(_, opts)
		require("witch").setup(opts)
	end,
}
