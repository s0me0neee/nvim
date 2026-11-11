return {
	"Mythos-404/xmake.nvim",
	lazy = true,
	cmd = "Xmake",
	config = true,
	-- the plugin blocks on `xmake show` once loaded, so only load it inside xmake projects
	init = function()
		vim.api.nvim_create_autocmd("BufReadPost", {
			group = vim.api.nvim_create_augroup("xmake_project_load", { clear = true }),
			callback = function(ev)
				if not vim.fs.root(ev.buf, "xmake.lua") then
					return
				end
				require("lazy").load({ plugins = { "xmake.nvim" } })
				-- loaded mid-event, so its own xmake.lua handler missed this read
				pcall(vim.api.nvim_exec_autocmds, "BufReadPost", { group = "xmake", buffer = ev.buf })
				return true
			end,
		})
	end,
}
