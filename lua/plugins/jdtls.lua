return {
	"mfussenegger/nvim-jdtls",
	opts = {
		root_dir = function(path)
			local root = vim.fs.root(path, vim.lsp.config.jdtls.root_markers) or vim.fs.dirname(path)
			-- rooting at $HOME makes jdtls crawl everything
			return root ~= vim.env.HOME and root or vim.fn.stdpath("cache") .. "/jdtls/no-project"
		end,
		settings = {
			java = {
				contentProvider = { preferred = "fernflower" },
				inlayHints = {
					variableTypes = { enabled = true },
					parameterTypes = { enabled = true },
				},
				completion = {
					guessMethodArguments = "off",
					chain = { enabled = true },
				},
				compile = { nullAnalysis = { mode = "automatic" } },
				configuration = { updateBuildConfiguration = "automatic" },
				implementationCodeLens = "all",
				symbols = { includeSourceMethodDeclarations = true },
			},
		},
	},
}
