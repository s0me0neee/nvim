return {
	"saghen/blink.cmp",
	lazy = false,
	opts = {
		-- Merged after LazyVim's kind icons. Filled letter = type, outline letter = member.
		appearance = {
			kind_icons = {
				Class = "󰯲 ",
				Interface = "󰰄 ",
				Struct = "󰰢 ",
				Enum = "󰯸 ",
				TypeParameter = "󰰥 ",
				Module = "󰰐 ",
				Namespace = "󰰓 ",
				Method = "󰰑 ",
				Function = "󰊕 ",
				Constructor = "󰯳 ",
				EnumMember = "󰯹 ",
				Field = "󰯼 ",
				Property = "󰰚 ",
				Variable = "󰰬 ",
				Constant = "󰏿 ",
				Keyword = "󰻾 ",
				Snippet = "󱄽 ",
				Text = "󰉿 ",
				File = "󰈔 ",
				Folder = "󰉋 ",
				Color = "󰏘 ",
				Operator = "󰪚 ",
				Value = "󰎠 ",
				Event = "󱐋 ",
				Unit = "󰑭 ",
				Reference = "󰬲 ",
				Array = "󰅪 ",
				Boolean = "󰨙 ",
				Null = "󰟢 ",
				Number = "󰎠 ",
				Object = "󰅩 ",
				String = "󰉿 ",
				Key = "󰌋 ",
				Package = "󰏗 ",
			},
		},
		cmdline = { enabled = false },
		keymap = {
			preset = "none",
			["<C-j>"] = { "select_next" },
			["<C-k>"] = { "select_prev" },
			["<Down>"] = { "select_next" },
			["<Up>"] = { "select_prev" },
			["<CR>"] = { "select_and_accept", "fallback" },
			["<C-e>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.hide()
					end
					return cmp.show()
				end,
			},
		},
		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
			providers = {
				lsp = {
					transform_items = function(_, items)
						for _, item in ipairs(items) do
							if
								item.client_name == "jdtls"
								and item.kind == vim.lsp.protocol.CompletionItemKind.Snippet
							then
								-- full-expression filterText outscores every method
								item.filterText = item.label
							end
						end
						return items
					end,
				},
			},
		},
		completion = {
			keyword = { range = "prefix" },
			trigger = {
				show_on_keyword = true,
				show_on_trigger_character = true,
				show_on_insert_on_trigger_character = true,
				show_on_accept_on_trigger_character = true,
			},
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			list = {
				selection = {
					preselect = true,
					auto_insert = false,
				},
			},
			menu = {
				border = "none",
				scrollbar = false,
				draw = {
					treesitter = { "lsp", "snippets", "buffer" },
					columns = { { "kind_icon" }, { "label", gap = 1 } },
					components = {
						label = {
							text = function(ctx)
								return require("colorful-menu-ext").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu-ext").blink_components_highlight(ctx)
							end,
						},
					},
				},
			},
			documentation = {
				auto_show = false,
				auto_show_delay_ms = 175,
				window = {
					border = "none",
					max_width = math.floor(vim.o.columns * 0.4),
					max_height = math.floor(vim.o.lines * 0.4),
				},
			},
			ghost_text = { enabled = false },
		},
	},
	opts_extend = { "sources.default" },
}
