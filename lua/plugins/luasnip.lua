return {
	"L3MON4D3/LuaSnip",
	config = function(_, opts)
		require("luasnip").setup(opts)
		-- loads ~/.config/nvim/luasnippets/<filetype>.lua
		require("luasnip.loaders.from_lua").lazy_load()
	end,
}
