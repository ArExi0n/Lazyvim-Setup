local global_manim = "/Users/ansh/Library/Python/3.9/bin/manim"

local function is_python_file()
	local ext = vim.fn.expand("%:e")
	return ext == "py"
end

local function find_manim()
	local root = require("lspconfig.util").root_pattern("pyproject.toml", ".git")(vim.fn.expand("%:p"))
	if root then
		local venv_manim = root .. "/.venv/bin/manim"
		if vim.uv.fs_stat(venv_manim) then
			return venv_manim
		end
	end
	return global_manim
end

local function find_python()
	local root = require("lspconfig.util").root_pattern("pyproject.toml", ".git")(vim.fn.expand("%:p"))
	if root then
		local venv_python = root .. "/.venv/bin/python"
		if vim.uv.fs_stat(venv_python) then
			return venv_python
		end
	end
	return vim.fn.exepath("python3") or "/usr/bin/python3"
end

local function pause_cmd(cmd)
	return cmd .. "; echo ''; echo 'Press ENTER to close'; read"
end

return {
	{
		"akinsho/toggleterm.nvim",
		keys = {
			{
				"<leader>mr",
				function()
					if not is_python_file() then
						vim.notify("Not a Python file", vim.log.levels.WARN)
						return
					end
					local src = vim.fn.expand("%:p")
					local cmd = find_python() .. " " .. src
					local Terminal = require("toggleterm.terminal").Terminal
					local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
					term:toggle()
				end,
				desc = "Python: Run file",
			},
			{
				"<leader>mm",
				function()
					if not is_python_file() then
						vim.notify("Not a Python file", vim.log.levels.WARN)
						return
					end
					local src = vim.fn.expand("%:p")
					local quality = vim.g.manim_quality or "m"
					local cmd = find_manim() .. " " .. src .. " -pq" .. quality
					local Terminal = require("toggleterm.terminal").Terminal
					local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
					term:toggle()
				end,
				desc = "Manim: Render scene",
			},
			{
				"<leader>mh",
				function()
					if not is_python_file() then
						vim.notify("Not a Python file", vim.log.levels.WARN)
						return
					end
					local src = vim.fn.expand("%:p")
					local cmd = find_manim() .. " " .. src .. " -pqh"
					local Terminal = require("toggleterm.terminal").Terminal
					local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
					term:toggle()
				end,
				desc = "Manim: Render high quality",
			},
			{
				"<leader>ml",
				function()
					if not is_python_file() then
						vim.notify("Not a Python file", vim.log.levels.WARN)
						return
					end
					local src = vim.fn.expand("%:p")
					local cmd = find_manim() .. " " .. src .. " -pql"
					local Terminal = require("toggleterm.terminal").Terminal
					local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
					term:toggle()
				end,
				desc = "Manim: Render low quality",
			},
		},
	},
}
