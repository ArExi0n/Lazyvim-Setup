local helpers = require("tests.helpers")

describe("LSP Configuration", function()
	local lsp_config
	local original_vim

	before_each(function()
		-- Save original vim functions we might mock
		original_vim = {
			lsp = vim.lsp,
			keymap = vim.keymap,
			api = vim.api,
			fn = vim.fn,
			bo = vim.bo,
			diagnostic = vim.diagnostic,
			trim = vim.trim,
			tbl_keys = vim.tbl_keys,
			tbl_deep_extend = vim.tbl_deep_extend,
			deepcopy = vim.deepcopy,
			schedule = vim.schedule,
		}

		-- Load the LSP configuration
		lsp_config = require("plugins.lsp")

		-- Mock vim functions
		vim.lsp = {
			protocol = {
				make_client_capabilities = function()
					return {
						textDocument = {
							completion = {
								completionItem = {},
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
		}

		vim.keymap = {
			set = spy.new(function() end),
		}

		vim.api = {
			nvim_create_augroup = function()
				return 1
			end,
			nvim_create_autocmd = function() end,
			nvim_buf_get_lines = function()
				return {}
			end,
			nvim_set_hl = function() end,
		}

		vim.fn = {
			expand = function()
				return "/test/file.lua"
			end,
			system = function(cmd)
				if cmd == "xcrun -f sourcekit-lsp" then
					return "/usr/bin/sourcekit-lsp\n"
				end
				return ""
			end,
		}

		vim.trim = function(str)
			return str:gsub("^%s*(.-)%s*$", "%1")
		end
		vim.tbl_keys = function(t)
			local keys = {}
			for k, _ in pairs(t) do
				table.insert(keys, k)
			end
			return keys
		end

		vim.tbl_deep_extend = function(behavior, ...)
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
		end

		vim.deepcopy = function(t)
			return t
		end
		vim.schedule = function(fn)
			fn()
		end
		vim.diagnostic = { config = function() end, open_float = function() end }
		vim.bo = {}
	end)

	after_each(function()
		-- Restore original vim functions
		for k, v in pairs(original_vim) do
			vim[k] = v
		end
	end)

	describe("tsserver configuration", function()
		it("should be correctly configured as an LSP server", function()
			-- Get the nvim-lspconfig plugin config
			local lspconfig_plugin = lsp_config[3] -- nvim-lspconfig is the 3rd plugin
			assert.is_not_nil(lspconfig_plugin)
			assert.equals("neovim/nvim-lspconfig", lspconfig_plugin[1])

			-- Check tsserver is in the servers configuration
			local opts = lspconfig_plugin.opts
			assert.is_not_nil(opts.servers.tsserver)
			assert.is_true(opts.servers.tsserver.autostart)
			assert.is_true(opts.servers.tsserver.single_file_support)

			-- Verify tsserver settings
			local tsserver_config = opts.servers.tsserver
			assert.is_not_nil(tsserver_config.settings.typescript)
			assert.is_not_nil(tsserver_config.settings.javascript)
			assert.is_not_nil(tsserver_config.root_dir)

			-- Test root_dir function
			local lspconfig_util = {
				root_pattern = function()
					return function()
						return "/test/project"
					end
				end,
			}
			package.loaded["lspconfig.util"] = lspconfig_util
			local root_dir = tsserver_config.root_dir()
			assert.equals("/test/project", root_dir)
		end)

		it("should start as an LSP server with correct autostart setting", function()
			local lspconfig_plugin = lsp_config[3]
			local tsserver_config = lspconfig_plugin.opts.servers.tsserver

			assert.is_true(tsserver_config.autostart, "tsserver should have autostart enabled")
		end)
	end)

	describe("sourcekit configuration", function()
		it("should start with the correct command", function()
			local lspconfig_plugin = lsp_config[3]
			local sourcekit_config = lspconfig_plugin.opts.servers.sourcekit

			-- Check the cmd in the servers configuration
			assert.same({ "sourcekit-lsp" }, sourcekit_config.cmd)

			-- Check filetypes
			assert.same({ "swift", "objc", "objcpp" }, sourcekit_config.filetypes)
		end)

		it("should have correct root_dir pattern", function()
			local lspconfig_plugin = lsp_config[3]
			local sourcekit_config = lspconfig_plugin.opts.servers.sourcekit

			assert.is_function(sourcekit_config.root_dir)

			-- Mock lspconfig.util for testing
			local lspconfig_util = {
				root_pattern = function(...)
					local patterns = { ... }
					assert.same({ "Package.swift", ".git", "*.xcodeproj", "*.xcworkspace" }, patterns)
					return function()
						return "/test/swift/project"
					end
				end,
			}
			package.loaded["lspconfig.util"] = lspconfig_util

			local root_dir = sourcekit_config.root_dir("/test/file.swift")
			assert.equals("/test/swift/project", root_dir)
		end)

		it("should set buffer options in on_attach function", function()
			local lspconfig_plugin = lsp_config[3]
			local sourcekit_config = lspconfig_plugin.opts.servers.sourcekit

			assert.is_function(sourcekit_config.on_attach)

			-- Mock vim.bo
			local buffer_options = {}
			vim.bo = setmetatable({}, {
				__index = function(_, bufnr)
					if not buffer_options[bufnr] then
						buffer_options[bufnr] = {}
					end
					return buffer_options[bufnr]
				end,
				__newindex = function(_, bufnr, options)
					if not buffer_options[bufnr] then
						buffer_options[bufnr] = {}
					end
					for k, v in pairs(options) do
						buffer_options[bufnr][k] = v
					end
				end,
			})

			-- Call on_attach
			local mock_client = {}
			local test_bufnr = 1
			sourcekit_config.on_attach(mock_client, test_bufnr)

			-- Verify buffer options were set
			assert.equals(4, vim.bo[test_bufnr].tabstop)
			assert.equals(4, vim.bo[test_bufnr].shiftwidth)
			assert.is_true(vim.bo[test_bufnr].expandtab)
		end)
	end)

	describe("sourcekit LSP on_attach function keymappings", function()
		it("should correctly set key mappings for showing diagnostics and hover documentation", function()
			local lspconfig_plugin = lsp_config[3]

			-- Mock the config function to capture the on_attach function from the manual setup
			local captured_on_attach
			local mock_lspconfig = {
				sourcekit = {
					setup = function(config)
						captured_on_attach = config.on_attach
					end,
				},
			}

			package.loaded["lspconfig"] = mock_lspconfig
			package.loaded["neoconf"] = { setup = function() end }
			package.loaded["mason-lspconfig"] = {
				setup = function() end,
				setup_handlers = function() end,
			}

			-- Execute the config function
			lspconfig_plugin.config(nil, lspconfig_plugin.opts)

			-- Verify on_attach was captured
			assert.is_function(captured_on_attach)

			-- Mock buffer number
			local test_bufnr = 1
			local mock_client = {}

			-- Call the on_attach function
			captured_on_attach(mock_client, test_bufnr)

			-- Verify keymap.set was called with the correct mappings
			assert.spy(vim.keymap.set).was_called()

			-- Check for diagnostic mapping ("<leader>d")
			assert.spy(vim.keymap.set).was_called_with(
				"n",
				"<leader>d",
				vim.diagnostic.open_float,
				match.has_match(function(opts)
					return opts.buffer == test_bufnr and opts.desc == "Show line diagnostics"
				end)
			)

			-- Check for hover documentation mapping ("K")
			assert.spy(vim.keymap.set).was_called_with(
				"n",
				"K",
				vim.lsp.buf.hover,
				match.has_match(function(opts)
					return opts.buffer == test_bufnr and opts.desc == "Show documentation for what is under cursor"
				end)
			)
		end)

		it("should correctly set key mapping for Telescope lsp_definitions", function()
			local lspconfig_plugin = lsp_config[3]

			-- Mock the config function setup (similar to above)
			local captured_on_attach
			local mock_lspconfig = {
				sourcekit = {
					setup = function(config)
						captured_on_attach = config.on_attach
					end,
				},
			}

			package.loaded["lspconfig"] = mock_lspconfig
			package.loaded["neoconf"] = { setup = function() end }
			package.loaded["mason-lspconfig"] = {
				setup = function() end,
				setup_handlers = function() end,
			}

			-- Execute the config function
			lspconfig_plugin.config(nil, lspconfig_plugin.opts)

			-- Call the on_attach function
			local test_bufnr = 1
			local mock_client = {}
			captured_on_attach(mock_client, test_bufnr)

			-- Check for Telescope lsp_definitions mapping ("gd")
			assert.spy(vim.keymap.set).was_called_with(
				"n",
				"gd",
				"<cmd>Telescope lsp_definitions trim_text=true<cr>",
				match.has_match(function(opts)
					return opts.buffer == test_bufnr and opts.desc == "Show LSP definition"
				end)
			)
		end)
	end)

	describe("sourcekit LSP on_init function", function()
		it("should set client.offset_encoding to utf-8", function()
			local lspconfig_plugin = lsp_config[3]

			-- Mock the config function to capture the on_init function
			local captured_on_init
			local mock_lspconfig = {
				sourcekit = {
					setup = function(config)
						captured_on_init = config.on_init
					end,
				},
			}

			package.loaded["lspconfig"] = mock_lspconfig
			package.loaded["neoconf"] = { setup = function() end }
			package.loaded["mason-lspconfig"] = {
				setup = function() end,
				setup_handlers = function() end,
			}

			-- Execute the config function
			lspconfig_plugin.config(nil, lspconfig_plugin.opts)

			-- Verify on_init was captured
			assert.is_function(captured_on_init)

			-- Mock client object
			local mock_client = {}

			-- Call the on_init function
			captured_on_init(mock_client)

			-- Verify offset_encoding was set to "utf-8"
			assert.equals("utf-8", mock_client.offset_encoding)
		end)
	end)

	describe("sourcekit manual setup", function()
		it("should configure sourcekit with xcrun command and proper capabilities", function()
			local lspconfig_plugin = lsp_config[3]

			-- Mock the setup call to capture configuration
			local captured_config
			local mock_lspconfig = {
				sourcekit = {
					setup = function(config)
						captured_config = config
					end,
				},
			}

			package.loaded["lspconfig"] = mock_lspconfig
			package.loaded["neoconf"] = { setup = function() end }
			package.loaded["mason-lspconfig"] = {
				setup = function() end,
				setup_handlers = function() end,
			}

			-- Execute the config function
			lspconfig_plugin.config(nil, lspconfig_plugin.opts)

			-- Verify the manual sourcekit setup was called with correct cmd
			assert.is_table(captured_config)
			assert.same({ "/usr/bin/sourcekit-lsp" }, captured_config.cmd)

			-- Verify capabilities were set
			assert.is_not_nil(captured_config.capabilities)

			-- Verify on_attach and on_init are functions
			assert.is_function(captured_config.on_attach)
			assert.is_function(captured_config.on_init)
		end)
	end)
end)

