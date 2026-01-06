if vim.loader then
	vim.loader.enable()
end

local _print = vim.print

_G.dd = function(...)
	_print(...)
end

require("config.autocmds")
require("config.lazy")
