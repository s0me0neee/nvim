return {
	"vE5li/better-goto-file.nvim",
	config = true,
	---@module "better-goto-file"
	---@type better-goto-file.Options
	opts = {
		keys = {
			{
				"<leader>f",
				mode = { "n" },
				function()
					require("better-goto-file").goto_file()
				end,
				silent = true,
				desc = "Better go to file under cursor",
			},
			{
				"<leader>f",
				mode = { "v" },
				'<Esc>:lua require("better-goto-file").goto_file_range()<cr>',
				silent = true,
				desc = "Better go to file in selection",
			},
		},
	},
}
