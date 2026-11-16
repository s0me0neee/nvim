-- Per-token color gradients in the style of Woodfish Theme, derived from the active colorscheme.
-- Port of woodfishhhh/Woodfish-Theme packages/theme-core/src/gradient/tokenGradient.ts
local api = vim.api

local M = {}

local config = {
	hue_shift = 40, -- degrees the gradient end turns past the token's own hue (Woodfish: 32)
	lightness_delta = 0.12, -- largest OKLCH lightness change of a derived stop
	neutral_chroma = 0.075, -- chroma of the rainbow on uncolored text
	anchor_hue = nil, -- hue given to grey text; nil derives it from the colors in use
	-- "theme": one hue per colorscheme; "buffer": each file's own dominant token hue (Woodfish), which varies a lot
	anchor_scope = "theme",
	cache = true, -- reuse each line's gradient until its text or highlights change
	body = "tint", -- uncolored text: "tint" (shared gradient in the anchor hue) or "rainbow" (Woodfish)
	body_chroma = 0.12, -- how strongly "tint" colors uncolored text
	angle = 45, -- CSS gradient angle Woodfish paints each token with
	cell_aspect = 2.2, -- cell height / width; a tilted gradient crosses short words only partly
	steps = 8, -- distinct colors in a two-stop gradient
	rainbow_steps = 36,
	-- plain text shares one diagonal rainbow across the screen, so short words don't flip hue per letter
	rainbow_period = 64, -- columns per full hue cycle
	priority = 126, -- just above LSP semantic tokens (125), below diagnostics
	max_line_bytes = 1000,
	exclude_buftypes = { terminal = true, prompt = true, quickfix = true },
	exclude_filetypes = {},
	-- namespaces whose lasting extmarks carry syntax colors (LSP tokens, blink docs, noice hover/signature)
	mark_namespaces = { "^nvim%.lsp%.semantic_tokens", "^blink_cmp$", "^noice$" },
}

local NEUTRAL_CHROMA = 0.045
local DIM_CONTRAST = 3
local READABLE_CONTRAST = 4.5
local END_VIVIDNESS = 0.85
local DIM_VIVIDNESS = 0.3
local END_LIGHTNESS_PULL = 0.5
local RAINBOW_LIGHTNESS_PULL = 0.7
local RAINBOW_STOP_COUNT = 9
local PASTEL_EDGE_STEP = 0.005
local JEWEL_CHROMA_FACTOR = 2

local ns = api.nvim_create_namespace("word_gradient")
local enabled = true

-- Color math -----------------------------------------------------------------

local function clamp(x, lo, hi)
	return math.max(lo or 0, math.min(hi or 1, x))
end

local function cbrt(x)
	return x < 0 and -((-x) ^ (1 / 3)) or x ^ (1 / 3)
end

local function to_linear(c)
	c = c / 255
	return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

local function to_srgb(c)
	return 255 * (c <= 0.0031308 and c * 12.92 or 1.055 * c ^ (1 / 2.4) - 0.055)
end

local function rgb_to_oklab(rgb)
	local r, g, b = to_linear(rgb[1]), to_linear(rgb[2]), to_linear(rgb[3])
	local l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
	local m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
	local s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
	return 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s
end

local function oklab_to_rgb(L, a, b)
	local l = (L + 0.3963377774 * a + 0.2158037573 * b) ^ 3
	local m = (L - 0.1055613458 * a - 0.0638541728 * b) ^ 3
	local s = (L - 0.0894841775 * a - 1.291485548 * b) ^ 3
	return {
		to_srgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
		to_srgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
		to_srgb(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s),
	}
end

local function rgb_to_oklch(rgb)
	local L, a, b = rgb_to_oklab(rgb)
	return { l = L, c = math.sqrt(a * a + b * b), h = math.deg(math.atan2(b, a)) }
end

local function oklch_to_rgb(c)
	local h = math.rad(c.h)
	return oklab_to_rgb(c.l, c.c * math.cos(h), c.c * math.sin(h))
end

local function in_gamut(rgb)
	for i = 1, 3 do
		local v = rgb[i]
		if v ~= v or v < -1e-6 or v > 255 + 1e-6 then
			return false
		end
	end
	return true
