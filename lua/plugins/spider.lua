-- camelCase/snake_case-aware w/e/b/ge that skip insignificant punctuation
-- Ex-command form (not a lua function) so dot-repeat works
return {
	"chrisgrieser/nvim-spider",
	opts = {},
	keys = {
		{ "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" }, desc = "Spider w" },
		{ "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "Spider e" },
		{ "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "Spider b" },
		{ "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider ge" },
		-- keep vim's cw = "change to end of word" (spider's cw would act like dw)
		{ "cw", "c<cmd>lua require('spider').motion('e')<CR>", desc = "Change to end of subword" },
	},
}
