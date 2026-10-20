return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["*"] = {
					keys = {
						{ "<c-k>", false, mode = "i" },
					},
				},
				eslint = {
					-- tsc already covers fixes; eslint's actions just duplicate the menu
					on_init = function(client)
						client.server_capabilities.codeActionProvider = false
					end,
				},
				tsc = {
					mason = false, -- use the TS 7 tsc already on PATH
					settings = {
						inlayHints = {
							parameterNames = {
								enabled = "all",
								suppressWhenArgumentMatchesName = true,
							},
							parameterTypes = {
								enabled = true,
							},
							variableTypes = {
								enabled = true,
							},
							functionLikeReturnTypes = {
								enabled = false,
							},
							enumMemberValues = {
								enabled = true,
							},
						},
						codeLens = {
							referencesCodeLens = {
								enabled = true,
								showOnAllFunctions = true,
							},
							implementationsCodeLens = {
								enabled = true,
							},
						},
					},
				},
				ty = {
					cmd = { "ty", "server" },
					mason = false,
					settings = {
						ty = {
							inlayHints = {
								variableTypes = true,
								callArgumentNames = true,
							},
						},
					},
				},
				kotlin_lsp = {
					cmd = { "kotlin-lsp", "--stdio" },
					mason = false, -- brew's JetBrains/utils tap; Mason's registry pin is stale
				},
				lua_ls = {
					settings = {
						Lua = {
							hint = {
								enable = true,
								setType = true,
								paramType = true,
								paramName = "All",
								await = true,
								awaitPropagate = true,
							},
						},
					},
				},
			},
		},
	},
}
