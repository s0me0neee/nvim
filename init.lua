-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", "<C-R>+") -- Paste insert mode
	vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+Pi', { noremap = true })
	vim.o.guifont = "FiraCode Nerd Font Mono:h14:w0"
	vim.opt.linespace = 1
	vim.g.neovide_normal_opacity = 0.5
	vim.g.transparency = 0.2
	vim.g.neovide_window_blurred = true
	vim.g.neovide_show_border = false
	vim.g.neovide_floating_blur_amount_x = 3
	vim.g.neovide_floating_blur_amount_y = 3
	vim.g.neovide_macos_simple_fullscreen = false
end

if not vim.g.vscode then
	require("config.lualine")
	require("themery").setup({
		themes = {
			"ayu-dark",
			"tokyonight",
			"tokyonight-storm",
			"tokyodark",
			"catppuccin-mocha",
			"vague",
			"lackluster-hack",
			"lackluster-night",
			"kanagawa",
			"kanagawa-paper-ink",
			"onedark",
			"rose-pine",
			"rose-pine-moon",
			"sakura",
			"monokai-pro",
		},
		livePreview = true,
	})
end

-- vim.api.nvim_set_hl(0, "normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- -- Make which-key borders transparent
-- vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })
-- vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
--
-- -- You might also want to make these transparent for consistency
-- vim.api.nvim_set_hl(0, "normalfloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
