require("lualine").setup({
	options = {
		theme = "auto", -- This is the only thing you needed to change!
		component_separators = "",
		section_separators = { left = "", right = "" },
		disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
	},

	sections = {
		-- lualine_a = { "mode" },
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					local map = {
						["NORMAL"] = "通常",
						["INSERT"] = "挿入",
						["VISUAL"] = "視覚",
						["V-LINE"] = "行視覚",
						["V-BLOCK"] = "矩形視覚",
						["REPLACE"] = "置換",
						["COMMAND"] = "命令",
						["TERMINAL"] = "端末",
					}
					return map[str] or str
				end,
			},
		},

		lualine_b = {
			"branch",
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				sections = { "error" },
				-- diagnostics_color = { error = { fg = "#ffffff", bg = "#ff0000" } }, -- will be overridden by auto anyway
			},
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				sections = { "warn" },
				-- diagnostics_color = { warn = { fg = "#ffffff", bg = "#ffa500" } },
			},
			{ "filename", path = 1, file_status = false },
			{
				function()
					return vim.bo.modified and "M" or (vim.bo.modifiable == false or vim.bo.readonly) and "R" or ""
				end,
				-- color = { fg = "#ffffff", bg = "#ff0000" }, -- auto will recolor this correctly
				padding = { left = 0, right = 1 },
			},
			{
				"%w",
				cond = function()
					return vim.wo.previewwindow
				end,
			},
			{
				"%r",
				cond = function()
					return vim.bo.readonly
				end,
			},
			{
				"%q",
				cond = function()
					return vim.bo.buftype == "quickfix"
				end,
			},
		},

		lualine_c = {},

		lualine_x = {},

		lualine_y = {
			-- Search result: /pattern (current/total)
			{
				function()
					if vim.v.hlsearch == 0 then
						return ""
					end
					local last_search = vim.fn.getreg("/")
					if not last_search or last_search == "" then
						return ""
					end
					local searchcount = vim.fn.searchcount({ recompute = 1, maxcount = 9999 })
					if searchcount.total == 0 then
						return last_search
					end
					return last_search .. " (" .. searchcount.current .. "/" .. searchcount.total .. ")"
				end,
				-- color = { fg = "#ff9e64" }, -- auto theme will override this to match your scheme
			},
			"filetype",
		},

		lualine_z = {
			"%l:%c",
			"%p%%/%L",
		},
	},

	inactive_sections = {
		lualine_c = { "%f %y %m" },
		lualine_x = {},
	},
})
