return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				-- format lone files too; Biome defaults apply when no biome.json is found
				["biome-check"] = { require_cwd = false },
			},
		},
	},
}
