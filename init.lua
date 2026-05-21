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
		vim.opt.cursorline = false
		vim.opt.cursorcolumn = false
	end,
})
