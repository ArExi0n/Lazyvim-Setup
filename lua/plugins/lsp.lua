return {
	{
		"hrsh7th/nvim-cmp",
		version = false,
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					}),
					documentation = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					}),
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.confirm({ select = true })
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-CR>"] = cmp.mapping.complete(),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "path", priority = 500 },
				}, {
					{ name = "buffer", priority = 250, keyword_length = 3 },
				}),
				formatting = {
					format = function(entry, vim_item)
						local kind_icons = {
							Text = "󰉿",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰜢",
							Variable = "󰀫",
							Class = "󰠱",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "󰑭",
							Value = "󰎠",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "󰈇",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "󰙅",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "",
						}
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = {
					priority_weight = 2,
					comparators = {
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
				},
			}
		end,
		config = function(_, opts)
			local cmp = require("cmp")
			cmp.setup(opts)

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
			region_check_events = "CursorMoved",
		},
		config = function(_, opts)
			require("luasnip").setup(opts)
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

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
				tsserver = {
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
					cmd = { "sourcekit-lsp" },
					filetypes = { "swift", "objc", "objcpp" },
					root_dir = function(filename)
						local util = require("lspconfig.util")
						return util.root_pattern("Package.swift", ".git", "*.xcodeproj", "*.xcworkspace")(filename)
					end,
					on_attach = function(client, bufnr)
						vim.bo[bufnr].tabstop = 4
						vim.bo[bufnr].shiftwidth = 4
						vim.bo[bufnr].expandtab = true
					end,
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
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			require("neoconf").setup()

			local servers = vim.tbl_keys(opts.servers or {})
			local ensure_installed = {}
			for _, server in ipairs(servers) do
				if server ~= "sourcekit" then
					table.insert(ensure_installed, server)
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_installation = true,
			})

			capabilities.textDocument.completion.completionItem.snippetSupport = true

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					local server_opts = opts.servers[server_name] or {}
					server_opts.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
					require("lspconfig")[server_name].setup(server_opts)
				end,
			})

			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local on_attach = function(_, bufnr)
				opts.buffer = bufnr

				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Show LSP definition"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions trim_text=true<cr>", opts)
			end

			lspconfig["sourcekit"].setup({
				cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
				capabilities = capabilities,
				on_attach = on_attach,
				on_init = function(client)
					client.offset_encoding = "utf-8"
				end,
			})

			local sourcekit_opts = opts.servers.sourcekit or {}
			sourcekit_opts.capabilities =
				vim.tbl_deep_extend("force", {}, capabilities, sourcekit_opts.capabilities or {})
			lspconfig.sourcekit.setup(sourcekit_opts)

			if opts.setup then
				for server_name, setup_fn in pairs(opts.setup) do
					if type(setup_fn) == "function" then
						setup_fn()
					end
				end
			end

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

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local bufnr = ev.buf
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
							silent = true,
							noremap = true,
						})
					end

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

					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = bufnr,
						callback = function()
							vim.diagnostic.show(nil, bufnr)
						end,
					})

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
	},
}
