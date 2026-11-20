local function project_root(fname)
	return vim.fs.root(fname, { "Cargo.toml", "rust-project.json", "Cargo.lock" })
end

-- returns true if the list changed
local function add_to_list(list, path)
	if vim.list_contains(list, path) then
		return false
	end
	table.insert(list, path)
	return true
end

-- rust-analyzer walks a detached file's whole parent dir (~20s in ~), so exclude its subdirs
local function exclude_subdirs(ra, fname)
	ra.files = ra.files or {}
	ra.files.exclude = ra.files.exclude or {}
	local dir = vim.fs.dirname(fname)
	local changed = false
	for name, kind in vim.fs.dir(dir) do
		if kind == "directory" then
			changed = add_to_list(ra.files.exclude, vim.fs.joinpath(dir, name)) or changed
		end
	end
	return changed
end

local function add_detached(ra, fname)
	ra.detachedFiles = ra.detachedFiles or {}
	local changed = add_to_list(ra.detachedFiles, fname)
	return exclude_subdirs(ra, fname) or changed
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
					local ra = client.settings["rust-analyzer"]
					local root = project_root(fname)
					local manifest = root and vim.fs.joinpath(root, "Cargo.toml")
					local changed = false
					if not root then
						changed = add_detached(ra, fname)
					-- with detached files active, rust-analyzer no longer discovers projects added later
					elseif ra.detachedFiles and vim.uv.fs_stat(manifest) then
						ra.linkedProjects = ra.linkedProjects or {}
						changed = add_to_list(ra.linkedProjects, manifest)
					end
					if changed then
						client:notify("workspace/didChangeConfiguration", { settings = client.settings })
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
				-- an unsaved standalone file can't be a detached file yet, so start on first write instead
				auto_attach = function(bufnr)
					if vim.bo[bufnr].buftype ~= "" then
						return false
					end
					local fname = vim.api.nvim_buf_get_name(bufnr)
					if fname == "" then
						return false
					end
					if vim.uv.fs_stat(fname) or project_root(fname) then
						return true
					end
					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						once = true,
						callback = function()
							require("rustaceanvim.lsp").start(bufnr)
						end,
					})
					return false
				end,
				-- nil for standalone files -> rustaceanvim's detached mode
				root_dir = project_root,
				settings = function(root, defaults)
					local server = require("rustaceanvim.config.server")
					local settings = server.load_rust_analyzer_settings(root, { default_settings = defaults })
					local fname = vim.api.nvim_buf_get_name(0)
					-- must be set at initialize or the first file flashes "Failed to discover workspace"
					if vim.uv.fs_stat(fname) and not project_root(fname) then
						add_detached(settings["rust-analyzer"], fname)
					end
					return settings
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = { features = "all" },
						inlayHints = {
							closureReturnTypeHints = { enable = "with_block" },
							lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
							closureCaptureHints = { enable = true },
							expressionAdjustmentHints = { enable = "reborrow" },
						},
						hover = { actions = { references = { enable = true } } },
						completion = { callable = { snippets = "add_parentheses" } },
					},
				},
			},
		},
	},
}
