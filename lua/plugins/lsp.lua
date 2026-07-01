return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"typescript-language-server",
				"eslint-lsp",
				"lua-language-server",
				"json-lsp",
				"tailwindcss-language-server",
				"bash-language-server",
				"rust-analyzer",
				"gopls",
				"css-lsp",
				"html-lsp",
				"swiftformat",
				"swiftlint",
				"luacheck",
				"shellcheck",
				"prettier",
				"clangd",
				"xcode-build-server",
				"stylua",
				"shfmt",
				"ruff",
				"gofumpt",
				"goimports",
				"ktlint",
				"taplo",
				"rubocop",
			})
		end,
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)
			mr.refresh(function()
				local function install_tools(idx)
					if idx > #opts.ensure_installed then return end
					local p = mr.get_package(opts.ensure_installed[idx])
					if not p:is_installed() then
						local ok, err = pcall(p.install, p)
						if not ok then
							vim.schedule(function()
								install_tools(idx + 1)
							end)
						end
					else
						install_tools(idx + 1)
					end
				end
				install_tools(1)
			end)
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		opts = {
			autostart = true,
			inlay_hints = { enabled = true },
			diagnostics = {
				underline = false,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
				float = {
					border = "rounded",
					focusable = false,
					style = "minimal",
					source = "always",
					header = "",
					prefix = "",
				},
			},

			servers = {
				-- tsserver renamed to ts_ls in lspconfig 0.11+
				ts_ls = {
					autostart = true,
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(
							"package.json",
							"tsconfig.json",
							"jsconfig.json",
							".git"
						)(...)
					end,
					single_file_support = true,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},

				sourcekit = {
					cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
					filetypes = { "swift", "objc", "objcpp" },
					root_dir = function(filename)
						local util = require("lspconfig.util")
						local root = util.root_pattern("buildServer.json", "Package.swift")(filename)
						if root then return root end
						local dir = vim.fs.dirname(filename)
						while dir and dir ~= "/" do
							for entry, type in vim.fs.dir(dir) do
								if type == "directory" and (entry:find("%.xcodeproj$") or entry:find("%.xcworkspace$")) then
									return dir
								end
							end
							dir = vim.fs.dirname(dir)
						end
						return util.root_pattern(".git")(filename)
					end,
					on_attach = function(_, bufnr)
						vim.bo[bufnr].tabstop = 4
						vim.bo[bufnr].shiftwidth = 4
						vim.bo[bufnr].expandtab = true
					end,
				},

				eslint = {
					autostart = true,
					settings = { workingDirectories = { mode = "auto" } },
				},

				jsonls = { autostart = true },
				bashls = { autostart = true },
				cssls = { autostart = true },
				html = { autostart = true },

				tailwindcss = {
					autostart = true,
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(
							"tailwind.config.js",
							"tailwind.config.ts",
							"postcss.config.js",
							"postcss.config.ts",
							".git"
						)(...)
					end,
					filetypes = {
						"html",
						"css",
						"scss",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"vue",
						"svelte",
					},
				},

				lua_ls = {
					autostart = true,
					single_file_support = true,
					settings = {
						Lua = {
							workspace = { checkThirdParty = false },
							completion = { workspaceWord = true, callSnippet = "Both" },
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								globals = { "vim" },
							},
						},
					},
				},

				rust_analyzer = {
					autostart = true,
					settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = false,
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							checkOnSave = { command = "check", allFeatures = false },
							procMacro = { enable = true },
							completion = { callable = { snippets = "fill_arguments" } },
							imports = {
								merge = { glob = true },
								preferNoStd = false,
							},
						},
					},
				},

				gopls = {
					autostart = true,
					settings = {
						gopls = {
							analyses = { unusedparams = true },
							staticcheck = true,
							gofumpt = true,
						},
					},
				},

				clangd = {
					autostart = true,
					cmd = {
				"clangd",
				"xcode-build-server",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
					},
				},

				zls = { autostart = true },
			},

			setup = {},
		},

		config = function(_, opts)
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- blink.cmp capabilities if available
			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
			require("neoconf").setup()

			local ensure_installed = {}
			for server, _ in pairs(opts.servers or {}) do
				if server ~= "sourcekit" then
					table.insert(ensure_installed, server)
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_installation = true,
				handlers = {
					function(server_name)
						local server_opts = opts.servers[server_name] or {}
						server_opts.capabilities =
							vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
						require("lspconfig")[server_name].setup(server_opts)
					end,
				},
			})

			local sk_opts = vim.tbl_deep_extend("force", opts.servers.sourcekit or {}, {
				capabilities = capabilities,
			})
			require("lspconfig").sourcekit.setup(sk_opts)

			vim.api.nvim_create_user_command("SourcekitRestart", function()
				for _, client in ipairs(vim.lsp.get_clients({ name = "sourcekit" })) do
					client:stop()
					vim.notify("sourcekit-lsp stopped, will restart on next Swift file open")
				end
				if vim.fn.executable("xcode-build-server") == 1 then
					vim.fn.jobstart({ "xcode-build-server", "config", "-overwrite" })
				end
			end, { desc = "Restart sourcekit-lsp and regenerate buildServer.json" })

			vim.api.nvim_create_user_command("SourcekitStatus", function()
				local clients = vim.lsp.get_clients({ name = "sourcekit" })
				if #clients == 0 then
					vim.notify("sourcekit-lsp: NOT running", vim.log.levels.WARN)
					return
				end
				local c = clients[1]
				local root = c.config.root_dir or "N/A"
				local has_build_server = vim.fn.filereadable(root .. "/buildServer.json") == 1
				vim.notify(string.format(
					"sourcekit-lsp: running\n  Root: %s\n  buildServer.json: %s",
					root, has_build_server and "yes" or "no"
				))
			end, { desc = "Check sourcekit-lsp status" })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local bufnr = ev.buf

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
							silent = true,
							noremap = true,
						})
					end

					map("n", "<leader>gd", vim.lsp.buf.definition, "LSP: Go to definition")
					map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
					map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
					map("n", "gr", vim.lsp.buf.references, "LSP: References")
					map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
					map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "LSP: Workspace symbol")
					map("n", "<leader>vd", function()
						vim.diagnostic.open_float(0, { scope = "line" })
					end, "LSP: Line diagnostics")
					map("n", "[d", vim.diagnostic.goto_prev, "LSP: Previous diagnostic")
					map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
				map("n", "<leader>vca", vim.lsp.buf.code_action, "LSP: Code action")
				map("n", "<leader>vi", function()
					vim.lsp.buf.code_action({
						context = {
							only = { "source.organizeImports", "source.addMissingImports", "source.fixAll" },
						},
						apply = true,
					})
				end, "LSP: Fix imports")
				map("n", "<leader>vrr", vim.lsp.buf.references, "LSP: References")
					map("n", "<leader>vrn", vim.lsp.buf.rename, "LSP: Rename")
					map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help")
					map("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, "LSP: Format")

					local sk = vim.lsp.get_clients({ bufnr = bufnr, name = "sourcekit" })
					if #sk > 0 then
						map("n", "<leader>xr", ":SourcekitRestart<CR>", "sourcekit-lsp: Restart")
					end

					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = bufnr,
						callback = function()
							vim.diagnostic.open_float(nil, {
								focusable = false,
								close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
								border = "rounded",
								source = "always",
								prefix = " ",
								scope = "cursor",
							})
						end,
					})
				end,
			})

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("monochrome-overrides", { clear = true }),
				callback = function()
					if vim.g.colors_name and vim.g.colors_name:match("^koda") then
						pcall(require("config.monochrome").apply)
					end
				end,
			})
		end,
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				javascript = { "eslint" },
				typescript = { "eslint" },
				javascriptreact = { "eslint" },
				typescriptreact = { "eslint" },
				swift = { "swiftlint" },
				lua = { "luacheck" },
				sh = { "shellcheck" },
			}
			local group = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
				python = { "ruff_format" },
				go = { "gofumpt", "goimports" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				rust = { "rustfmt" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				swift = { "swiftformat" },
				kotlin = { "ktlint" },
				toml = { "taplo" },
				ruby = { "rubocop" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	{
		"j-hui/fidget.nvim",
		opts = {
			notification = {
				window = { winblend = 0 },
			},
		},
	},
}
