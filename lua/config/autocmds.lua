-- Auto-loaded by LazyVim (lazyvim.config.init).

-- Force-kill every LSP client on exit. Neovim's graceful shutdown gives servers
-- only a short window; a busy rust-analyzer (mid-index) misses it and the
-- process orphans (survives `:q`).
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("lsp_force_exit", { clear = true }),
	callback = function()
		for _, client in ipairs(vim.lsp.get_clients()) do
			client:stop(true)
		end
	end,
})
