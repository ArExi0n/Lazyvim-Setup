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
				"shfmt",
				"stylua",
				"prettier",
			})
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
						return require("lspconfig.util").root_pattern(
							"Package.swift",
							".git",
							"*.xcodeproj",
							"*.xcworkspace"
						)(filename)
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
							cargo = { allFeatures = true, loadOutDirsFromCheck = true },
							checkOnSave = { command = "clippy", allFeatures = true },
							procMacro = { enable = true },
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
			})

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					local server_opts = opts.servers[server_name] or {}
					server_opts.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
					require("lspconfig")[server_name].setup(server_opts)
				end,
			})

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
					map("n", "<leader>vrr", vim.lsp.buf.references, "LSP: References")
					map("n", "<leader>vrn", vim.lsp.buf.rename, "LSP: Rename")
					map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help")
					map("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, "LSP: Format")

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
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				rust = { "rustfmt" },
				swift = { "swiftformat" },
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
