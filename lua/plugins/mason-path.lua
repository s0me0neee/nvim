-- skip Mason installs for anything already on PATH outside Mason

-- java extra loads lombok.jar from Mason's jdtls package
local keep_mason = { jdtls = true }

local function on_path(bin)
	for dir in vim.gsplit(vim.env.PATH or "", ":", { plain = true }) do
		if not dir:find("/mason/", 1, true) and vim.fn.executable(dir .. "/" .. bin) == 1 then
			return true
		end
	end
	return false
end

local function pkg_on_path(name)
	local ok, pkg = pcall(function()
		return require("mason-registry").get_package(name)
	end)
	local bins = ok and pkg.spec.bin and vim.tbl_keys(pkg.spec.bin) or {}
	return #bins > 0 and vim.iter(bins):any(on_path)
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			local ok, mappings = pcall(require, "mason-lspconfig.mappings")
			local to_pkg = ok and mappings.get_mason_map().lspconfig_to_package or {}
			for server, sopts in pairs(opts.servers) do
				if sopts == true then
					sopts = {}
					opts.servers[server] = sopts
				end
				if
					type(sopts) == "table"
					and sopts.enabled ~= false
					and sopts.mason ~= false
					and to_pkg[server]
					and not keep_mason[server]
					and pkg_on_path(to_pkg[server])
				then
					sopts.mason = false
				end
			end
		end,
	},
	{
		"mason-org/mason.nvim",
		-- let PATH binaries win over Mason's copies when both exist
		opts = { PATH = "append" },
		-- replaces LazyVim's config: package bins are only known after setup, too late for opts
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType so a newly installed server can attach
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)
			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() and (keep_mason[tool] or not pkg_on_path(tool)) then
						p:install()
					end
				end
			end)
		end,
	},
}
