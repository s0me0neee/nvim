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
			["<Tab>"] = {
				function()
					return LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" })()
				end,
				"fallback",
			},
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
				-- stop at the ends instead of wrapping around
				cycle = { from_bottom = false, from_top = false },
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
				auto_show = true,
				auto_show_delay_ms = 750,
				draw = function(opts)
					local item = opts.item
					if item.client_name == "ty" and type(item.detail) == "string" then
						local width = opts.window.config.max_width
						local lines = require("colorful-menu-ext.ty").format_detail(item.label, item.detail, width)
						if lines then
							-- one string: a list gets deduplicated, which would drop repeated stub lines
							return opts.default_implementation({ detail = table.concat(lines, "\n") })
						end
					end
					opts.default_implementation()
				end,
				window = {
					border = "none",
					max_width = math.floor(vim.o.columns * 0.4),
					max_height = math.floor(vim.o.lines * 0.3),
				},
			},
			ghost_text = { enabled = false },
		},
	},
	opts_extend = { "sources.default" },
}
