return {
	"saghen/blink.cmp",
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
			default = { "lsp", "path", "snippets", "buffer" },
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
					enabled = false,
				},
			},
			list = {
				selection = {
					preselect = true,
					auto_insert = false,
				},
			},
			menu = {
				border = "single",
				scrollbar = false,
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind" },
						{ "label", gap = 1 },
					},
					components = {
						kind = {
							text = function(ctx)
								local kind_labels = {
									Function = "fn",
									Method = "meth",
									Variable = "var",
									Field = "field",
									Class = "cls",
									Interface = "iface",
									Module = "mod",
									Property = "prop",
									Constructor = "ctor",
									Enum = "enum",
									Keyword = "kw",
									Snippet = "snip",
									Text = "txt",
									Unit = "unit",
									Value = "val",
									Color = "clr",
									File = "file",
									Reference = "ref",
									Folder = "dir",
									EnumMember = "enm",
									Constant = "const",
									Struct = "struct",
									Event = "evt",
									Operator = "op",
									TypeParameter = "T",
								}
								return kind_labels[ctx.kind] or ctx.kind
							end,
						},
						label = {
							text = function(ctx)
								local label = ctx.label
								local detail = ctx.item.detail or ""
								-- Clean detail
								detail = detail:gsub("%s*%(%s*use%s+[^)]*%)", "")
								detail = detail:gsub("~", "")
								detail = detail:gsub("%s+", " ")

								if ctx.kind == "Function" or ctx.kind == "Method" then
									local args = detail:match("%b()") or "()"
									local ret = detail:match("%)%s*%->%s*(.+)") or ""
									label = label .. " " .. args
									if ret ~= "" then
										label = label .. " -> " .. ret
									end
								end
								return label
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
				auto_show_delay_ms = 200,
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
