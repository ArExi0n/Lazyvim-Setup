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
				-- Linters
				"luacheck",
				"shellcheck",
				-- Formatters
				"shfmt",
				"swiftformat",
				"stylua",
				"prettier",
			})
		end,
	},

	-- LSP Configuration with auto-setup
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = {
			-- Automatically start LSP servers
			autostart = true,

			inlay_hints = { enabled = true },

			diagnostics = {
				underline = true,
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
				-- TypeScript/JavaScript
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

				-- Swift LSP (Fixed configuration - moved out of ts_ls)
				sourcekit = {
					autostart = true,
					cmd = { "sourcekit-lsp" },
					filetypes = { "swift", "objc", "objcpp" },
					root_dir = function(filename, bufnr)
						local util = require("lspconfig.util")
						return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace", ".git")(filename)
							or util.find_git_ancestor(filename)
					end,
					capabilities = {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					},
					settings = {},
				},

				eslint = {
					autostart = true,
					settings = {
						workingDirectories = { mode = "auto" },
					},
				},

				jsonls = {
					autostart = true,
				},

				bashls = {
					autostart = true,
				},

				cssls = {
					autostart = true,
				},

				html = {
					autostart = true,
				},

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
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
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
								allFeatures = true,
								loadOutDirsFromCheck = true,
							},
							checkOnSave = {
								command = "clippy",
								allFeatures = true,
							},
							procMacro = {
								enable = true,
							},
						},
					},
				},

				gopls = {
					autostart = true,
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
							gofumpt = true,
						},
					},
				},

				zls = {
					autostart = true,
				},
			},

			setup = {},
		},

		config = function(_, opts)
			-- Configure diagnostics globally
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- Auto-install LSP servers via mason-lspconfig
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(opts.servers),
				automatic_installation = true,
			})

			-- Floating definition preview function
			local function open_window_for_definition()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
					if not result or vim.tbl_isempty(result) then
						vim.diagnostic.open_float(nil, { border = "rounded", source = true, scope = "line" })
						return
					end
					local loc = result[1]
					if not loc or not loc.uri then
						vim.diagnostic.open_float(nil, { border = "rounded", source = true, scope = "line" })
						return
					end
					local bufnr = vim.uri_to_bufnr(loc.uri)
					vim.fn.bufload(bufnr)
					local lines =
						vim.api.nvim_buf_get_lines(bufnr, loc.range.start.line, loc.range["end"].line + 1, false)
					local content = table.concat(lines, "\n")
					vim.lsp.util.open_floating_preview(vim.split(content, "\n"), "typescript", {
						border = "rounded",
						focusable = true,
						max_width = 80,
						max_height = 20,
					})
				end)
			end

			-- LSP Attach autocmd for keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local bufnr = ev.buf
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- Enable omnifunc completion
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
							silent = true,
							noremap = true,
						})
					end

					-- LSP keymaps
					map("n", "gd", open_window_for_definition, "LSP: Floating definition preview")
					map("n", "<leader>gd", vim.lsp.buf.definition, "LSP: Go to definition")
					map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
					map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
					map("n", "gr", vim.lsp.buf.references, "LSP: References")
					map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
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

					-- Refresh diagnostics on save
					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						callback = function()
							vim.diagnostic.show(nil, bufnr)
						end,
					})

					-- Show diagnostics on CursorHold
					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = bufnr,
						callback = function()
							vim.diagnostic.open_float(nil, {
								focusable = false,
								close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
								border = "rounded",
								source = "always",
								prefix = " ",
								scope = "cursor",
							})
						end,
					})
				end,
			})

			-- Setup all servers
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Enhanced capabilities
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.completion.completionItem.resolveSupport = {
				properties = {
					"documentation",
					"detail",
					"additionalTextEdits",
				},
			}

			-- Setup mason-lspconfig handlers
			require("mason-lspconfig").setup_handlers({
				-- Default handler
				function(server_name)
					local server_opts = opts.servers[server_name] or {}
					server_opts.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

					if opts.setup[server_name] then
						if opts.setup[server_name](server_name, server_opts) then
							return
						end
					end

					lspconfig[server_name].setup(server_opts)
				end,
			})

			-- Apply Catppuccin theme colors
			vim.schedule(function()
				local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")
				if has_catppuccin then
					local palette = catppuccin.get_palette("frappe")

					vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = palette.red, bg = "NONE" })
					vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = palette.yellow, bg = "NONE" })
					vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = palette.blue, bg = "NONE" })
					vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = palette.teal, bg = "NONE" })
				end
			end)
		end,
	},

	-- Linting
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

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			{
				"zbirenbaum/copilot-cmp",
				optional = true,
				config = function()
					require("copilot_cmp").setup()
				end,
			},
		},
		opts = function(_, opts)
			local cmp = require("cmp")
			local has_copilot_cmp = pcall(require, "copilot_cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			require("luasnip.loaders.from_vscode").lazy_load()

			opts.formatting = {
				format = function(entry, vim_item)
					local kind_icons = {
						Text = "",
						Method = "󰆧",
						Function = "󰊕",
						Constructor = "",
						Field = "󰇽",
						Variable = "󰂡",
						Class = "󰠱",
						Interface = "",
						Module = "",
						Property = "󰜢",
						Unit = "",
						Value = "󰎠",
						Enum = "",
						Keyword = "󰌋",
						Snippet = "",
						Color = "󰏘",
						File = "󰈙",
						Reference = "",
						Folder = "󰉋",
						EnumMember = "",
						Constant = "󰏿",
						Struct = "",
						Event = "",
						Operator = "󰆕",
						TypeParameter = "󰅲",
						Copilot = "",
					}

					vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
					vim_item.menu = ({
						copilot = "[Copilot]",
						nvim_lsp = "[LSP]",
						buffer = "[BUF]",
						path = "[PATH]",
						emoji = "[EMOJI]",
						luasnip = "[SNIP]",
					})[entry.source.name]

					return vim_item
				end,
			}

			opts.window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			}

			opts.sources = cmp.config.sources({
				{ name = "copilot", group_index = 1, priority = 1000 },
				{ name = "nvim_lsp", group_index = 2, priority = 900 },
				{ name = "luasnip", group_index = 2, priority = 750 },
				{ name = "path", group_index = 2, priority = 500 },
			}, {
				{ name = "buffer", group_index = 3, priority = 250 },
				{ name = "emoji", group_index = 3, priority = 100 },
			})

			opts.sorting = {
				priority_weight = 2,
				comparators = {
					has_copilot_cmp and require("copilot_cmp").prioritize or nil,
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			}

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
					["<C-b>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-f>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
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
				window = {
					winblend = 0,
				},
			},
		},
		event = "VeryLazy",
		config = function()
			local fidget = require("fidget")
			fidget.setup({
				notification = {
					window = {
						normal_hl = "String", -- Base highlight group in the notification window
						winblend = 0, -- Background color opacity in the notification window
						border = "rounded", -- Border around the notification window
						zindex = 45, -- Stacking priority of the notification window
						max_width = 0, -- Maximum width of the notification window
						max_height = 0, -- Maximum height of the notification window
						x_padding = 1, -- Padding from right edge of window boundary
						y_padding = 1, -- Padding from bottom edge of window boundary
						align = "bottom", -- How to align the notification window
						relative = "editor", -- What the notification window position is relative to
					},
				},
			})
		end,
	},
}
