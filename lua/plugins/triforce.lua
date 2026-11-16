return {
	{
		"gisketch/triforce.nvim",
		dependencies = { "nvzone/volt" },
		keys = {
			{
				"<leader>T",
				function()
					require("triforce").show_profile()
				end,
			},
		},
		opts = {},
		config = function(_, opts)
			require("triforce").setup(opts)
			-- upstream replaces the language table with bare names on every random fact, so the
			-- second call empties it and the Languages tab loses all names and icons; only read it
			local languages = require("triforce.languages")
			require("triforce.random_stats").format_language_name = function(filetype)
				local spec = languages.get_langs()[filetype]
				return spec and spec.name or filetype
			end
		end,
	},
}
