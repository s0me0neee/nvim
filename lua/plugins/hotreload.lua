-- fs_event (FSEvents) watchers per buffer -> :checktime, so external edits land
-- without a FocusGained. Drop this once we're on nvim 0.13, which ships the same
-- thing in core as runtime/lua/nvim/autoread.lua.
return {
	"diogo464/hotreload.nvim",
	event = "VeryLazy",
	opts = {},
}
