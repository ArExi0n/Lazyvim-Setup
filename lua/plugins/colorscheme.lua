return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe", -- latte, frappe, macchiato, mocha
				transparent_background = true,
				show_end_of_buffer = false,
				term_colors = false,
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},
				no_italic = false,
				no_bold = false,
				no_underline = false,
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				color_overrides = {},
				custom_highlights = function(colors)
					return {
						-- Disable cursor line highlighting
						CursorLine = { bg = "NONE" },
						CursorLineNr = { fg = colors.lavender, bg = "NONE" },

						-- Disable LSP reference highlighting (word under cursor)
						LspReferenceText = { bg = "NONE" },
						LspReferenceRead = { bg = "NONE" },
						LspReferenceWrite = { bg = "NONE" },

						-- Disable visual selection of matching words
						MatchParen = { fg = colors.peach, bg = "NONE", bold = true },

						-- Telescope transparency
						TelescopeNormal = { bg = "NONE" },
						TelescopeBorder = { bg = "NONE" },
						TelescopePromptNormal = { bg = "NONE" },
						TelescopePromptBorder = { bg = "NONE" },
						TelescopePromptTitle = { bg = "NONE" },
						TelescopeResultsNormal = { bg = "NONE" },
						TelescopeResultsBorder = { bg = "NONE" },
						TelescopeResultsTitle = { bg = "NONE" },
						TelescopePreviewNormal = { bg = "NONE" },
						TelescopePreviewBorder = { bg = "NONE" },
						TelescopePreviewTitle = { bg = "NONE" },

						-- Float transparency
						NormalFloat = { bg = "NONE" },
						FloatBorder = { bg = "NONE" },
						FloatTitle = { bg = "NONE" },

						-- Popup menu transparency
						Pmenu = { bg = "NONE" },
						PmenuSel = { bg = colors.surface0 },
						PmenuBorder = { bg = "NONE" },

						-- LSP hover/signature transparency
						LspInfoBorder = { bg = "NONE" },

						-- Noice/notification transparency
						NoicePopup = { bg = "NONE" },
						NoicePopupBorder = { bg = "NONE" },
						NoiceCmdlinePopup = { bg = "NONE" },
						NoiceCmdlinePopupBorder = { bg = "NONE" },

						-- Which-key transparency
						WhichKeyFloat = { bg = "NONE" },

						-- Neo-tree transparency
						NeoTreeNormal = { bg = "NONE" },
						NeoTreeNormalNC = { bg = "NONE" },
						NeoTreeEndOfBuffer = { bg = "NONE" },

						-- Notify transparency
						NotifyBackground = { bg = "NONE" },

						-- Mason transparency
						MasonNormal = { bg = "NONE" },

						-- Lazy transparency
						LazyNormal = { bg = "NONE" },
					}
				end,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = true,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
					telescope = {
						enabled = true,
					},
					which_key = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
					neotree = true,
					noice = true,
					mason = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")

			-- Disable cursor line highlighting
			vim.opt.cursorline = false

			-- Disable LSP document highlight (word under cursor highlighting)
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						client.server_capabilities.documentHighlightProvider = false
					end
				end,
			})
		end,
	},
}
