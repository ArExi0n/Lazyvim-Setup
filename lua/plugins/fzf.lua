return {
	{
		"ibhagwan/fzf-lua",
		optional = true,
		opts = function(_, opts)
			-- Fix `nvim_open_win: Invalid 'height'` crash for code-action pickers
			-- (e.g. `<leader>qf` quickfix actions, `<leader>vca`) on short
			-- screens / tmux panes.
			--
			-- Root cause: LazyVim's `ui_select` gives codeactions an absolute
			-- `down:15` preview. fzf-lua subtracts that from the main window
			-- height without re-clamping (`win.generate_layout`), so when
			-- `vim.o.lines <= 21` the main height hits 0 and `nvim_open_win`
			-- throws from `redraw_main` <- `create` <- `M.fzf`.
			-- (No `delta` binary installed here, so the builtin previewer —
			-- the crashing path — is always used.)
			--
			-- Starting hidden forces the single-window layout, whose size is
			-- clamped to >= 1. The preview is still one F4 away.
			local ui_select = opts.ui_select
			if type(ui_select) == "function" then
				opts.ui_select = function(fzf_opts, items)
					local res = ui_select(fzf_opts, items)
					if
						type(res) == "table"
						and fzf_opts
						and fzf_opts.kind == "codeaction"
						and vim.o.lines < 24
					then
						res.winopts = res.winopts or {}
						res.winopts.preview = res.winopts.preview or {}
						res.winopts.preview.hidden = true
					end
					return res
				end
			end
		end,
	},
}
