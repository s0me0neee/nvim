return {
	"saghen/blink.cmp",
	lazy = false,
	dependencies = {},
	opts = {
		cmdline = { enabled = false },
		keymap = {
			preset = "none",
			["<C-j>"] = { "select_next" },
			["<C-k>"] = { "select_prev" },
			["<Down>"] = { "select_next" },
			["<Up>"] = { "select_prev" },
			["<CR>"] = { "select_and_accept", "fallback" },
		},
		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
			providers = {},
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
						kind = {
							text = function(ctx)
								local kind_icons = { Claude = "✻" }
								return kind_icons[ctx.kind] or ctx.kind
							end,
						},
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},

						source_name = {
							text = function(ctx)
								local source_map = {
									lsp = "LSP",
									buffer = "Buf",
									path = "Path",
									snippets = "Snip",
								}
								return source_map[ctx.source_name] or ctx.source_name
							end,
						},
					},
				},
			},
			documentation = {
				auto_show = false,
				auto_show_delay_ms = 250,
				window = {
					border = "none",
					max_width = math.floor(vim.o.columns * 0.4),
					max_height = math.floor(vim.o.lines * 0.5),
				},
			},
			ghost_text = { enabled = false },
		},
	},
	opts_extend = { "sources.default" },
}
