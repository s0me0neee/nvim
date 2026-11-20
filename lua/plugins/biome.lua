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
					-- no project config (stop excludes $HOME itself) -> use ~/.biome.json if present, else biome defaults
					env = function(_, ctx)
						local names = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
						local found = vim.fs.find(names, { upward = true, path = ctx.dirname, stop = vim.env.HOME })
						local fallback = vim.env.HOME .. "/.biome.json"
						if #found == 0 and vim.uv.fs_stat(fallback) then
							return { BIOME_CONFIG_PATH = fallback }
						end
					end,
				},
			},
		},
	},
}
