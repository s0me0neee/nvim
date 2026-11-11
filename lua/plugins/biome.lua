return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- formatting goes through conform's biome CLI; skip the language server
				biome = { enabled = false },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				-- format lone files too
				["biome-check"] = {
					require_cwd = false,
					-- no project config (stop excludes $HOME itself) -> use ~/.biome.json
					env = function(_, ctx)
						local names = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
						local found = vim.fs.find(names, { upward = true, path = ctx.dirname, stop = vim.env.HOME })
						if #found == 0 then
							return { BIOME_CONFIG_PATH = vim.env.HOME .. "/.biome.json" }
						end
					end,
				},
			},
		},
	},
}
