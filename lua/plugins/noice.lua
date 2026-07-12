return {
	"folke/noice.nvim",
	lazy = true,
	enabled = true,
	opts = {
		lsp = {

			enabled = false,
			hover = {
				enabled = true,
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = false,
				["vim.lsp.util.stylize_markdown"] = false,
				["cmp.entry.get_documentation"] = false,
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
