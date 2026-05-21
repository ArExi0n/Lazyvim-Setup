local M = {}

function M.apply()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local bg = normal.bg or 0
	local fg = normal.fg or 0xffffff

	local function hi(group, opts)
		opts = opts or {}
		if opts.fg == nil then
			opts.fg = fg
		end
		if opts.bg == nil then
			opts.bg = "NONE"
		end
		vim.api.nvim_set_hl(0, group, opts)
	end

	local function mix(a, b, t)
		local r1 = bit.rshift(bit.band(a, 0xFF0000), 16)
		local g1 = bit.rshift(bit.band(a, 0x00FF00), 8)
		local b1 = bit.band(a, 0x0000FF)
		local r2 = bit.rshift(bit.band(b, 0xFF0000), 16)
		local g2 = bit.rshift(bit.band(b, 0x00FF00), 8)
		local b2 = bit.band(b, 0x0000FF)
		return bit.bor(
			bit.lshift(math.floor(r1 + (r2 - r1) * t), 16),
			bit.lshift(math.floor(g1 + (g2 - g1) * t), 8),
			math.floor(b1 + (b2 - b1) * t)
		)
	end

	local cursor_bg = mix(bg, fg, 0.04)
	local visual_bg = mix(bg, fg, 0.12)
	local select_bg = mix(bg, fg, 0.20)
	local float_bg = mix(bg, fg, 0.05)
	local popup_bg = mix(bg, fg, 0.08)

	-- Core UI — transparent
	hi("Normal")
	hi("NormalNC")
	hi("NormalFloat")
	hi("EndOfBuffer")

	-- Cursor / Line
	hi("CursorLine", { bg = cursor_bg })
	hi("CursorColumn", { bg = cursor_bg })
	hi("Cursor", { bg = mix(bg, fg, 0.5), fg = mix(fg, bg, 0.5) })
	hi("lCursor", { bg = mix(bg, fg, 0.5), fg = mix(fg, bg, 0.5) })
	hi("CursorLineNr")
	hi("LineNr")
	hi("LineNrAbove")
	hi("LineNrBelow")

	-- Selection / Search
	hi("Visual", { bg = visual_bg })
	hi("VisualNOS", { bg = visual_bg })
	hi("Search", { fg = fg, bg = mix(bg, fg, 0.3) })
	hi("IncSearch", { fg = bg, bg = fg })
	hi("CurSearch", { fg = bg, bg = fg })
	hi("Substitute", { bg = select_bg })
	hi("MatchParen", { bold = true })
	hi("QuickFixLine", { bg = visual_bg })

	-- Popup menu
	hi("Pmenu", { bg = popup_bg })
	hi("PmenuSel", { bg = select_bg })
	hi("PmenuSbar", { bg = visual_bg })
	hi("PmenuThumb", { bg = popup_bg })

	-- Tabs / Status / Separators
	hi("TabLine", { bg = popup_bg })
	hi("TabLineSel", { bg = cursor_bg })
	hi("TabLineFill")
	hi("StatusLine", { bg = cursor_bg })
	hi("StatusLineNC")
	hi("WinSeparator")
	hi("VertSplit")

	-- Float / Border
	hi("FloatBorder")
	hi("FloatTitle")

	-- Signs / Fold / Columns
	hi("SignColumn")
	hi("Folded")
	hi("FoldColumn")
	hi("ColorColumn", { bg = cursor_bg })
	hi("SpecialKey")
	hi("NonText")
	hi("Whitespace")
	hi("Conceal")

	-- Messages
	hi("ModeMsg")
	hi("MsgArea")
	hi("MsgSeparator")
	hi("MoreMsg")
	hi("WarningMsg")
	hi("ErrorMsg")

	-- Diff (background only)
	hi("DiffAdd", { bg = cursor_bg })
	hi("DiffChange", { bg = visual_bg })
	hi("DiffDelete", { bg = popup_bg })
	hi("DiffText", { bg = select_bg })

	-- Spell
	hi("SpellBad", { sp = mix(bg, fg, 0.5), undercurl = true })
	hi("SpellCap", { sp = mix(bg, fg, 0.5), undercurl = true })
	hi("SpellLocal", { sp = mix(bg, fg, 0.5), undercurl = true })
	hi("SpellRare", { sp = mix(bg, fg, 0.5), undercurl = true })

	-- Diagnostics — all flat fg, no colors
	local diagnostic_groups = {
		"DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint",
		"DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint",
		"DiagnosticVirtualTextError", "DiagnosticVirtualTextWarn",
		"DiagnosticVirtualTextInfo", "DiagnosticVirtualTextHint",
		"DiagnosticFloatingError", "DiagnosticFloatingWarn",
		"DiagnosticFloatingInfo", "DiagnosticFloatingHint",
		"DiagnosticUnderlineError", "DiagnosticUnderlineWarn",
		"DiagnosticUnderlineInfo", "DiagnosticUnderlineHint",
	}
	for _, group in ipairs(diagnostic_groups) do
		hi(group)
	end

	-- LSP
	hi("LspReferenceText", { bg = cursor_bg })
	hi("LspReferenceRead", { bg = cursor_bg })
	hi("LspReferenceWrite", { bg = visual_bg })

	-- Git signs — flat fg
	local git_groups = {
		"GitSignsAdd", "GitSignsChange", "GitSignsDelete",
		"NeoTreeGitAdded", "NeoTreeGitModified", "NeoTreeGitDeleted",
		"NeoTreeGitUntracked", "NeoTreeGitConflict", "NeoTreeGitIgnored", "NeoTreeGitStaged",
	}
	for _, group in ipairs(git_groups) do
		hi(group)
	end

	-- Neo-tree — transparent
	hi("NeoTreeNormal")
	hi("NeoTreeNormalNC")
	hi("NeoTreeRootName", { bold = true })
	hi("NeoTreeDirectoryName")
	hi("NeoTreeDirectoryIcon")
	hi("NeoTreeFileName")
	hi("NeoTreeFileNameOpened", { bold = true })
	hi("NeoTreeIndentMarker")
	hi("NeoTreeExpander")
	hi("NeoTreeDotfile")
	hi("NeoTreeHiddenByName")
	hi("NeoTreeSymbolicLinkTarget")
	hi("NeoTreeCursorLine", { bg = cursor_bg })
	hi("NeoTreeEndOfBuffer")

	-- Dev icons
	hi("DevIconRs")
	hi("DevIconToml")
	hi("DevIconLua")
	hi("DevIconDefault")

	-- Telescope — transparent
	hi("TelescopeNormal")
	hi("TelescopeBorder")
	hi("TelescopePromptNormal")
	hi("TelescopePromptBorder")
	hi("TelescopePromptTitle")
	hi("TelescopeResultsNormal")
	hi("TelescopeResultsBorder")
	hi("TelescopeResultsTitle")
	hi("TelescopePreviewNormal")
	hi("TelescopePreviewBorder")
	hi("TelescopePreviewTitle")
	hi("TelescopeSelection", { bg = visual_bg, bold = true })
	hi("TelescopeMatching", { bold = true })

	-- Bufferline — transparent
	hi("BufferLineFill")
	hi("BufferLineBackground")
	hi("BufferLineBufferSelected", { bold = true })
	hi("BufferLineBufferVisible")
	hi("BufferLineSeparator")
	hi("BufferLineSeparatorSelected")
	hi("BufferLineSeparatorVisible")
	hi("BufferLineModified")
	hi("BufferLineModifiedSelected")
	hi("BufferLineModifiedVisible")
	hi("BufferLineIndicatorSelected")
	hi("BufferLineDuplicate")
	hi("BufferLineDuplicateSelected")
	hi("BufferLineDuplicateVisible")

	-- Noice — transparent
	hi("NoicePopup")
	hi("NoicePopupBorder")
	hi("NoiceCmdlinePopup")
	hi("NoiceCmdlinePopupBorder")
	hi("NoiceCmdlineIcon")
	hi("NoiceConfirm")
	hi("NoiceConfirmBorder")
	hi("NoiceMini")

	-- Notify — transparent
	hi("NotifyBackground")
	hi("NotifyERRORBorder")
	hi("NotifyWARNBorder")
	hi("NotifyINFOBorder")
	hi("NotifyDEBUGBorder")
	hi("NotifyTRACEBorder")
	hi("NotifyERRORIcon")
	hi("NotifyWARNIcon")
	hi("NotifyINFOIcon")
	hi("NotifyDEBUGIcon")
	hi("NotifyTRACEIcon")
	hi("NotifyERRORTitle")
	hi("NotifyWARNTitle")
	hi("NotifyINFOTitle")
	hi("NotifyERRORBody")
	hi("NotifyWARNBody")
	hi("NotifyINFOBody")

	-- Which-key — transparent
	hi("WhichKeyFloat")
	hi("WhichKey")
	hi("WhichKeyGroup")
	hi("WhichKeySeparator")
	hi("WhichKeyDesc")
	hi("WhichKeyBorder")

	-- Trouble — transparent
	hi("TroubleNormal")
	hi("TroubleText")
	hi("TroubleCount")
	hi("TroubleLocation")

	-- Mason — transparent
	hi("MasonNormal")
	hi("MasonHighlight", { bold = true })
	hi("MasonHighlightBlock")
	hi("MasonMuted")
	hi("MasonMutedBlock")
	hi("MasonBorder")

	-- Lazy — transparent
	hi("LazyNormal")
	hi("LazyButton")
	hi("LazyButtonActive", { bold = true })
	hi("LazySpecial")
	hi("LazyProgressDone")
	hi("LazyProgressTodo")
	hi("LazyReasonPlugin")
	hi("LazyReasonEvent")

	-- Fidget
	hi("FidgetTitle", { bold = true })
	hi("FidgetTask")

	-- Incline — transparent
	hi("InclineNormal")
	hi("InclineNormalNC")

	-- DAP
	local dap_groups = {
		"DapBreakpoint", "DapBreakpointRejected", "DapStopped", "DapLogPoint",
		"DapUIScope", "DapUIType", "DapUIValue", "DapUIModifiedValue",
		"DapUIThread", "DapUIStoppedThread", "DapUIFrameName",
		"DapUISource", "DapUILineNumber", "DapUIWinSelect",
	}
	for _, group in ipairs(dap_groups) do
		hi(group)
	end

	-- Blink / nvim-cmp kind icons — all same fg
	local kind_groups = {}
	local kinds = {
		"Text", "Method", "Function", "Constructor", "Field", "Variable",
		"Class", "Interface", "Module", "Property", "Unit", "Value", "Enum",
		"Keyword", "Snippet", "Color", "File", "Reference", "Folder",
		"EnumMember", "Constant", "Struct", "Event", "Operator", "TypeParameter",
	}
	for _, kind in ipairs(kinds) do
		kind_groups[#kind_groups + 1] = "BlinkCmpKind" .. kind
		kind_groups[#kind_groups + 1] = "CmpItemKind" .. kind
	end
	for _, group in ipairs(kind_groups) do
		hi(group)
	end

	-- Alpha
	hi("AlphaHeader")
	hi("AlphaButtons")
	hi("AlphaFooter")

	-- Lualine
	local lualine_mode_fg = mix(fg, bg, 0.2)
	local lualine_mode_bg = mix(bg, fg, 0.2)
	for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
		hi("lualine_a_" .. mode, { fg = lualine_mode_fg, bg = lualine_mode_bg, bold = true })
		hi("lualine_b_" .. mode, { bg = cursor_bg })
		hi("lualine_c_" .. mode)
	end
	hi("lualine_a_inactive")
	hi("lualine_b_inactive")
	hi("lualine_c_inactive")
end

return M
