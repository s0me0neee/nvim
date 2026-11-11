-- tsc/ty rendering for colorful-menu.nvim without patching it; other servers go to colorful-menu
local cm = require("colorful-menu")
local utils = require("colorful-menu.utils")
local resolve = require("colorful-menu-ext.resolve")

local M = {}

local RENDERERS = { tsc = "tsc", tsgo = "tsc", ty = "ty" }

local DEFAULTS = {
	tsc = { extra_info_hl = "@comment", align_type_to_right = true, resolve_signatures = true },
	ty = { extra_info_hl = "@comment", align_type_to_right = true },
}

-- options live in colorful-menu's setup({ ls = { tsc = ..., ty = ... } }), which keeps unknown keys
local function opts(name)
	return vim.tbl_extend("force", DEFAULTS[name], cm.config.ls[name] or {})
end

-- blink draws text and highlights separately, so cache per item until its resolved detail arrives
local cache = setmetatable({}, { __mode = "k" })

---@return CMHighlights?
local function render(ctx)
	if vim.b.ts_highlight == false then
		return nil
	end
	local client = vim.lsp.get_client_by_id(ctx.item.client_id)
	local name = client and not client:is_stopped() and RENDERERS[client.name]
	if not name then
		return nil
	end

	local item = ctx.item
	local o = opts(name)
	local detail
	if name == "tsc" and o.resolve_signatures then
		resolve.resolve_visible()
		detail = resolve.detail(item)
	end
	local hit = cache[ctx.item]
	if hit and hit.detail == detail then
		return hit.result
	end

	if detail then
		item = vim.tbl_extend("force", item, { detail = detail })
	end
	local result = require("colorful-menu-ext." .. name).render(item, client.name, o)
	if result then
		result = utils.normalize_newlines(result)
		utils.apply_post_processing(item, result, client.name)
	end
	cache[ctx.item] = { detail = detail, result = result }
	return result
end

function M.blink_components_text(ctx)
	local result = render(ctx)
	if result then
		return result.text
	end
	return cm.blink_components_text(ctx)
end

function M.blink_components_highlight(ctx)
	local result = render(ctx)
	if not result then
		return cm.blink_components_highlight(ctx)
	end
	local highlights = {}
	for _, hl in ipairs(result.highlights or {}) do
		table.insert(highlights, {
			hl.range[1],
			hl.range[2],
			group = ctx.deprecated and "BlinkCmpLabelDeprecated" or hl[1],
		})
	end
	for _, idx in ipairs(ctx.label_matched_indices) do
		table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
	end
	return highlights
end

return M
