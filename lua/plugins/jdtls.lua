return {
	"mfussenegger/nvim-jdtls",
	opts = {
		root_dir = function(path)
			local root = vim.fs.root(path, vim.lsp.config.jdtls.root_markers) or vim.fs.dirname(path)
			-- rooting at $HOME makes jdtls crawl everything
			return root ~= vim.env.HOME and root or vim.fn.stdpath("cache") .. "/jdtls/no-project"
		end,
	},
}
