return {
	dir = vim.fn.expand("~/jetbrain/rust/flcc"),
	name = "flcc",
	build = "cargo build --release",
	-- disabled in favor of minuet-ai.nvim for now -- flip back to true (or
	-- delete this line) to re-enable.
	enabled = false,
	config = function()
		require("flcc").setup({
			host = "http://localhost",
			port = 11434,
			model = "qwen2.5-coder:1.5b-base",
			max_tokens = 40,
			top_p = 0.9,
			stop = { "\n" },
			auto_trigger_ft = { "*" },
			keymap = { accept = "<Tab>" },
		})
	end,
}
