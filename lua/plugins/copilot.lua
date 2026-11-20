-- LazyVim's ai.copilot extra does the base setup; <Tab> accepts via blink's ai_accept
return {
	"zbirenbaum/copilot.lua",
	enabled = false,
	opts = {
		suggestion = {
			-- keep the ghost text visible while the blink menu is open
			hide_during_completion = false,
			keymap = {
				accept_line = "<S-Tab>",
			},
		},
	},
}
