return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		keys = {
			{ "<leader>cP", "<cmd>RenderMarkdown preview<cr>", ft = "markdown", desc = "Rendered Preview (split)" },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(ev)
					local src = require("render-markdown.core.preview").get(ev.buf)
					if not src then
						return
					end
					-- ts folding re-queries stale trees while the preview is rewritten, erroring in #trim!
					for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
						vim.wo[win][0].foldmethod = "manual"
					end
					-- closing the preview re-enables rendering on the source, undo that
					vim.api.nvim_create_autocmd("BufWipeout", {
						buffer = ev.buf,
						once = true,
						callback = vim.schedule_wrap(function()
							if vim.api.nvim_buf_is_valid(src) then
								require("render-markdown.core.manager").set_buf(src, false)
							end
						end),
					})
				end,
			})
		end,
		opts = {
			-- off in file buffers; only the preview split and LSP hover docs render
			enabled = false,
			latex = {
				converter = "latex2text",
			},
			overrides = {
				buftype = {
					nofile = {
						enabled = true,
						render_modes = true,
						sign = { enabled = false },
					},
				},
				preview = {
					enabled = true,
					render_modes = true,
					anti_conceal = { enabled = false },
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "latex" } },
	},
}
