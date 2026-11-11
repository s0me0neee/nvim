return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["*"] = {
					keys = {
						{ "<c-k>", false, mode = "i" },
						{
							"<leader>ca",
							function()
								require("tiny-code-action").code_action()
							end,
							desc = "Code Action",
							mode = { "n", "x" },
							has = "codeAction",
						},
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
					cmd = { "tsc", "--lsp", "--stdio" },
					-- lspconfig's root_dir blocks on `tsc --version` per project; this one only skips that check
					root_dir = function(bufnr, on_dir)
						local locks = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
						local project_root = vim.fs.root(bufnr, { locks, { ".git" } })
						local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
						local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
						-- a closer deno project belongs to denols
						if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
							return
						end
						if deno_root and (not project_root or #deno_root >= #project_root) then
							return
						end
						on_dir(project_root or vim.fn.getcwd())
					end,
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
