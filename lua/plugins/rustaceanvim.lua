return {
	{
		"mrcjkb/rustaceanvim",
		opts = {
			tools = {
				-- Use plain `cargo test` for runnables instead of auto-switching to
				-- `cargo nextest run`, which strips --nocapture and hides test output.
				enable_nextest = false,
			},
			server = {
				-- For a .rs file that is not inside a Cargo / rust-project tree,
				-- root rust-analyzer at a fixed EMPTY dir instead of the file's
				-- parent directory. Stops it crawling home / a big polyglot repo /
				-- node_modules on every scratch file. std still resolves via the
				-- discovered sysroot.
				root_dir = function(fname)
					local root = vim.fs.root(fname, { "Cargo.toml", "rust-project.json", "Cargo.lock" })
					if root then
						return root
					end
					local scratch = vim.fs.joinpath(vim.fn.stdpath("cache"), "rust-analyzer-standalone")
					vim.fn.mkdir(scratch, "p")
					return scratch
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = { features = "all" },
					},
				},
			},
		},
	},
}