end

local function max_chroma(l, h)
	if l <= 0 or l >= 1 then
		return 0
	end
	local lo, hi = 0, 0.4
	for _ = 1, 18 do
		local mid = (lo + hi) / 2
		if in_gamut(oklch_to_rgb({ l = l, c = mid, h = h })) then
			lo = mid
		else
			hi = mid
		end
	end
	return lo
end

local cusp_cache = {}
local function cusp_lightness(h)
	local key = math.floor((h % 360) * 2 + 0.5) / 2
	if not cusp_cache[key] then
		local best_l, best_c = 0.5, 0
		for i = 1, 47 do
			local c = max_chroma(i / 48, key)
			if c > best_c then
				best_l, best_c = i / 48, c
			end
		end
		cusp_cache[key] = best_l
	end
	return cusp_cache[key]
end

local function gamut_map(c)
	local rgb = oklch_to_rgb(c)
	if in_gamut(rgb) then
		return rgb
	end
	local lo, hi = 0, c.c
	for _ = 1, 20 do
		local mid = (lo + hi) / 2
		if in_gamut(oklch_to_rgb({ l = c.l, c = mid, h = c.h })) then
			lo = mid
		else
			hi = mid
		end
	end
	return oklch_to_rgb({ l = c.l, c = lo, h = c.h })
end

local function luminance(rgb)
	return 0.2126 * to_linear(rgb[1]) + 0.7152 * to_linear(rgb[2]) + 0.0722 * to_linear(rgb[3])
end

local function contrast(x, y)
	local a, b = luminance(x), luminance(y)
	return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

local function int_to_rgb(n)
	return { math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256 }
end

local function to_hex(rgb)
	return string.format(
		"#%02x%02x%02x",
		clamp(math.floor(rgb[1] + 0.5), 0, 255),
		clamp(math.floor(rgb[2] + 0.5), 0, 255),
		clamp(math.floor(rgb[3] + 0.5), 0, 255)
	)
end

-- Gradient derivation (mirrors tokenGradient.ts) -----------------------------

local theme = {} -- fg (int?) and bg (rgb) of Normal, captured on ColorScheme

local function limit(x, bound)
	return clamp(x, -bound, bound)
end

local function readable(c, read)
	local rgb = gamut_map(c)
	if not read then
		return rgb
	end
	local l = c.l
	for _ = 1, 60 do
		if contrast(rgb, read.bg) >= read.min then
			break
		end
		l = clamp(l + read.dir * 0.01)
		rgb = gamut_map({ l = l, c = c.c, h = c.h })
	end
	return rgb
end

local function chromatic_stops(base, punct, dim)
	local turn = (dim or punct) and config.hue_shift / 2 or config.hue_shift
	local h = base.h + turn
	local l = dim and base.l
		or clamp(base.l + limit((cusp_lightness(h) - base.l) * END_LIGHTNESS_PULL, config.lightness_delta))
	local headroom = max_chroma(l, h)
	local c = math.max(base.c, base.c + (headroom - base.c) * (dim and DIM_VIVIDNESS or END_VIVIDNESS))
	return { base, { l = l, c = c, h = h } }
end

local function pastel_edge(h, chroma, dir)
	local l = dir > 0 and 1 - PASTEL_EDGE_STEP or PASTEL_EDGE_STEP
	while l > 0 and l < 1 and max_chroma(l, h) < chroma do
		l = l - dir * PASTEL_EDGE_STEP
	end
	return clamp(l)
end

