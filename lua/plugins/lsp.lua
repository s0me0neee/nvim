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
				vtsls = {
					settings = {
						typescript = {
							inlayHints = {
								variableTypes = { enabled = true },
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
