-- vim.loader disabled due to startswith nil error
-- if vim.loader then
-- 	vim.loader.enable()
-- end

local _print = vim.print

_G.dd = function(...)
	_print(...)
end

require("config.autocmds")
require("config.options")

require("config.lazy")

-- Load user keymaps after LazyVim's defaults (VeryLazy) so they win conflicts
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		require("config.keymaps")
	end,
})

-- Safety net: lazy.nvim fires VeryLazy on UIEnter, but UIEnter never fires in
-- some environments (nvim --headless, some nvim 0.12 UI-attach timings).
-- Without it, all event = "VeryLazy" plugins (mini.ai textobjects, which-key,
-- fidget, flash, ...) never load. Fire it on VimEnter if it hasn't fired yet.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.defer_fn(function()
			if not vim.g.did_very_lazy then
				vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
			end
		end, 300)
	end,
})

require("config.theme").setup({
	default = "koda",
})

vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		vim.opt.cursorline = true
		vim.opt.cursorlineopt = "number"
		vim.opt.cursorcolumn = false
		vim.opt.list = false
		vim.opt.statuscolumn = ""
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "go.mod" },
	callback = function()
		vim.bo.filetype = "gomod"
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "go.sum" },
	callback = function()
		vim.bo.filetype = "gosum"
	end,
})
