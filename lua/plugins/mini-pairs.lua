-- a quote typed right after a word closes it rather than opening a new pair ('hello -> 'hello" not 'hello"")
local function quote(pair, not_after)
	return {
		action = "closeopen",
		pair = pair,
		neigh_pattern = "^[^%w\\" .. (not_after or "") .. "]",
		register = { cr = false },
	}
end

return {
	"nvim-mini/mini.pairs",
	opts = {
		mappings = {
			['"'] = quote('""'),
			["'"] = quote("''"),
			["`"] = quote("``"),
		},
	},
	config = function(_, opts)
		LazyVim.mini.pairs(opts)

		-- Rust lifetimes: &'a and <'a> shouldn't open a '' pair
		local function rust(buf)
			MiniPairs.map_buf(buf, "i", "'", quote("''", "&<"))
		end
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("mini_pairs_rust", { clear = true }),
			pattern = "rust",
			callback = function(ev)
				rust(ev.buf)
			end,
		})
		-- mini.pairs loads on VeryLazy, after a file opened at startup already got its filetype
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "rust" then
				rust(buf)
			end
		end
	end,
}
