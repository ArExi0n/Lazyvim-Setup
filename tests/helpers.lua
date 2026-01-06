-- Test helpers for Neovim plugin tests
local M = {}

-- Mock vim global with essential functions
function M.mock_vim()
	_G.vim = {
		g = {},
		o = {},
		bo = {},
		wo = {},
		env = {},
		v = {
			version = function()
				return { major = 0, minor = 8, patch = 0 }
			end,
		},
		api = {
			nvim_create_augroup = function()
				return 1
			end,
			nvim_create_autocmd = function() end,
			nvim_set_keymap = function() end,
			nvim_buf_get_option = function()
				return ""
			end,
			nvim_buf_set_option = function() end,
			nvim_win_get_option = function()
				return ""
			end,
			nvim_win_set_option = function() end,
			nvim_command = function() end,
			nvim_exec = function() end,
			nvim_get_option = function()
				return ""
			end,
			nvim_set_option = function() end,
			nvim_buf_get_lines = function()
				return {}
			end,
			nvim_set_hl = function() end,
			nvim_create_namespace = function()
				return 1
			end,
		},
		fn = {
			expand = function()
				return ""
			end,
			fnamemodify = function()
				return ""
			end,
			resolve = function()
				return ""
			end,
			executable = function()
				return 1
			end,
			exepath = function()
				return "/usr/bin/test"
			end,
			system = function()
				return ""
			end,
			getcwd = function()
				return "/test"
			end,
		},
		cmd = function() end,
		keymap = {
			set = function() end,
		},
		lsp = {
			protocol = {
				make_client_capabilities = function()
					return {
						textDocument = {
							completion = {
								completionItem = {
									snippetSupport = false,
								},
							},
						},
					}
				end,
			},
			buf = {
				hover = function() end,
				definition = function() end,
				declaration = function() end,
				implementation = function() end,
				references = function() end,
				workspace_symbol = function() end,
				code_action = function() end,
				rename = function() end,
				signature_help = function() end,
				format = function() end,
			},
			get_client_by_id = function()
				return {}
			end,
		},
		diagnostic = {
			config = function() end,
			open_float = function() end,
		},
		tbl_keys = function(t)
			local keys = {}
			for k, _ in pairs(t) do
				table.insert(keys, k)
			end
			return keys
		end,
		tbl_deep_extend = function(behavior, ...)
			local result = {}
			for i = 1, select("#", ...) do
				local tbl = select(i, ...)
				if type(tbl) == "table" then
					for k, v in pairs(tbl) do
						result[k] = v
					end
				end
			end
			return result
		end,
		deepcopy = function(t)
			if type(t) ~= "table" then
				return t
			end
			local copy = {}
			for k, v in pairs(t) do
				copy[k] = M.deepcopy(v)
			end
			return copy
		end,
		trim = function(str)
			return str:gsub("^%s*(.-)%s*$", "%1")
		end,
		schedule = function(fn)
			fn()
		end,
		list_extend = function(dst, src)
			for _, item in ipairs(src) do
				table.insert(dst, item)
			end
			return dst
		end,
		tbl_isempty = function(t)
			return next(t) == nil
		end,
		uri_to_bufnr = function()
			return 1
		end,
		split = function(str, sep)
			local result = {}
			local pattern = string.format("([^%s]+)", sep or "%s")
			for match in str:gmatch(pattern) do
				table.insert(result, match)
			end
			return result
		end,
	}
end

-- Reset package cache
function M.reset_package_cache()
	for name, _ in pairs(package.loaded) do
		if name:match("^plugins%.") then
			package.loaded[name] = nil
		end
	end
end

-- Setup test environment
function M.setup()
	M.mock_vim()
	M.reset_package_cache()
end

-- Teardown test environment
function M.teardown()
	M.reset_package_cache()
end

return M

