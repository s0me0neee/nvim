return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"onsails/lspkind.nvim", -- vscode-like pictograms
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		cmp.setup({
			-- window = {
			-- 	completion = {
			-- 		border = "none",
			-- 	},
			-- 	documentation = cmp.config.disable,
			-- },
			completion = {
				completeopt = "menu,menuone,noinsert", -- ✅ allow auto-select
			},
			preselect = cmp.PreselectMode.Item, -- ✅ highlight first item
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Insert,
					select = true,
				}),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-k>"] = cmp.mapping.select_prev_item(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- LSP suggestions
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
				{ name = "path" }, -- file system paths
			}),
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})
	end,
}
