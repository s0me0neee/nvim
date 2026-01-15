-- Minimal nvim-cmp configuration without hahast text
local cmp = require("cmp")
cmp.setup({

	-- Disable ghost text (inline suggestions)
	experimental = {
		ghost_text = false,
	},
	-- Minimal window styling - no documentation window
	window = {
		completion = {
			border = "single",
			-- winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
		},
		-- Remove documentation window completely
		documentation = cmp.config.disable,
	},
	-- Formatting to show completion type, parameters and return types inline
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			-- Longer, still compact kind labels
			local kind_labels = {
				Function = "fn",
				Method = "meth",
				Variable = "var",
				Field = "field",
				Class = "cls",
				Interface = "iface",
				Module = "mod",
				Property = "prop",
				Constructor = "ctor",
				Enum = "enum",
				Keyword = "kw",
				Snippet = "snip",
				Text = "txt",
				Unit = "unit",
				Value = "val",
				Color = "clr",
				File = "file",
				Reference = "ref",
				Folder = "dir",
				EnumMember = "enm",
				Constant = "const",
				Struct = "struct",
				Event = "evt",
				Operator = "op",
				TypeParameter = "T",
			}

			local ci = entry.completion_item
			local label = ci.label or vim_item.abbr

			-- Remove function source like "(use std::path::PathBuf)"
			local function clean_detail(d)
				d = d or ""
				d = d:gsub("%s*%(%s*use%s+[^)]*%)", "")
				d = d:gsub("~", "")
				d = d:gsub("%s+", " ")
				return d
			end

			local detail = clean_detail(ci.detail)

			if ci.kind == 3 or ci.kind == 2 then -- Function or Method
				local args = detail:match("%b()") or "()"
				local ret = detail:match("%)%s*%->%s*(.+)") or ""
				local display = label .. " " .. args
				if ret ~= "" then
					display = display .. " -> " .. ret
				end
				vim_item.abbr = display
			else
				-- Non-function items: just the name
				vim_item.abbr = label
			end

			-- Keep compact kind label
			vim_item.kind = kind_labels[vim_item.kind] or (vim_item.kind or ""):lower()

			-- Source menu (includes Snippet)
			vim_item.menu = ({
				nvim_lsp = "LSP",
				buffer = "Buf",
				path = "Path",
				luasnip = "Snippet",
				crates = "Crate",
				cmp_tabnine = "TN",
			})[entry.source.name] or ""
			return vim_item
		end,
	},
	-- Key mappings with insert behavior
	mapping = cmp.mapping.preset.insert({

		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-k>"] = cmp.mapping.select_prev_item(),
	}),
	-- Your completion sources
	sources = cmp.config.sources({
		{ name = "cmp_tabnine" },
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "luasnip" },
	}),
})
