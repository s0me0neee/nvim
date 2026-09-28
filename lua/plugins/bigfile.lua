-- keep buffer-attaching plugins away from files snacks flagged as bigfile
return {
	{
		"gitsigns.nvim",
		opts = function(_, opts)
			local on_attach = opts.on_attach
			opts.on_attach = function(buf)
				if vim.bo[buf].filetype == "bigfile" then
					return false
				end
				return on_attach and on_attach(buf)
			end
		end,
	},
	{
		"todo-comments.nvim",
		opts = { highlight = { exclude = { "bigfile" } } },
	},
}
