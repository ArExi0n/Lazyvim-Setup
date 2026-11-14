-- Sylvan-style start screen (homepage only).
-- When nvim opens with no args on an empty [No Name] buffer, make it look
-- exactly like sylvan-nvim's default screen: everforest medium/transparent,
-- absolute line numbers, default statusline + tabline, no lualine.
-- Everything is restored the moment a real file is opened, so normal
-- editing behavior is untouched.
local M = {}

local saved = nil
local start_buf = nil
-- Buffer that existed while init.lua ran (the startup buffer). Late-apply
-- below only ever fires for this exact buffer, so :enew later can't
-- retrigger sylvan mode. Once anything real is shown, startup is over.
local setup_buf = nil
local startup_done = false

local EVERFOREST_KEYS = {
	"everforest_background",
	"everforest_transparent_background",
	"everforest_better_performance",
	"everforest_enable_italic",
}

local function is_empty_start_buf(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	if vim.bo[buf].buftype ~= "" then
		return false
	end
	if vim.api.nvim_buf_get_name(buf) ~= "" then
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	return #lines <= 1 and (lines[1] or "") == ""
end

local function apply()
	if saved then
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	if vim.fn.argc() ~= 0 or not is_empty_start_buf(buf) then
		return
	end
	start_buf = buf
	saved = {
		-- NOTE: on empty startup LazyVim's lualine init forces laststatus=0
		-- and restores lualine_laststatus (=3) when lualine loads. Save the
		-- post-load value so leaving the start screen matches opening a
		-- file directly.
		laststatus = vim.g.lualine_laststatus or vim.o.laststatus,
		showtabline = vim.o.showtabline,
		ruler = vim.o.ruler,
		showmode = vim.o.showmode,
		winborder = vim.o.winborder,
		theme = vim.g.colors_name,
		everforest = {},
	}
	for _, k in ipairs(EVERFOREST_KEYS) do
		saved.everforest[k] = vim.g[k]
	end
	-- Default statusline, not lualine's.
	pcall(function()
		require("lualine").hide({ place = { "statusline" }, unhide = false })
	end)
	vim.o.laststatus = 2
	vim.o.showtabline = 2
	vim.o.ruler = true
	vim.o.showmode = true
	vim.o.winborder = "rounded"
	vim.wo.number = true
	vim.wo.relativenumber = false
	-- Sylvan's everforest variant (medium + transparent).
	vim.g.everforest_background = "medium"
	vim.g.everforest_transparent_background = 2
	vim.g.everforest_better_performance = 1
	vim.g.everforest_enable_italic = 1
	pcall(vim.cmd.colorscheme, "everforest")
end

local function restore()
	if not saved then
		return
	end
	local s = saved
	saved = nil
	start_buf = nil
	vim.o.laststatus = s.laststatus
	vim.o.showtabline = s.showtabline
	vim.o.ruler = s.ruler
	vim.o.showmode = s.showmode
	vim.o.winborder = s.winborder
	vim.wo.relativenumber = true
	pcall(function()
		require("lualine").hide({ place = { "statusline" }, unhide = true })
	end)
	for _, k in ipairs(EVERFOREST_KEYS) do
		vim.g[k] = s.everforest[k]
	end
	if s.theme and s.theme ~= vim.g.colors_name then
		pcall(require("config.theme").set, s.theme, { persist = false })
	elseif s.theme then
		-- Same theme name but variant globals changed: re-apply so the
		-- restored everforest settings take effect (transparent.apply
		-- re-runs via the ColorScheme autocmd).
		pcall(vim.cmd.colorscheme, s.theme)
	end
end

function M.setup()
	setup_buf = vim.api.nvim_get_current_buf()
	local group = vim.api.nvim_create_augroup("sylvan_startscreen", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = apply,
	})
	-- Re-assert after lualine loads on VeryLazy: its setup restores
	-- laststatus=3, which would undo the start-screen statusline.
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		group = group,
		callback = function()
			if saved then
				vim.o.laststatus = 2
				pcall(function()
					require("lualine").hide({ place = { "statusline" }, unhide = false })
				end)
			end
		end,
	})
	-- Leave start-screen mode as soon as a real buffer is shown: a
	-- different buffer in a normal window, or the start buffer gains a
	-- filename. Floating windows (pickers, hovers) don't trigger it.
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function(args)
			if not saved and not startup_done then
				-- Startup phase: the initial buffer may be entered before
				-- VimEnter (headless/timing quirks). Apply for the setup
				-- buffer only; anything else ends the startup phase.
				if
					args.buf == setup_buf
					and vim.fn.argc() == 0
					and is_empty_start_buf(args.buf)
				then
					apply()
				else
					startup_done = true
				end
				return
			end
			if not saved then
				return
			end
			if args.buf == start_buf and vim.api.nvim_buf_get_name(args.buf) == "" then
				return
			end
			local ok, cfg = pcall(vim.api.nvim_win_get_config, 0)
			if ok and cfg.relative ~= "" then
				return
			end
			restore()
		end,
	})
	vim.api.nvim_create_autocmd("BufFilePost", {
		group = group,
		callback = function()
			if saved then
				restore()
			end
		end,
	})
end

return M
