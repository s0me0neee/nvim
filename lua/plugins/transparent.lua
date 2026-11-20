-- colors_name drops the variant for some themes (kanagawa-dragon reports "kanagawa"), so keep the requested name
local requested_scheme

return {
	"xiyaowong/transparent.nvim",
	-- after init.lua, so word-gradient's ColorScheme hook reads Normal's bg before this clears it
	event = "VeryLazy",
	init = function()
		-- registered at startup so it also sees LazyVim's and themery's initial colorscheme
		vim.api.nvim_create_autocmd("ColorSchemePre", {
			callback = function(ev)
				requested_scheme = ev.match
			end,
		})
	end,
	opts = {
		extra_groups = { "NormalFloat", "FloatBorder", "WhichKeyBorder", "WhichKeyFloat" },
	},
	config = function(_, opts)
		local transparent = require("transparent")
		transparent.setup(opts)
		-- loaded after VimEnter, so the plugin's own startup clear has already passed
		transparent.clear()

		Snacks.toggle
			.new({
				name = "Transparency",
				get = function()
					return vim.g.transparent_enabled == true
				end,
				set = function(state)
					-- toggle() reloads g:colors_name to restore backgrounds; point it at the real variant
					vim.g.colors_name = requested_scheme or vim.g.colors_name
					transparent.toggle(state)
				end,
			})
			:map("<leader>uU")
	end,
}
