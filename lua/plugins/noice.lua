return {
	"folke/noice.nvim",
	lazy = true,
	opts = {
		lsp = {
			hover = {
				enabled = true,
				-- don't notify when the server has nothing for the cursor position (keywords, whitespace)
				silent = true,
			},
			-- let noice format all LSP markdown, not just its own hover window
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		views = {
			hover = {
				-- noice already wraps at word boundaries; this just lowers the 120-col default
				size = { max_width = 80 },
			},
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			inc_rename = false,
			long_message_to_split = true,
			lsp_doc_border = false,
		},
		cmdline = {
			view = "cmdline",
			format = {
				cmdline = { pattern = "^:", icon = ">", lang = "vim" },
			},
		},
		messages = {
			enabled = true, -- enables the Noice messages UI
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "shell_out",
				},
				view = "messages",
			},
		},
	},
}
