local M = {}

local function setup()
	vim.cmd.colorscheme("vague")
end

function M.names()
	return { "vague" }
end

function M.current()
	return vim.g.colors_name
end

function M.set(name, opts)
	if name == "vague" then
		setup()
		if opts and opts.notify ~= false then
			vim.notify("Theme: vague", vim.log.levels.INFO)
		end
		return true
	end
	return false
end

return M