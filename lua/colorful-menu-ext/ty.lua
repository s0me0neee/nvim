local cm = require("colorful-menu")
local utils = require("colorful-menu.utils")
local Kind = cm.Kind

local M = {}

-- commas inside brackets belong to a signature, not to the Overload[...] list
local function split_top_level(s)
	local parts, depth, start = {}, 0, 1
	for i = 1, #s do
		local c = s:sub(i, i)
		if c == "(" or c == "[" or c == "{" then
			depth = depth + 1
		elseif c == ")" or c == "]" or c == "}" then
			depth = depth - 1
		elseif c == "," and depth == 0 then
			table.insert(parts, vim.trim(s:sub(start, i - 1)))
			start = i + 1
		end
	end
	table.insert(parts, vim.trim(s:sub(start)))
	return parts
end

-- ty writes "def f[T](..) -> R", "bound method C.f(..) -> R", "(..) -> R" or "Overload[sig, ...]"
local function signature(desc)
	local overloads = 1
	local inner = desc:match("^Overload%[(.*)%]$")
	if inner then
		local sigs = split_top_level(inner)
		desc, overloads = sigs[1], #sigs
	end
	desc = desc:gsub("^def [^%[(]+", ""):gsub("^bound method [^%[(]+", "")
	if desc:match("^%b[]%b()") or desc:match("^%b()") then
		return desc, overloads
	end
	return nil, overloads
end

---@return CMHighlights
function M.render(item, ls, o)
	local label = item.label
	local kind = item.kind
	local label_only = {
		text = label,
		highlights = { { utils.hl_by_kind(kind, "python"), range = { 0, #label } } },
	}

	-- auto-import candidates carry " (import numpy.ma)" instead of a type
	local import = vim.tbl_get(item, "labelDetails", "detail")
	if import then
		local path = import:match("%(import (.-)%)") or vim.trim(import)
		if o.extra_info_hl == false or path == "" then
			return label_only
		end
		local space = o.align_type_to_right and utils.align_spaces_bell(label, path) or " "
		label_only.text = label .. space .. path
		table.insert(label_only.highlights, { o.extra_info_hl, range = { #label + #space, #label_only.text } })
		return label_only
	end

	local desc = vim.tbl_get(item, "labelDetails", "description") or item.detail
	if
		type(desc) ~= "string"
		or desc:find("\n")
		or kind == Kind.Keyword
		or desc:match("^<class '.*'>$")
		or desc:match("^<module '.*'>$")
	then
		return label_only
	end

	if kind == Kind.Function or kind == Kind.Method or kind == Kind.Constructor then
		local sig, overloads = signature(desc)
		if sig then
			local text = label .. sig
			local result = utils.highlight_range("def " .. text .. ": ...", ls, 4, 4 + #text)
			if overloads > 1 and o.extra_info_hl ~= false then
				local more = overloads == 2 and "(+1 overload)" or string.format("(+%d overloads)", overloads - 1)
				result.text = text .. " " .. more
				table.insert(result.highlights, { o.extra_info_hl, range = { #text + 1, #result.text } })
			end
			return result
		end
	end

	local text = label .. ": " .. desc
	return utils.highlight_range(text, ls, 0, #text)
end

return M
