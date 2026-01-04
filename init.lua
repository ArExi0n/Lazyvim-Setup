if vim.loader then
	vim.loader.enable()
end

_G.dd = function(...)
	vim.print(...)
end
vim.print = _G.dd

require("config.lazy")
