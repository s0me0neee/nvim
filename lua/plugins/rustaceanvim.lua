local function project_root(fname)
	return vim.fs.root(fname, { "Cargo.toml", "rust-project.json", "Cargo.lock" })
end

local function add_to_list(client, key, path)
	local settings = client.settings["rust-analyzer"]
	settings[key] = settings[key] or {}
	if not vim.list_contains(settings[key], path) then
		table.insert(settings[key], path)
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end
end

return {
	{
		"mrcjkb/rustaceanvim",
		init = function()
			-- rustaceanvim only sends detachedFiles for a nil root on a new client, so register each file here
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("rust_detached_files", { clear = true }),
				pattern = "*.rs",
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local fname = vim.api.nvim_buf_get_name(args.buf)
					-- a detached path that doesn't exist yet breaks workspace loading
					if not client or client.name ~= "rust-analyzer" or not vim.uv.fs_stat(fname) then
						return
					end
					local root = project_root(fname)
					local manifest = root and vim.fs.joinpath(root, "Cargo.toml")
					if not root then
						add_to_list(client, "detachedFiles", fname)
					-- with detached files active, rust-analyzer no longer discovers projects added later
					elseif client.settings["rust-analyzer"].detachedFiles and vim.uv.fs_stat(manifest) then
						add_to_list(client, "linkedProjects", manifest)
					end
				end,
			})
		end,
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
					local root = project_root(fname)
					if root then
						return root
					end
					local scratch = vim.fs.joinpath(vim.fn.stdpath("cache"), "rust-analyzer-standalone")
					vim.fn.mkdir(scratch, "p")
					return scratch
				end,
				settings = function(root, defaults)
					local server = require("rustaceanvim.config.server")
					local settings = server.load_rust_analyzer_settings(root, { default_settings = defaults })
					local fname = vim.api.nvim_buf_get_name(0)
					-- must be set at initialize or the first file flashes "Failed to discover workspace"
					if vim.uv.fs_stat(fname) and not project_root(fname) then
						settings["rust-analyzer"].detachedFiles = { fname }
					end
					return settings
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
