-- ashfeather
-- Derived from Pictures/wallpaper/78036181_p0.jpg by sampling the image directly.
--
-- THREE CORES ONLY: the blue-black wings (backgrounds), the blue-white hair
-- (cool foregrounds), and the orange harness/rust/glow (the single warm accent).
-- There is deliberately no green: the image contains none, and an earlier build
-- read green because its invented "sage" (#7da8a5) had g=168 > b=165 -- an actual
-- green cast -- as did its diff-add tint (#1b2422, g=36 > b=34).
--
-- Every cool colour here is verified b > g by at least 6/255; every warm colour is
-- verified r > g > b. Diff follows the duotone: additions are COOL, deletions WARM.
--
-- The image's "black" is not one colour: shadow regions measure hue 229deg while
-- the dark/low-mid bands measure 328-332deg (magenta bleed from skin and rust),
-- which is why averaging the whole image yields mud. Restricting to cool pixels
-- (hue 190-270deg, 61% of the image) exposes a spine that is consistent at hue
-- 215-220deg across EVERY luminance, at only 9-15% saturation:
--
--   deepest #15181b   shadow #24272c   dark #3c4048
--   mid     #68717e   light  #a2aab8   milky #dbdee3
--
-- Backgrounds sit on that spine at hue 217. Foregrounds are solved to target
-- contrast ratios against the background: band 5.0:1 - 13.2:1 (2.66x spread).

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "ashfeather"

local c = {
	-- CORE 1: blue-black wings -- hue 218 at 21-26% saturation. The base is lifted
	-- from #0c0f14 so that lightening the foregrounds LOWERS contrast instead of
	-- raising it: on a dark ground, a paler foreground is a higher-contrast one.
	bg_dim = "#141922",
	bg = "#1d242f",
	line = "#242c3a",
	bg_alt = "#2a3342",
	sel = "#374256",
	border = "#46536a",

	-- CORE 2: blue-white hair, moved toward their light variants. Saturation is
	-- held to within ~1 point of the vivid pass -- only lightness moved.
	milk = "#e8ecf3", -- 13.2:1  sat 31%  titles, bold
	fg = "#d7dfe9", -- 11.6:1  sat 29%  body text
	ice = "#b3d0e3", --  9.7:1  sat 46%  types, info, additions
	steel = "#bbc0e4", --  8.8:1  sat 43%  functions, hints
	blue = "#a4bee2", --  8.2:1  sat 52%  keywords, directories
	fg_dim = "#97a6bf", --  6.3:1  sat 24%  comments
	fg_faint = "#8392ac", --  5.0:1  sat 20%  line numbers, borders

	-- CORE 3: orange harness / rust / glow, likewise lightened at fixed saturation.
	-- orange keeps the hand-picked hue 19.7deg and its 91% saturation intact.
	amber = "#ebc4a9", --  9.7:1  sat 62%  pale glow    - strings, warnings
	orange = "#f9aa83", --  8.3:1  sat 91%  harness hue  - numbers, constants
	ember = "#e29072", --  6.3:1  sat 66%  bright rust  - errors, deletions

	-- diff tints: additions cool, deletions warm, all near-background
	add_bg = "#1c2c38",
	chg_bg = "#1d2137",
	del_bg = "#38221c",
	txt_bg = "#25374e",
	none = "NONE",
}

local g = {
	--- editor -----------------------------------------------------------------
	Normal = { fg = c.fg, bg = c.bg },
	NormalNC = { fg = c.fg, bg = c.bg },
	NormalFloat = { fg = c.fg, bg = c.bg_alt },
	FloatBorder = { fg = c.border, bg = c.bg_alt },
	FloatTitle = { fg = c.milk, bg = c.bg_alt, bold = true },
	Cursor = { fg = c.bg, bg = c.fg },
	lCursor = { link = "Cursor" },
	TermCursor = { link = "Cursor" },
	CursorLine = { bg = c.line },
	CursorColumn = { bg = c.line },
	ColorColumn = { bg = c.line },
	CursorLineNr = { fg = c.fg, bold = true },
	LineNr = { fg = c.fg_faint },
	LineNrAbove = { fg = c.fg_faint },
	LineNrBelow = { fg = c.fg_faint },
	SignColumn = { fg = c.fg_faint, bg = c.bg },
	FoldColumn = { fg = c.fg_faint, bg = c.bg },
	Folded = { fg = c.fg_dim, bg = c.bg_alt },
	EndOfBuffer = { fg = c.bg },
	NonText = { fg = c.fg_faint },
	Whitespace = { fg = c.sel },
	SpecialKey = { fg = c.fg_faint },
	Conceal = { fg = c.fg_dim },
	MatchParen = { fg = c.amber, bold = true },
	Visual = { bg = c.sel },
	VisualNOS = { bg = c.sel },
	Search = { fg = c.bg, bg = c.blue },
	IncSearch = { fg = c.bg, bg = c.amber },
	CurSearch = { fg = c.bg, bg = c.amber },
	Substitute = { fg = c.bg, bg = c.ember },
	WinSeparator = { fg = c.border },
	VertSplit = { fg = c.border },
	StatusLine = { fg = c.fg_dim, bg = c.bg_alt },
	StatusLineNC = { fg = c.fg_faint, bg = c.bg_alt },
	WinBar = { fg = c.fg_dim, bg = c.none },
	WinBarNC = { fg = c.fg_faint, bg = c.none },
	TabLine = { fg = c.fg_dim, bg = c.bg_alt },
	TabLineFill = { bg = c.bg_dim },
	TabLineSel = { fg = c.fg, bg = c.sel, bold = true },
	Pmenu = { fg = c.fg_dim, bg = c.bg_alt },
	PmenuSel = { fg = c.fg, bg = c.sel, bold = true },
	PmenuKind = { fg = c.ice, bg = c.bg_alt },
	PmenuKindSel = { fg = c.ice, bg = c.sel },
	PmenuExtra = { fg = c.fg_faint, bg = c.bg_alt },
	PmenuExtraSel = { fg = c.fg_dim, bg = c.sel },
	PmenuSbar = { bg = c.bg_alt },
	PmenuThumb = { bg = c.border },
	WildMenu = { link = "PmenuSel" },
	QuickFixLine = { bg = c.sel, bold = true },
	Directory = { fg = c.blue },
	Title = { fg = c.milk, bold = true },
	Question = { fg = c.ice },
	MoreMsg = { fg = c.ice },
	OkMsg = { fg = c.ice }, -- nvim default is green; overridden to stay in palette
	ModeMsg = { fg = c.fg, bold = true },
	MsgArea = { fg = c.fg },
	MsgSeparator = { fg = c.border },
	ErrorMsg = { fg = c.ember, bold = true },
	WarningMsg = { fg = c.amber },
	Error = { fg = c.ember },
	Todo = { fg = c.bg, bg = c.amber, bold = true },
	Underlined = { underline = true },
	Ignore = { fg = c.fg_faint },
	debugPC = { bg = c.chg_bg },
	debugBreakpoint = { fg = c.ember },

	--- syntax -----------------------------------------------------------------
	Comment = { fg = c.fg_dim },
	Constant = { fg = c.orange },
	String = { fg = c.amber },
	Character = { fg = c.amber },
	Number = { fg = c.orange },
	Boolean = { fg = c.orange },
	Float = { fg = c.orange },
	Identifier = { fg = c.fg },
	Function = { fg = c.steel },
	Statement = { fg = c.blue },
	Conditional = { fg = c.blue },
	Repeat = { fg = c.blue },
	Label = { fg = c.blue },
	Operator = { fg = c.ice },
	Keyword = { fg = c.blue },
	Exception = { fg = c.blue },
	PreProc = { fg = c.ember },
	Include = { fg = c.ember },
	Define = { fg = c.ember },
	Macro = { fg = c.ember },
	PreCondit = { fg = c.ember },
	Type = { fg = c.ice },
	StorageClass = { fg = c.ice },
	Structure = { fg = c.ice },
	Typedef = { fg = c.ice },
	Special = { fg = c.orange },
	SpecialChar = { fg = c.orange },
	Tag = { fg = c.blue },
	Delimiter = { fg = c.fg_dim },
	SpecialComment = { fg = c.fg_dim, bold = true },
	Debug = { fg = c.ember },

	--- diff / spell -----------------------------------------------------------
	DiffAdd = { bg = c.add_bg },
	DiffChange = { bg = c.chg_bg },
	DiffDelete = { bg = c.del_bg },
	DiffText = { bg = c.txt_bg },
	Added = { fg = c.ice },
	Changed = { fg = c.blue },
	Removed = { fg = c.ember },
	SpellBad = { sp = c.ember, undercurl = true },
	SpellCap = { sp = c.amber, undercurl = true },
	SpellLocal = { sp = c.ice, undercurl = true },
	SpellRare = { sp = c.steel, undercurl = true },

	--- diagnostics ------------------------------------------------------------
	DiagnosticError = { fg = c.ember },
	DiagnosticWarn = { fg = c.amber },
	DiagnosticInfo = { fg = c.ice },
	DiagnosticHint = { fg = c.steel },
	DiagnosticOk = { fg = c.ice },
	DiagnosticUnnecessary = { fg = c.fg_faint },
	DiagnosticVirtualTextError = { fg = c.ember, bg = c.del_bg },
	DiagnosticVirtualTextWarn = { fg = c.amber, bg = c.line },
	DiagnosticVirtualTextInfo = { fg = c.ice, bg = c.line },
	DiagnosticVirtualTextHint = { fg = c.steel, bg = c.line },
	DiagnosticVirtualTextOk = { fg = c.ice, bg = c.add_bg },
	DiagnosticUnderlineError = { sp = c.ember, undercurl = true },
	DiagnosticUnderlineWarn = { sp = c.amber, undercurl = true },
	DiagnosticUnderlineInfo = { sp = c.ice, undercurl = true },
	DiagnosticUnderlineHint = { sp = c.steel, undercurl = true },
	DiagnosticUnderlineOk = { sp = c.ice, undercurl = true },

	--- lsp --------------------------------------------------------------------
	LspReferenceText = { bg = c.sel },
	LspReferenceRead = { bg = c.sel },
	LspReferenceWrite = { bg = c.sel, underline = true },
	LspInlayHint = { fg = c.fg_faint, bg = c.line },
	LspCodeLens = { fg = c.fg_faint },
	LspSignatureActiveParameter = { fg = c.amber, bold = true },

	--- treesitter -------------------------------------------------------------
	["@variable"] = { fg = c.fg },
	["@variable.builtin"] = { fg = c.ember },
	["@variable.parameter"] = { fg = c.fg },
	["@variable.member"] = { fg = c.ice },
	["@constant"] = { fg = c.orange },
	["@constant.builtin"] = { fg = c.orange },
	["@constant.macro"] = { fg = c.ember },
	["@module"] = { fg = c.ice },
	["@label"] = { fg = c.blue },
	["@string"] = { fg = c.amber },
	["@string.escape"] = { fg = c.orange },
	["@string.special"] = { fg = c.orange },
	["@string.regexp"] = { fg = c.orange },
	["@character"] = { fg = c.amber },
	["@character.special"] = { fg = c.orange },
	["@number"] = { fg = c.orange },
	["@boolean"] = { fg = c.orange },
	["@float"] = { fg = c.orange },
	["@function"] = { fg = c.steel },
	["@function.builtin"] = { fg = c.steel },
	["@function.call"] = { fg = c.steel },
	["@function.macro"] = { fg = c.ember },
	["@function.method"] = { fg = c.steel },
	["@function.method.call"] = { fg = c.steel },
	["@constructor"] = { fg = c.ice },
	["@operator"] = { fg = c.ice },
	["@keyword"] = { fg = c.blue },
	["@keyword.function"] = { fg = c.blue },
	["@keyword.operator"] = { fg = c.blue },
	["@keyword.return"] = { fg = c.blue },
	["@keyword.import"] = { fg = c.ember },
	["@keyword.exception"] = { fg = c.blue },
	["@keyword.conditional"] = { fg = c.blue },
	["@keyword.repeat"] = { fg = c.blue },
	["@type"] = { fg = c.ice },
	["@type.builtin"] = { fg = c.ice },
	["@type.definition"] = { fg = c.ice },
	["@attribute"] = { fg = c.ember },
	["@property"] = { fg = c.ice },
	["@field"] = { fg = c.ice },
	["@punctuation.delimiter"] = { fg = c.fg_dim },
	["@punctuation.bracket"] = { fg = c.fg_dim },
	["@punctuation.special"] = { fg = c.orange },
	["@comment"] = { fg = c.fg_dim },
	["@comment.todo"] = { fg = c.bg, bg = c.amber, bold = true },
	["@comment.note"] = { fg = c.bg, bg = c.ice, bold = true },
	["@comment.warning"] = { fg = c.bg, bg = c.amber, bold = true },
	["@comment.error"] = { fg = c.bg, bg = c.ember, bold = true },
	["@tag"] = { fg = c.blue },
	["@tag.builtin"] = { fg = c.blue },
	["@tag.attribute"] = { fg = c.steel },
	["@tag.delimiter"] = { fg = c.fg_dim },
	["@markup.heading"] = { fg = c.milk, bold = true },
	["@markup.heading.1"] = { fg = c.milk, bold = true },
	["@markup.heading.2"] = { fg = c.ice, bold = true },
	["@markup.heading.3"] = { fg = c.steel, bold = true },
	["@markup.heading.4"] = { fg = c.blue, bold = true },
	["@markup.strong"] = { fg = c.milk, bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.strikethrough"] = { strikethrough = true },
	["@markup.underline"] = { underline = true },
	["@markup.link"] = { fg = c.blue, underline = true },
	["@markup.link.label"] = { fg = c.ice },
	["@markup.link.url"] = { fg = c.fg_dim, underline = true },
	["@markup.raw"] = { fg = c.amber },
	["@markup.raw.block"] = { fg = c.amber },
	["@markup.list"] = { fg = c.blue },
	["@markup.list.checked"] = { fg = c.ice },
	["@markup.list.unchecked"] = { fg = c.fg_faint },
	["@markup.quote"] = { fg = c.fg_dim, italic = true },
	["@diff.plus"] = { fg = c.ice },
	["@diff.minus"] = { fg = c.ember },
	["@diff.delta"] = { fg = c.blue },

	--- gitsigns ---------------------------------------------------------------
	GitSignsAdd = { fg = c.ice },
	GitSignsChange = { fg = c.blue },
	GitSignsDelete = { fg = c.ember },
	GitSignsAddInline = { bg = c.add_bg },
	GitSignsChangeInline = { bg = c.chg_bg },
	GitSignsDeleteInline = { bg = c.del_bg },
	GitSignsCurrentLineBlame = { fg = c.fg_faint },

	--- telescope --------------------------------------------------------------
	TelescopeNormal = { fg = c.fg_dim, bg = c.bg_alt },
	TelescopeBorder = { fg = c.border, bg = c.bg_alt },
	TelescopeTitle = { fg = c.milk, bold = true },
	TelescopePromptNormal = { fg = c.fg, bg = c.sel },
	TelescopePromptBorder = { fg = c.sel, bg = c.sel },
	TelescopePromptTitle = { fg = c.bg, bg = c.blue, bold = true },
	TelescopePromptPrefix = { fg = c.amber },
	TelescopeResultsTitle = { fg = c.border, bg = c.bg_alt },
	TelescopePreviewTitle = { fg = c.bg, bg = c.ice, bold = true },
	TelescopeSelection = { fg = c.fg, bg = c.sel, bold = true },
	TelescopeSelectionCaret = { fg = c.amber, bg = c.sel },
	TelescopeMatching = { fg = c.amber, bold = true },

	--- snacks -----------------------------------------------------------------
	SnacksNormal = { fg = c.fg, bg = c.bg_alt },
	SnacksBackdrop = { bg = c.bg_dim },
	SnacksBorder = { fg = c.border, bg = c.bg_alt },
	SnacksTitle = { fg = c.milk, bold = true },
	SnacksPickerMatch = { fg = c.amber, bold = true },
	SnacksPickerSelected = { fg = c.fg, bg = c.sel, bold = true },
	SnacksPickerDir = { fg = c.fg_faint },
	SnacksDashboardHeader = { fg = c.steel },
	SnacksDashboardIcon = { fg = c.ice },
	SnacksDashboardDesc = { fg = c.fg_dim },
	SnacksDashboardKey = { fg = c.amber },
	SnacksDashboardFooter = { fg = c.fg_faint },
	SnacksIndent = { fg = c.line },
	SnacksIndentScope = { fg = c.border },
	SnacksNotifierInfo = { fg = c.ice },
	SnacksNotifierWarn = { fg = c.amber },
	SnacksNotifierError = { fg = c.ember },

	--- neo-tree ---------------------------------------------------------------
	NeoTreeNormal = { fg = c.fg_dim, bg = c.bg_dim },
	NeoTreeNormalNC = { fg = c.fg_dim, bg = c.bg_dim },
	NeoTreeWinSeparator = { fg = c.bg_dim, bg = c.bg_dim },
	NeoTreeDirectoryName = { fg = c.blue },
	NeoTreeDirectoryIcon = { fg = c.blue },
	NeoTreeRootName = { fg = c.milk, bold = true },
	NeoTreeFileName = { fg = c.fg_dim },
	NeoTreeFileNameOpened = { fg = c.fg },
	NeoTreeCursorLine = { bg = c.sel },
	NeoTreeIndentMarker = { fg = c.line },
	NeoTreeGitAdded = { fg = c.ice },
	NeoTreeGitModified = { fg = c.blue },
	NeoTreeGitDeleted = { fg = c.ember },
	NeoTreeGitUntracked = { fg = c.fg_faint },
	NeoTreeGitIgnored = { fg = c.fg_faint },

	--- blink.cmp --------------------------------------------------------------
	BlinkCmpMenu = { fg = c.fg_dim, bg = c.bg_alt },
	BlinkCmpMenuBorder = { fg = c.border, bg = c.bg_alt },
	BlinkCmpMenuSelection = { fg = c.fg, bg = c.sel, bold = true },
	BlinkCmpLabel = { fg = c.fg_dim },
	BlinkCmpLabelMatch = { fg = c.amber, bold = true },
	BlinkCmpLabelDeprecated = { fg = c.fg_faint, strikethrough = true },
	BlinkCmpKind = { fg = c.ice },
	BlinkCmpSource = { fg = c.fg_faint },
	BlinkCmpDoc = { fg = c.fg, bg = c.bg_alt },
	BlinkCmpDocBorder = { fg = c.border, bg = c.bg_alt },
	BlinkCmpSignatureHelp = { fg = c.fg, bg = c.bg_alt },
	BlinkCmpGhostText = { fg = c.fg_faint },

	--- which-key / trouble / todo / noice --------------------------------------
	WhichKey = { fg = c.amber },
	WhichKeyGroup = { fg = c.blue },
	WhichKeyDesc = { fg = c.fg },
	WhichKeySeparator = { fg = c.fg_faint },
	WhichKeyFloat = { bg = c.bg_alt },
	WhichKeyBorder = { fg = c.border, bg = c.bg_alt },
	WhichKeyTitle = { fg = c.milk, bold = true },
	TroubleNormal = { fg = c.fg_dim, bg = c.bg_dim },
	TroubleText = { fg = c.fg_dim },
	TroubleCount = { fg = c.amber, bg = c.sel },
	TroubleIndent = { fg = c.line },
	TodoBgTODO = { fg = c.bg, bg = c.ice, bold = true },
	TodoFgTODO = { fg = c.ice },
	TodoSignTODO = { fg = c.ice },
	TodoBgFIX = { fg = c.bg, bg = c.ember, bold = true },
	TodoFgFIX = { fg = c.ember },
	TodoSignFIX = { fg = c.ember },
	TodoBgWARN = { fg = c.bg, bg = c.amber, bold = true },
	TodoFgWARN = { fg = c.amber },
	TodoSignWARN = { fg = c.amber },
	TodoBgNOTE = { fg = c.bg, bg = c.steel, bold = true },
	TodoFgNOTE = { fg = c.steel },
	TodoSignNOTE = { fg = c.steel },
	NoiceCmdlinePopupBorder = { fg = c.border },
	NoiceCmdlineIcon = { fg = c.amber },
	NoiceConfirmBorder = { fg = c.border },

	--- misc plugins -----------------------------------------------------------
	IblIndent = { fg = c.line },
	IblScope = { fg = c.border },
	FlashLabel = { fg = c.bg, bg = c.amber, bold = true },
	FlashMatch = { fg = c.fg, bg = c.sel },
	FlashCurrent = { fg = c.bg, bg = c.blue },
	BufferLineFill = { bg = c.bg_dim },
	LazyNormal = { fg = c.fg, bg = c.bg_alt },
	MasonNormal = { fg = c.fg, bg = c.bg_alt },
	RenderMarkdownCode = { bg = c.line },
	RenderMarkdownCodeInline = { fg = c.amber, bg = c.line },
	RenderMarkdownBullet = { fg = c.blue },
	RenderMarkdownH1Bg = { fg = c.milk, bg = c.sel, bold = true },
	RenderMarkdownH2Bg = { fg = c.ice, bg = c.line },
	RenderMarkdownH3Bg = { fg = c.steel, bg = c.line },
	GrugFarResultsMatch = { fg = c.amber, bold = true },
	GrugFarResultsPath = { fg = c.blue },
}

for name, val in pairs(g) do
	vim.api.nvim_set_hl(0, name, val)
end

-- terminal palette
vim.g.terminal_color_0 = c.sel
vim.g.terminal_color_8 = c.fg_faint
vim.g.terminal_color_1 = c.ember
vim.g.terminal_color_9 = c.ember
vim.g.terminal_color_2 = c.ice
vim.g.terminal_color_10 = c.ice
vim.g.terminal_color_3 = c.amber
vim.g.terminal_color_11 = c.amber
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_5 = c.steel
vim.g.terminal_color_13 = c.steel
vim.g.terminal_color_6 = c.ice
vim.g.terminal_color_14 = c.ice
vim.g.terminal_color_7 = c.fg
vim.g.terminal_color_15 = c.milk
