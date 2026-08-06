return {
	{
		"mrcjkb/rustaceanvim",
		opts = {
			tools = {
				-- Use plain `cargo test` for runnables instead of auto-switching to
				-- `cargo nextest run`, which strips --nocapture and hides test output.
				enable_nextest = false,
			},
		},
	},
}
