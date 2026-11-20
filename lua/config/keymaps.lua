-- LazyVim core and Neovim default maps I don't use or that duplicate another key
-- (plugin keys are removed in plugins/removed-keys.lua); pcall: some may not exist
for _, lhs in ipairs({
	"<leader>`", -- = <leader>bb
	"[b", -- = H
	"]b", -- = L
	"<leader>ft", -- = <C-/>
	"<leader>uZ", -- = <leader>wm
	"<leader>xq",
	"<leader>xl",
	"<leader>dpp",
	"<leader>dph",
	"<leader>uA",
	"<leader>ua",
	"<leader>uS",
	"<leader>uD",
	"<leader>K",
	"<C-w>d", -- = <leader>cd
	"<C-w><C-d>",
	"gO",
	"[a",
	"]a",
	"[A",
	"]A",
	"[T",
	"]T",
	"[<C-q>",
	"]<C-q>",
	"[<C-l>",
	"]<C-l>",
	"[<C-t>",
	"]<C-t>",
	"[L",
	"]L",
	"[Q",
	"]Q",
	"[l",
	"]l",
	"[D",
	"]D",
	"[B", -- built-in :brewind, exposed once bufferline's [B was removed
	"]B",
	"[d",
	"]d",
	"[e",
	"]e",
	"[w",
	"]w",
	"<leader>uc",
	"<leader><Tab><Tab>",
	"<leader><Tab>[",
	"<leader><Tab>]",
	"<leader><Tab>d",
	"<leader><Tab>f",
	"<leader><Tab>l",
	"<leader><Tab>o",
}) do
	pcall(vim.keymap.del, "n", lhs)
end
for _, lhs in ipairs({ "[n", "]n", "[N", "]N" }) do
	pcall(vim.keymap.del, "x", lhs)
end

-- built-in commands (window splits/close, q: cmdline window), not maps, so they can only be disabled
for _, lhs in ipairs({ "<C-w>s", "<C-w>v", "<C-w>c", "q:" }) do
	vim.keymap.set("n", lhs, "<Nop>")
end
-- LazyVim defines these as remaps of the <C-w> keys above, so give them the commands directly
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split Window Below" })
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split Window Right" })
vim.keymap.set("n", "<leader>wd", "<cmd>close<cr>", { desc = "Delete Window" })

-- LazyVim's <esc> plus closing noice's hover/signature popup, which only auto-closes on cursor move
vim.keymap.set("n", "<esc>", function()
	vim.cmd("noh")
	LazyVim.cmp.actions.snippet_stop()
	local docs = package.loaded["noice.lsp.docs"]
	if docs then
		for _, message in pairs(docs._messages) do
			if message:win() then
				docs.hide(message)
			end
		end
	end
	return "<esc>"
end, { expr = true, desc = "Escape, clear hlsearch, close hover" })

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = " Projects" })

vim.keymap.set("n", "<leader>h", function()
	Snacks.dashboard.open()
end, { desc = "Dashboard" })

vim.keymap.set("n", "<leader>t", "<cmd>Themery<cr>", { desc = " Themes" })

vim.keymap.set("n", "<leader>E", "<cmd>Neotree<cr>", { desc = "File exp" })

-- replace the word under the cursor on lines first..last, previewing the replacement inline
local function substitute_word(first, last)
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local pat = [[\V\<]] .. vim.fn.escape(word, [[\/]]) .. [[\>]]
	local hits = vim.fn.matchbufline(buf, pat, first, last)
	local match = vim.fn.matchadd("Search", ([[\%%>%dl\%%<%dl]]):format(first - 1, last + 1) .. pat)
	local ns = vim.api.nvim_create_namespace("substitute_preview")
	local conceallevel = vim.wo[win].conceallevel
	-- bare one-line input over the statusline instead of noice's popup or the :s command
	local input = Snacks.input({
		prompt = "",
		icon = "",
		prompt_pos = "left",
		expand = false,
		win = {
			row = vim.o.lines - 1,
			col = 0,
			width = 0,
			border = "none",
			keys = { i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true } },
		},
	}, function(repl)
		pcall(vim.fn.matchdelete, match, win)
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.wo[win].conceallevel = conceallevel
		if repl then
			vim.cmd(("keeppatterns %d,%ds/%s/%s/g"):format(first, last, pat, vim.fn.escape(repl, [[\/&~]])))
		end
	end)
	-- snacks pads the input with a statuscolumn even without a prompt
	vim.wo[input.win].statuscolumn = ""
	-- live preview: conceal each match and draw the typed text inline in its place
	input:on("TextChangedI", function()
		local text = input:text()
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.wo[win].conceallevel = text == "" and conceallevel or 2
		if text == "" then
			return
		end
		for _, hit in ipairs(hits) do
			vim.api.nvim_buf_set_extmark(buf, ns, hit.lnum - 1, hit.byteidx, {
				end_col = hit.byteidx + #hit.text,
				conceal = "",
				virt_text = { { text, "Search" } },
				virt_text_pos = "inline",
			})
		end
	end, { buf = true })
end

vim.keymap.set("n", "<leader>R", function()
	substitute_word(1, vim.api.nvim_buf_line_count(0))
end, { desc = "Substitute word under cursor" })

vim.keymap.set("x", "<leader>R", function()
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	if first > last then
		first, last = last, first
	end
	-- leave visual mode so the input and :s don't act on the selection
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	substitute_word(first, last)
end, { desc = "Substitute word under cursor in selected lines" })

-- only y and d fill the clipboard; an explicitly named register ("ac) is still honored
for _, key in ipairs({ "c", "C", "x", "X" }) do
	vim.keymap.set({ "n", "x" }, key, function()
		local reg = vim.v.register
		return (reg == '"' or reg == "+" or reg == "*") and '"_' .. key or key
	end, { expr = true })
end
-- visual P replaces the selection without yanking it
vim.keymap.set("x", "p", "P")