local function rainbow_stops(base, dir, anchor)
	local stops = {}
	for i = 0, RAINBOW_STOP_COUNT - 1 do
		local h = anchor + 360 * i / (RAINBOW_STOP_COUNT - 1)
		local l
		local c = config.neutral_chroma
		if dir < 0 then
			l = clamp(base.l + config.lightness_delta)
			c = c * JEWEL_CHROMA_FACTOR
		else
			local edge = pastel_edge(h, c, dir)
			local room = (edge - base.l) * dir
			local offset = room > 0 and room * RAINBOW_LIGHTNESS_PULL * dir or edge - base.l
			l = clamp(base.l + limit(offset, config.lightness_delta))
		end
		stops[#stops + 1] = { l = l, c = math.min(c, max_chroma(l, h)), h = h }
	end
	return stops
end

local function muted_stops(base, punct, anchor)
	return {
		base,
		{
			l = base.l,
			c = math.max(base.c, config.neutral_chroma / 2),
			h = anchor + (punct and 0 or config.hue_shift / 2),
		},
	}
end

-- Every uncolored word shares one gradient around the anchor hue, soft tint into vivid.
local function body_stops(base, anchor)
	local h1 = anchor - config.hue_shift / 2
	local h2 = anchor + config.hue_shift / 2
	local l2 = clamp(base.l + limit((cusp_lightness(h2) - base.l) * END_LIGHTNESS_PULL, config.lightness_delta))
	return {
		{ l = base.l, c = math.min(config.body_chroma * 0.35, max_chroma(base.l, h1)), h = h1 },
		{ l = l2, c = math.min(config.body_chroma, max_chroma(l2, h2)), h = h2 },
	}
end

local function derive(fg, punct, anchor)
	local src = int_to_rgb(fg)
	local base = rgb_to_oklch(src)
	local read = theme.bg
		and {
			bg = theme.bg,
			min = math.min(READABLE_CONTRAST, contrast(src, theme.bg)),
			dir = rgb_to_oklch(theme.bg).l < 0.5 and 1 or -1,
		}
	local stops
	if base.c >= NEUTRAL_CHROMA then
		stops = chromatic_stops(base, punct, read and contrast(src, read.bg) < DIM_CONTRAST)
	elseif not punct and (theme.fg and fg == theme.fg or not theme.fg and (base.l >= 0.7 or base.l <= 0.4)) then
		stops = config.body == "rainbow"
				and rainbow_stops(base, read and read.dir or (base.l >= 0.5 and 1 or -1), anchor)
			or body_stops(base, anchor)
	else
		stops = muted_stops(base, punct, anchor)
	end
	local rgbs = {}
	for i, s in ipairs(stops) do
		rgbs[i] = s == base and src or readable(s, read)
	end
	return rgbs
end

-- Highlight groups -------------------------------------------------------------

local gradients = {} -- "<fg>[:p][:<anchor>]" -> list of hl group names
local fg_cache = {} -- hl group name -> fg int, or false when it sets no fg
local oklch_cache = {} -- fg int -> oklch

local function oklch_of(fg)
	local c = oklch_cache[fg]
	if not c then
		c = rgb_to_oklch(int_to_rgb(fg))
		oklch_cache[fg] = c
	end
	return c
end

local function sample(rgbs, t)
	local seg = t * (#rgbs - 1)
	local i = math.min(math.floor(seg), #rgbs - 2)
	local f = seg - i
	local L1, a1, b1 = rgb_to_oklab(rgbs[i + 1])
	local L2, a2, b2 = rgb_to_oklab(rgbs[i + 2])
	return oklab_to_rgb(L1 + (L2 - L1) * f, a1 + (a2 - a1) * f, b1 + (b2 - b1) * f)
end

local function gradient(fg, punct, anchor)
	local key = fg .. (punct and ":p" or "")
	-- only grey colors borrow the anchor hue
	if oklch_of(fg).c < NEUTRAL_CHROMA then
		key = key .. ":" .. math.floor(anchor + 0.5)
	end
	local groups = gradients[key]
	if groups then
		return groups
	end
	local rgbs = derive(fg, punct, anchor)
	local n = #rgbs == 2 and config.steps or config.rainbow_steps
	groups = { rainbow = #rgbs > 2 }
	for i = 0, n - 1 do
		local hex = to_hex(sample(rgbs, (i + 0.5) / n))
		local name = "WordGradient_" .. hex:sub(2)
		api.nvim_set_hl(0, name, { fg = hex })
		groups[#groups + 1] = name
	end
	gradients[key] = groups
	return groups
end

local function fg_of(name)
	local v = fg_cache[name]
	if v ~= nil then
		return v
	end
	local probe = name
	while true do
		local hl = api.nvim_get_hl(0, { name = probe, link = false, create = false })
		if next(hl) then
			v = hl.fg or false
			break
		end
		-- undefined "@a.b.lang" falls back to "@a.b", like the treesitter highlighter
		local parent = probe:match("^(.+)%.[^.]+$")
		if not parent then
			v = false
			break
		end
		probe = parent
	end
	fg_cache[name] = v
	return v
end

-- Woodfish ranks on-screen token colors; these groups stand in for "what code mostly looks like".
local PALETTE_GROUPS = {
	"@keyword",
	"@keyword.function",
	"@keyword.return",
	"@keyword.import",
	"@keyword.conditional",
	"@function",
	"@function.call",
	"@function.method.call",
	"@function.builtin",
	"@constructor",
	"@type",
	"@type.builtin",
	"@string",
	"@number",
	"@boolean",
	"@constant",
	"@constant.builtin",
	"@variable.member",
	"@property",
	"@variable.parameter",
	"@variable.builtin",
	"@operator",
	"@module",
}
local ACCENT_GROUPS = { "Function", "Keyword", "Special", "Title", "Directory", "CursorLineNr", "Statement", "Type" }
local DEFAULT_ANCHOR_HUE = 300

-- Hue of the color used most (weighted by vividness) across the theme's syntax groups.
local function theme_anchor_hue()
	if config.anchor_hue then
		return config.anchor_hue
	end
	local scores, best = {}, nil
	for _, group in ipairs(PALETTE_GROUPS) do
		local fg = fg_of(group)
		local c = fg and rgb_to_oklch(int_to_rgb(fg))
		if c and c.c >= 0.075 and c.l >= 0.4 then
			local entry = scores[fg] or { h = c.h, score = 0 }
			entry.score = entry.score + c.c
			scores[fg] = entry
			if not best or entry.score > best.score then
				best = entry
			end
		end
	end
	if best then
		return best.h
	end
	-- near-monochrome themes: borrow the most saturated UI accent
	local accent
	for _, group in ipairs(ACCENT_GROUPS) do
		local fg = fg_of(group)
		local c = fg and rgb_to_oklch(int_to_rgb(fg))
		if c and c.c >= NEUTRAL_CHROMA and (not accent or c.c > accent.c) then
			accent = c
		end
	end
	return accent and accent.h or DEFAULT_ANCHOR_HUE
end

local buffers = {} -- buf -> { tick, rows = { [row] = flat marks }, count, anchor, tries, drawn_anchor }

local function snapshot()
	gradients, fg_cache, buffers = {}, {}, {}
	local normal = api.nvim_get_hl(0, { name = "Normal", link = false })
	theme.fg = normal.fg
	-- a transparent Normal has no bg; assume the terminal's black or white
	theme.bg = int_to_rgb(normal.bg or (vim.o.background == "light" and 0xffffff or 0))
	theme.anchor = theme_anchor_hue()
end

function M.anchor_hue(buf)
	local st = buf and buffers[buf]
	return st and st.anchor or theme.anchor
end

-- Decoration provider ---------------------------------------------------------

local mark_namespaces = {}

local function refresh_mark_namespaces()
	mark_namespaces = {}
	for name, id in pairs(api.nvim_get_namespaces()) do
		for _, pattern in ipairs(config.mark_namespaces) do
			if name:find(pattern) then
				mark_namespaces[#mark_namespaces + 1] = id
				break
			end
		end
	end
end

local function has_marks(buf)
	for _, id in ipairs(mark_namespaces) do
		if #api.nvim_buf_get_extmarks(buf, id, 0, -1, { limit = 1 }) > 0 then
			return true
		end
	end
	return false
end

local BLINK_MENU = "blink-cmp-menu"
local BLINK_PRIORITY = 4097 -- blink's menu highlights use the extmark default, 4096

local function blink_renderer(buf)
	local menu = vim.bo[buf].filetype == BLINK_MENU and package.loaded["blink.cmp.completion.windows.menu"]
	return menu and menu.renderer and menu.renderer.bufnr == buf and menu.renderer or nil
end

local function eligible(buf)
	if enabled and blink_renderer(buf) then
		return true
	end
	return enabled
		and vim.b[buf].word_gradient ~= false
		and not config.exclude_buftypes[vim.bo[buf].buftype]
		and not vim.tbl_contains(config.exclude_filetypes, vim.bo[buf].filetype)
		and (vim.treesitter.highlighter.active[buf] ~= nil or has_marks(buf))
end

-- Fills per-byte winning fg, source id and punctuation flag for one line.
local function resolve_line(buf, row, len)
	local fg, pri, src, kind = {}, {}, {}, {}
	local next_src = 0

	local function paint(s, e, color, p, k)
		next_src = next_src + 1
		for b = s + 1, e do
			if not pri[b] or p >= pri[b] then
				fg[b], pri[b], src[b], kind[b] = color, p, next_src, k
			end
		end
	end

	local function clip(sr, sc, er, ec)
		if sr > row or er < row then
			return nil
		end
		local s = sr < row and 0 or sc
		local e = er > row and len or math.min(ec, len)
		if e <= s then
			return nil
		end
		return s, e
	end

	local renderer = blink_renderer(buf)
	if renderer then
		-- blink's highlights are ephemeral, so rebuild them the way its renderer's on_line does
		local offset = renderer.padding[1]
		for _, column in ipairs(renderer.columns or {}) do
			local text = column:get_line_text(row + 1)
			if #text > 0 then
				for _, h in ipairs(column:get_line_highlights(row + 1)) do
					local color = h.group and fg_of(h.group)
					local s, e = clip(row, offset + h[1], row, offset + h[2])
					if color and s then
						paint(s, e, color, h.priority or 4096, h.group:match("^@comment") and "comment")
					end
				end
				offset = offset + #text + renderer.gap
			end
		end
		return fg, src, kind
	end

	-- the highlighter's own tree: previews like snacks start treesitter with a lang unrelated to filetype
	local highlighter = vim.treesitter.highlighter.active[buf]
	local parser = highlighter and highlighter.tree
	if parser then
		parser:for_each_tree(function(tstree, ltree)
			local lang = ltree:lang()
			local query = vim.treesitter.query.get(lang, "highlights")
			if not query then
				return
			end
			local root = tstree:root()
			local rsr, _, rer = root:range()
			if row < rsr or row > rer then
				return
			end
			for id, node, metadata in query:iter_captures(root, buf, row, row + 1) do
				local name = query.captures[id]
				if name:sub(1, 1) ~= "_" and name ~= "spell" and name ~= "nospell" and name ~= "conceal" then
					local color = fg_of("@" .. name .. "." .. lang)
					if color then
						local r = vim.treesitter.get_range(node, buf, metadata[id])
						local s, e = clip(r[1], r[2], r[4], r[5])
						if s then
							local p = tonumber(metadata.priority or metadata[id] and metadata[id].priority)
								or vim.hl.priorities.treesitter
							paint(s, e, color, p, name:match("^punctuation") or name:match("^comment"))
						end
					end
				end
			end
		end)
	end

	for _, mns in ipairs(mark_namespaces) do
		local marks = api.nvim_buf_get_extmarks(buf, mns, { row, 0 }, { row, -1 }, { details = true, overlap = true })
		for _, m in ipairs(marks) do
			local d = m[4]
			local color = d.hl_group and fg_of(d.hl_group)
			if color then
				local s, e = clip(m[2], m[3], d.end_row or m[2], d.end_col or m[3])
				if s then
					local g = d.hl_group
					local k = (g:match("^@comment") or g:match("^@lsp%.type%.comment")) and "comment"
						or g:match("^@punctuation") and "punctuation"
					paint(s, e, color, d.priority or vim.hl.priorities.semantic_tokens, k)
				end
			end
		end
	end

	return fg, src, kind
end

local function is_space(byte)
	return byte == 32 or byte == 9
end

-- Display column of every character start, for the screen-anchored rainbow.
local function display_cols(line, tabstop)
	local cols, col = {}, 0
	for b = 1, #line do
		local byte = line:byte(b)
		if byte < 0x80 or byte >= 0xC0 then
			cols[b - 1] = col
			col = byte == 9 and (math.floor(col / tabstop) + 1) * tabstop or col + 1
		end
	end
	return cols
end

-- Appends { col, end_col, hl_group } triples for one token to `out`.
local function add_run(out, row, line, s, e, color, is_punct, cols, anchor)
	while s < e and is_space(line:byte(s + 1)) do
		s = s + 1
	end
	while e > s and is_space(line:byte(e)) do
		e = e - 1
	end
	local starts = {}
	for b = s, e - 1 do
		local byte = line:byte(b + 1)
		if byte < 0x80 or byte >= 0xC0 then
			starts[#starts + 1] = b
		end
	end
	local m = #starts
	if m == 0 then
		return
	end
	local groups = gradient(color, is_punct, anchor)
	local k = #groups
	-- where a CSS linear-gradient(angle) over the token's box crosses each glyph's center
	local a = math.rad(config.angle)
	local span = m * math.abs(math.sin(a)) + config.cell_aspect * math.abs(math.cos(a))
	local function stop(j)
		if groups.rainbow then
			-- moving down a row shifts the band left by one cell height, a 45° sweep
			local t = (cols[starts[j + 1]] + 0.5 - row * config.cell_aspect) / config.rainbow_period
			return math.floor((t % 1) * k) % k + 1
		end
		local t = 0.5 + (j + 0.5 - m / 2) * math.sin(a) / span
		return clamp(math.floor(t * k) + 1, 1, k)
	end
	local j = 0
	while j < m do
		local idx = stop(j)
		local j2 = j
		while j2 + 1 < m and stop(j2 + 1) == idx do
			j2 = j2 + 1
		end
		local n = #out
		out[n + 1], out[n + 2], out[n + 3] = starts[j + 1], j2 + 1 < m and starts[j2 + 2] or e, groups[idx]
		j = j2 + 1
	end
end

local NO_MARKS = {}

local function compute_line(buf, row, anchor)
	local line = api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
	local len = line and #line or 0
	if len == 0 or len > config.max_line_bytes then
		return NO_MARKS
	end
	local fg, src, kind = resolve_line(buf, row, len)
	local cols = config.body == "rainbow" and display_cols(line, vim.bo[buf].tabstop)
	local out = {}
	local run_start = 0
	for b = 1, len + 1 do
		-- uncolored text forms one run per stretch, so plain prose gets one gradient
		if b > len or src[b] ~= src[run_start + 1] then
			local color = fg[run_start + 1] or theme.fg
			local k = kind[run_start + 1]
			if color and k ~= "comment" then
				add_run(out, row, line, run_start, b - 1, color, k == "punctuation", cols, anchor)
			end
			run_start = b - 1
		end
	end
	return out
end

-- Per-buffer state ------------------------------------------------------------

local MAX_CACHED_ROWS = 4000
local ANCHOR_SAMPLE_LINES = 150
local ANCHOR_MIN_TOKENS = 12
local ANCHOR_MAX_TRIES = 20

local function buf_state(buf)
	local st = buffers[buf]
	if not st then
		st = { rows = {}, count = 0, tries = 0 }
		buffers[buf] = st
	end
	local tick = api.nvim_buf_get_changedtick(buf)
	if st.tick ~= tick then
		st.tick, st.rows, st.count = tick, {}, 0
	end
	return st
end

local function invalidate(buf, first, last)
	local st = buffers[buf]
	if not st then
		return
	end
	if first then
		for row = first, last or first do
			st.rows[row] = nil
		end
	else
		st.rows, st.count = {}, 0
	end
end

local hooked = setmetatable({}, { __mode = "k" })

-- a parse can land after the text was drawn (async, injections), changing colors without a new changedtick
local function hook_parser(buf, parser)
	if not hooked[parser] then
		hooked[parser] = true
		parser:register_cbs({
			on_changedtree = function()
				invalidate(buf)
			end,
		}, true)
	end
end

-- Hue of the file's most used vivid token color (count x chroma), as Woodfish ranks what is on screen.
local function sample_anchor(buf)
	local last = math.min(api.nvim_buf_line_count(buf), ANCHOR_SAMPLE_LINES)
	local lines = api.nvim_buf_get_lines(buf, 0, last, false)
	local scores, best, tokens = {}, nil, 0
	for row = 0, last - 1 do
		local len = #lines[row + 1]
		if len > 0 and len <= config.max_line_bytes then
			local fg, src, kind = resolve_line(buf, row, len)
			local prev
			for b = 1, len do
				local s = src[b]
				if s and s ~= prev and not kind[b] then
					tokens = tokens + 1
					local c = oklch_of(fg[b])
					if c.c >= 0.075 and c.l >= 0.4 then
						local entry = scores[fg[b]] or { h = c.h, score = 0 }
						entry.score = entry.score + c.c
						scores[fg[b]] = entry
						if not best or entry.score > best.score then
							best = entry
						end
					end
				end
				prev = s
			end
		end
	end
	return best and best.h, tokens
end

local function buffer_anchor(buf, st)
	if st.anchor then
		return st.anchor
	end
	if config.anchor_hue or config.anchor_scope ~= "buffer" then
		st.anchor = theme.anchor
		return st.anchor
	end
	st.tries = st.tries + 1
	local hue, tokens = sample_anchor(buf)
	-- before treesitter has parsed there are no tokens at all, so retry for a few redraws; grey themes settle at once
	if tokens >= ANCHOR_MIN_TOKENS or st.tries >= ANCHOR_MAX_TRIES then
		st.anchor = hue or theme.anchor
		return st.anchor
	end
	return theme.anchor
end

local frame = {} -- what on_win decided for the window whose lines are being drawn

local function on_win(_, _, buf)
	refresh_mark_namespaces()
	frame.buf = nil
	if not eligible(buf) then
		return false
	end
	local highlighter = vim.treesitter.highlighter.active[buf]
	local blink = blink_renderer(buf)
	frame.buf = buf
	frame.priority = blink and BLINK_PRIORITY or config.priority
	if highlighter and not blink then
		hook_parser(buf, highlighter.tree)
		local st = buf_state(buf)
		local anchor = buffer_anchor(buf, st)
		if st.drawn_anchor ~= anchor then
			-- lines drawn with the old hue may not be part of this redraw
			if st.drawn_anchor then
				vim.schedule(function()
					if api.nvim_buf_is_valid(buf) then
						api.nvim__redraw({ buf = buf, valid = false })
					end
				end)
			end
			st.drawn_anchor, st.rows, st.count = anchor, {}, 0
		end
		frame.st, frame.anchor = config.cache and st or nil, anchor
	else
		-- floats (hover, completion) follow the file they belong to
		frame.st, frame.anchor = nil, M.anchor_hue(api.nvim_get_current_buf())
	end
end

local function on_line(_, _, buf, row)
	if frame.buf ~= buf then
		return
	end
	local st = frame.st
	local marks = st and st.rows[row]
	if not marks then
		marks = compute_line(buf, row, frame.anchor)
		if st then
			if st.count >= MAX_CACHED_ROWS then
				st.rows, st.count = {}, 0
			end
			st.rows[row], st.count = marks, st.count + 1
		end
	end
	for i = 1, #marks, 3 do
		api.nvim_buf_set_extmark(buf, ns, row, marks[i], {
			end_col = marks[i + 1],
			hl_group = marks[i + 2],
			ephemeral = true,
			priority = frame.priority,
			strict = false,
		})
	end
end

function M.enable(state)
	enabled = state
	vim.cmd("redraw!")
end

function M.is_enabled()
	return enabled
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	snapshot()
	local group = api.nvim_create_augroup("word_gradient", { clear = true })
	api.nvim_create_autocmd("ColorScheme", { group = group, callback = snapshot })
	-- semantic tokens recolor a line without touching its text
	api.nvim_create_autocmd("LspTokenUpdate", {
		group = group,
		callback = function(ev)
			local token = ev.data.token
			invalidate(ev.buf, token.line, token.end_line)
		end,
	})
	api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(ev)
			invalidate(ev.buf)
		end,
	})
	api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(ev)
			buffers[ev.buf] = nil
		end,
	})
	api.nvim_set_decoration_provider(ns, { on_win = on_win, on_line = on_line })
	api.nvim_create_user_command("WordGradient", function(args)
		local arg = args.args
		M.enable(arg == "on" or (arg ~= "off" and not enabled))
	end, {
		nargs = "?",
		complete = function()
			return { "on", "off", "toggle" }
		end,
	})
	if _G.Snacks then
		Snacks.toggle.new({ name = "Word Gradient", get = M.is_enabled, set = M.enable }):map("<leader>uW")
	end
end

return M
