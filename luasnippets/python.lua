local ls = require("luasnip")
local f = ls.function_node
local ts_postfix = require("luasnip.extras.treesitter_postfix").treesitter_postfix
local matcher = require("luasnip.extras.treesitter_postfix").builtin.tsnode_matcher

-- single expressions: `a + b.str` wraps only `b`
local atom = {
	"call",
	"attribute",
	"subscript",
	"identifier",
	"parenthesized_expression",
	"string",
	"concatenated_string",
	"integer",
	"float",
	"true",
	"false",
	"none",
	"list",
	"tuple",
	"dictionary",
	"set",
	"list_comprehension",
	"dictionary_comprehension",
	"set_comprehension",
	"generator_expression",
}

-- `expr.name` -> `name(expr)`
local function wrap(name)
	return ts_postfix({
		trig = "." .. name,
		name = "." .. name,
		dscr = name .. "(…)",
		matchTSNode = matcher.find_topmost_types(atom),
		reparseBuffer = "live",
	}, {
		f(function(_, parent)
			return name .. "(" .. table.concat(parent.snippet.env.LS_TSMATCH, "\n") .. ")"
		end),
	})
end

local snippets = {}
for _, name in ipairs({
	"str", "repr", "int", "float", "bool", "len", "type", "id", "hash",
	"list", "tuple", "set", "frozenset", "dict",
	"sorted", "reversed", "enumerate", "iter", "next",
	"sum", "min", "max", "abs", "round", "any", "all",
	"print", "vars", "dir", "range",
}) do
	table.insert(snippets, wrap(name))
end

return snippets
