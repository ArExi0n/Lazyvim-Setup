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
