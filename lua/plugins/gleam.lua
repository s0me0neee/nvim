-- gleam format is hard-coded to 2 spaces; this re-indents its output to 4
local function reindent(_, _, lines, callback)
	local text = table.concat(lines, "\n")
	local parser = vim.treesitter.get_string_parser(text, "gleam")
	local root = parser:parse()[1]:root()

	-- continuation lines of multiline strings are literal content, leave them alone
	local in_string = {}
	local query = vim.treesitter.query.parse("gleam", "(string) @s")
	for _, node in query:iter_captures(root, text) do
		local srow, _, erow = node:range()
		for row = srow + 1, erow do
			in_string[row] = true
		end
	end

	local out = {}
	for i, line in ipairs(lines) do
		out[i] = in_string[i - 1] and line or line:gsub("^( +)", "%1%1")
	end
	callback(nil, out)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gleam",
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
	end,
})

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				gleam_indent4 = { format = reindent },
			},
			formatters_by_ft = {
				gleam = { "gleam", "gleam_indent4" },
			},
		},
	},
}
