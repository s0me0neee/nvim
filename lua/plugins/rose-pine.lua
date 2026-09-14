return {
	"rose-pine/neovim",
	name = "rose-pine",
	lazy = true,
	config = function()
		require("rose-pine").setup({
			dark_variant = "main",
			styles = { italic = false, transparency = false },
			palette = {
				dawn = {
					no_bg = "#faf4ed",
					cursor_bg = "#000000",
					cursor_fg = "#ffffff",
				},
				-- Deep rose-pine moon. Base #161829 keeps the near-black depth but
				-- its hue is rotated back to 232deg, 40% of the way from the blue
				-- slate toward stock moon's 246deg violet. Every accent is likewise
				-- blended 40% toward its stock rose-pine value, keeping the light
				-- pastel character: band 4.3:1 - 12.1:1, 2.83x spread.
				moon = {
					-- background ramp, hue 232 held across every step
					_nc = "#121422",
					base = "#161829",
					surface = "#1b1e31",
					overlay = "#22253d",
					highlight_low = "#191c2f",
					highlight_med = "#272b45",
					highlight_high = "#2f3452",

					-- foreground, solved for target contrast vs base
					text = "#d6d3f0", -- 12.1:1  body text
					gold = "#f6bf73", -- 10.5:1  strings, constants
					foam = "#9bced8", -- 10.2:1  types
					iris = "#cab1e9", --  9.2:1
					rose = "#eca5a2", --  8.8:1  functions
					leaf = "#9db7b3", --  8.2:1
					love = "#ed84a2", --  7.0:1  errors
					subtle = "#9b97b2", --  6.2:1  comments
					pine = "#63a5bf", --  6.4:1  keywords
					muted = "#7e7a93", --  4.3:1  line nrs, borders

					no_bg = "#000000",
					cursor_bg = "#ffffff",
					cursor_fg = "#000000",
				},
			},
			-- highlight_groups = {
			-- 	Normal = { bg = "no_bg" },
			-- 	Cursor = { bg = "cursor_bg", fg = "cursor_fg" },
			-- 	Directory = { fg = "foam", bold = false },
			-- 	StatusLine = { bg = "surface", fg = "subtle" },
			-- 	StatusLineTerm = { link = "StatusLine" },
			-- 	StatusLineNC = { link = "StatusLine" },
			-- 	--- gitsigns
			-- 	StatusLineGitSignsAdd = { bg = "surface", fg = "pine" },
			-- 	StatusLineGitSignsChange = { bg = "surface", fg = "gold" },
			-- 	StatusLineGitSignsDelete = { bg = "surface", fg = "rose" },
			-- 	--- diagnostics
			-- 	StatusLineDiagnosticSignError = { bg = "surface", fg = "love" },
			-- 	StatusLineDiagnosticSignWarn = { bg = "surface", fg = "gold" },
			-- 	StatusLineDiagnosticSignInfo = { bg = "surface", fg = "foam" },
			-- 	StatusLineDiagnosticSignHint = { bg = "surface", fg = "iris" },
			-- 	StatusLineDiagnosticSignOk = { bg = "surface", fg = "pine" },
			-- },
		})
	end,
}
