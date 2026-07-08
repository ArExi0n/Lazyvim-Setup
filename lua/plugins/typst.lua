return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "tinymist" })
		end,
	},

	-- tinymist LSP server config is in lsp.lua

	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "typst" })
		end,
	},

	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.typst = { "typstyle" }
			opts.formatters = opts.formatters or {}
			opts.formatters.typstyle = {
				command = "typstyle",
				args = { "-" },
				stdin = true,
			}
		end,
	},
}
