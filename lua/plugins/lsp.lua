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
				"luacheck",
				"shellcheck",
				"shfmt",
				"stylua",
			})
		end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		opts = {
			inlay_hints = { enabled = true },

			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 2,
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

			-- LSP Server configurations
			servers = {
				-- TypeScript/JavaScript
				ts_ls = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
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

				-- ESLint
				eslint = {},

				-- JSON
				jsonls = {},

				-- Bash
				bashls = {},

				-- CSS Language Server
				cssls = {},

				-- HTML Language Server
				html = {},

				-- Tailwind CSS
				tailwindcss = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
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
						"heex",
					},
				},

				-- Lua Language Server
				lua_ls = {
					single_file_support = true,
					root_dir = function(fname)
						local root_files = {
							".luarc.json",
							".luarc.jsonc",
							".luacheckrc",
							".stylua.toml",
							"stylua.toml",
							"selene.toml",
							"selene.yml",
							".git",
						}
						return require("lspconfig.util").root_pattern(unpack(root_files))(fname)
					end,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = true,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},

				-- Rust Analyzer
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
							},
							checkOnSave = {
								command = "clippy",
							},
						},
					},
				},

				-- Go Language Server
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
						},
					},
				},

				-- Zig Language Server
				zls = {
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(".git", "build.zig", "zls.json")(fname)
					end,
					settings = {
						zls = {
							enable_inlay_hints = true,
							enable_snippets = true,
							warn_style = true,
						},
					},
				},
			},

			setup = {
				-- Custom setup for Zig
				zls = function(_, opts)
					vim.g.zig_fmt_parse_errors = 0
					vim.g.zig_fmt_autosave = 0
				end,
			},
		},

		config = function(_, opts)
			-- Setup diagnostics
			vim.diagnostic.config(opts.diagnostics)

			-- Custom floating definition preview function
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
					vim.lsp.util.open_floating_preview(vim.split(content, "\n"), "rust", {
						border = "rounded",
						focusable = true,
						max_width = 80,
						max_height = 20,
					})
				end)
			end

			-- Custom LSP keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local bufnr = ev.buf
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- Enable omnifunc
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true, noremap = true })
					end

					-- Custom keymaps
					map("n", "gd", open_window_for_definition, "LSP: Floating definition preview")
					map("n", "<leader>gd", vim.lsp.buf.definition, "LSP: Go to definition")
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
				end,
			})

			-- Setup servers
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			for server, server_opts in pairs(opts.servers) do
				server_opts.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				end

				lspconfig[server].setup(server_opts)
			end

			-- Apply Catppuccin theme colors if available
			vim.schedule(function()
				local has_catppuccin, catppuccin = pcall(require, "catppuccin.palettes")
				if has_catppuccin then
					local palette = catppuccin.get_palette("frappe")

					vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = palette.teal })
					vim.api.nvim_set_hl(0, "NormalFloat", { bg = palette.base, fg = palette.text })
					vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.blue, bg = palette.base })
					vim.api.nvim_set_hl(0, "Pmenu", { bg = palette.base, fg = palette.text })
					vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.surface1, fg = palette.text })
					vim.api.nvim_set_hl(0, "PmenuBorder", { fg = palette.blue, bg = palette.base })
					vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = palette.text })
					vim.api.nvim_set_hl(0, "CmpItemKind", { fg = palette.blue })
				end
			end)
		end,
	},

	-- Autocompletion
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

			-- Custom formatting with icons
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

			-- Window configuration
			opts.window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			}

			-- Update sources with priorities
			opts.sources = cmp.config.sources({
				{ name = "copilot", group_index = 1, priority = 1000 },
				{ name = "nvim_lsp", group_index = 2, priority = 900 },
				{ name = "luasnip", group_index = 2, priority = 750 },
				{ name = "path", group_index = 2, priority = 500 },
			}, {
				{ name = "buffer", group_index = 3, priority = 250 },
				{ name = "emoji", group_index = 3, priority = 100 },
			})

			-- Custom sorting with Copilot prioritization
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

			-- Update mappings
			opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-CR>"] = cmp.mapping.confirm({ select = true }),
			})

			return opts
		end,
	},

	-- Formatting
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
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	-- LSP progress UI
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
}
