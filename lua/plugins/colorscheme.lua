return {
	{
		"oskarnurm/koda.nvim",
		name = "koda",
		priority = 1000,
		config = function()
			require("config.koda").setup("koda-dark")
			vim.cmd.colorscheme("koda-dark")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 900,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
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
				integrations = {
					cmp = true,
					gitsigns = true,
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
					noice = true,
					mason = true,
				},
			})
			vim.cmd.colorscheme("catppuccin")
			vim.opt.cursorline = false
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
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 100,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"navarasu/onedark.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"sainnhe/everforest",
		lazy = true,
		priority = 100,
	},
	{
		"sainnhe/sonokai",
		lazy = true,
		priority = 100,
	},
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
		priority = 100,
	},
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = true,
		priority = 100,
	},
}
