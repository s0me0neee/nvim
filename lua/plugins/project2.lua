return {
	{
		"coffebar/neovim-project",
		opts = {
			projects = { -- define project roots
				"~/.config/*",
				"~/JetBrain/Clion/*",
				"~/JetBrain/go/*",
				"~/JetBrain/lua/*",
				"~/JetBrain/nim/*",
				"~/JetBrain/Webstorm/*",
				"~/JetBrain/PyCharm/*",
				"~/JetBrain/Rider/*",
				"~/JetBrain/IntelliJ/*",
				"~/JetBrain/rust/*",
				"~/*",
				"~/Documents/*",
				"~/JetBrain/leetcode/",
			},
			last_session_on_startup = false,
			dashboard_mode = true,
			picker = {
				type = "snacks", -- one of "telescope", "fzf-lua", or "snacks"
				preview = {
					enabled = true, -- show directory structure in Telescope preview
					git_status = true, -- show branch name, an ahead/behind counter, and the git status of each file/folder
					git_fetch = false, -- fetch from remote, used to display the number of commits ahead/behind, requires git authorization
					show_hidden = true, -- show hidden files/folders
				},
			},
		},
		init = function()
			vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
		end,
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
			{ "Shatur/neovim-session-manager" },
		},
		lazy = false,
		priority = 100,
	},
}
