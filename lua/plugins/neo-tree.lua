return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			filesystem = {
				filtered_items = {
					hide_dotfiles = true,
					hide_gitignored = false,
				},
			},
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						-- Neo-tree opens files via bufadd()+nvim_win_set_buf(), which
						-- skips Vim's usual cleanup of the lone empty [No Name] buffer,
						-- leaving it orphaned in the buffer list. Sweep it up.
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if
								vim.api.nvim_buf_get_name(buf) == ""
								and vim.bo[buf].buftype == ""
								and not vim.bo[buf].modified
								and #vim.fn.win_findbuf(buf) == 0
							then
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end
					end,
				},
			},
		},
	},
}
