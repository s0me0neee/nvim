return {
	{
		"saecki/crates.nvim",
		lazy = true,
		ft = { "toml" },
		config = function()
			require("crates").setup({
				completion = {
					-- cmp = {
					-- 	enabled = true,
					-- },
					-- crates = {
					-- 	enabled = true, -- disabled by default
					-- 	max_results = 8, -- The maximum number of search results to display
					-- 	min_chars = 3, -- The minimum number of charaters to type before completions begin appearing
					-- },
					-- lsp = {
					-- 	enabled = true,
					-- 	on_attach = function(client, bufnr)
					-- 		-- the same on_attach function as for your other language servers
					-- 		-- can be ommited if you're using the `LspAttach` autocmd
					-- 	end,
					-- 	actions = true,
					-- 	completion = true,
					-- 	hover = true,
					-- },
				},
			})
			-- require("blink-cmp").setup({
			-- 	sources = {
			-- 		compat = { "crates" },
			-- 		default = { "lsp", "path", "snippets", "buffer" },
			-- 	},
			-- })
		end,
	},
}
