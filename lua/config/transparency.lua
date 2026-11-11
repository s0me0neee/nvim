local function clear_backgrounds()
	for _, group in ipairs({ "Normal", "NormalFloat", "NormalNC", "WhichKeyBorder", "WhichKeyFloat", "FloatBorder" }) do
		-- drop only the background; setting { bg = "none" } alone would also wipe fg and styles
		local hl = vim.api.nvim_get_hl(0, { name = group })
		if not hl.link then
			hl.bg, hl.ctermbg = nil, nil
			vim.api.nvim_set_hl(0, group, hl)
		end
	end
end

-- colors_name drops the variant for some themes (kanagawa-dragon reports "kanagawa"), so keep the requested name
local requested_scheme = vim.g.colors_name
local transparency_group = vim.api.nvim_create_augroup("transparency", { clear = true })
vim.api.nvim_create_autocmd("ColorSchemePre", {
	group = transparency_group,
	callback = function(ev)
		requested_scheme = ev.match
	end,
})

-- a theme switch repaints the backgrounds, so keep transparency on across it
vim.api.nvim_create_autocmd("ColorScheme", {
	group = transparency_group,
	callback = function()
		if vim.g.transparent_enabled then
			clear_backgrounds()
		end
	end,
})

Snacks.toggle
	.new({
		name = "Transparency",
		get = function()
			return vim.g.transparent_enabled == true
		end,
		set = function(state)
			vim.g.transparent_enabled = state
			if state then
				clear_backgrounds()
			elseif requested_scheme then
				-- the original backgrounds are gone, so reload the theme to get them back
				vim.cmd.colorscheme(requested_scheme)
			end
		end,
	})
	:map("<leader>uU")
