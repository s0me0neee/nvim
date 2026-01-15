return {
	"luisiacc/gruvbox-baby",
	lazy = true,
	config = function()
		vim.g.gruvbox_baby_transparent_mode = false
		vim.g.gruvbox_baby_background_color = medium --medium or dark
		vim.g.gruvbox_baby_function_style = "bold" --see :h attr-list
		vim.g.gruvbox_baby_keyword_style = "italic"
		vim.g.gruvbox_baby_comment_style = "italic"
		vim.g.gruvbox_baby_string_style = "nocombine"
	end,
}
