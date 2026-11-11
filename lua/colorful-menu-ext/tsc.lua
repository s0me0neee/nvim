local cm = require("colorful-menu")
local utils = require("colorful-menu.utils")
local Kind = cm.Kind

local M = {}

local function one_line(s)
	return (s:gsub("    ", ""):gsub("\n", " "))
end

local KIND_HL = {
	[Kind.Class] = "@type",
	[Kind.Constructor] = "@type",
	[Kind.Constant] = "@constant",
	[Kind.Function] = "@function",
	[Kind.Method] = "@function",
	[Kind.Property] = "@property",
	[Kind.Field] = "@property",
	[Kind.Variable] = "@variable",
}

local function kind_hl(kind)
	if kind == Kind.Enum then
		return utils.hl_exist_or("@lsp.type.enum", "@type")
	elseif kind == Kind.EnumMember then
		return utils.hl_exist_or("@lsp.type.enumMember", "@type")
	elseif kind == Kind.Interface then
		return utils.hl_exist_or("@lsp.type.interface", "@type")
	end
	return KIND_HL[kind] or cm.config.fallback_highlight
end

-- label plus labelDetails (auto-import module), like colorful-menu's vtsls renderer but alignable
local function label_details(item, ls, o)
	local label = item.label
	if not item.kind then
		return utils.highlight_range(label, ls, 0, #label)
	end
	local result = { text = label, highlights = { { kind_hl(item.kind), range = { 0, #label } } } }
	local extra = vim.tbl_get(item, "labelDetails", "description")
	if o.extra_info_hl ~= false and extra then
		extra = one_line(extra)
		local space = o.align_type_to_right and utils.align_spaces_bell(label, extra) or " "
		result.text = label .. space .. extra
		table.insert(result.highlights, { o.extra_info_hl, range = { #label + #space, #result.text } })
	end
	return result
end

-- resolved detail is "function f<T>(a: T): R" or "(method) Foo.f(): R", one line per overload
local function signature(detail, label)
	local overloads = 1
	for _ in detail:gmatch("\n%s*function ") do
		overloads = overloads + 1
	end
	for _ in detail:gmatch("\n%s*%(method%) ") do
		overloads = overloads + 1
	end
	if overloads > 1 then
		detail = detail:match("^(.-)\n%s*[f(]") or detail
	end
	local init = 1
	while true do
		local _, e = detail:find(label, init, true)
		if not e then
			return nil, overloads
		end
		local sig = detail:sub(e + 1)
		if sig:match("^[<(]") then
			return one_line(sig), overloads
		end
		init = e + 1
	end
end

---@return CMHighlights
function M.render(item, ls, o)
	local kind = item.kind
	local sig, overloads
	if item.detail and (kind == Kind.Function or kind == Kind.Method or kind == Kind.Constructor) then
		sig, overloads = signature(item.detail, item.label)
	end
	if not sig then
		return label_details(item, ls, o)
	end

	local label = item.label
	local text = label .. sig
	local result = utils.highlight_range("function " .. text .. " {}", ls, 9, 9 + #text)
	if #result.highlights == 0 then
		result.highlights = { { "@function", range = { 0, #label } } }
	end
	if o.extra_info_hl == false then
		return result
	end

	local more = overloads == 2 and "(+1 overload)" or overloads > 2 and string.format("(+%d overloads)", overloads - 1)
	if more then
		result.text = result.text .. " " .. more
		table.insert(result.highlights, { o.extra_info_hl, range = { #result.text - #more, #result.text } })
	end
	local module = vim.tbl_get(item, "labelDetails", "description")
	if module then
		local space = o.align_type_to_right and utils.align_spaces_bell(result.text, module) or " "
		local start = #result.text + #space
		result.text = result.text .. space .. module
		table.insert(result.highlights, { o.extra_info_hl, range = { start, #result.text } })
	end
	return result
end

return M
