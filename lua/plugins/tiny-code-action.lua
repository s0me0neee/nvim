-- the plugin's snacks picker re-resolves the action on confirm (jdtls then returns broken edits)
-- and lets <CR> close the picker mid-preview (snacks then errors on the missing preview)
local resolving = false

local function preview(ctx)
	local previewer = require("tiny-code-action.previewers.snacks").term_previewer({
		bufnr = ctx.picker:filter().current_buf,
		cwd = vim.fn.getcwd(),
	})
	resolving = true
	local ok, ret = pcall(previewer, ctx)
	resolving = false
	if not ok then
		error(ret)
	end
	return ret
end

local function confirm(picker, item)
	-- <CR> during the preview's blocking resolve runs inside it; retry once that resolve is cached
	if resolving then
		vim.defer_fn(function()
			confirm(picker, item)
		end, 20)
		return
	end
	local bufnr = picker:filter().current_buf
	picker:close()
	local client = item and vim.lsp.get_client_by_id(item.client_id)
	if not client then
		return
	end
	require("tiny-code-action.pickers.snacks").apply_action(item.action, client, item.context, bufnr, item._resolved_action)
end

return {
	"rachartier/tiny-code-action.nvim",
	dependencies = { "folke/snacks.nvim" },
	event = "LspAttach",
	opts = {
		backend = "delta",
		picker = {
			"snacks",
			-- custom opts replace the plugin's snacks defaults, so keep its layout
			opts = { layout = "vertical", preview = preview, confirm = confirm },
		},
	},
}
