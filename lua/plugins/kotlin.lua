-- Kotlin-specific plugins and configurations
return {
	-- Enhanced Kotlin syntax highlighting and indentation
	{
		"udalov/kotlin-vim",
		ft = "kotlin",
	},

	-- Neotest adapter for Gradle (Kotlin/Java testing)
	{
		"nvim-neotest/neotest",
		dependencies = {
			"weilbith/neotest-gradle",
		},
		opts = function(_, opts)
			opts.adapters = opts.adapters or {}
			table.insert(opts.adapters, require("neotest-gradle"))
		end,
	},

	-- Mason configuration to ensure Kotlin tools are installed
	-- Note: LazyVim Kotlin extras already install kotlin-language-server and ktlint
	-- This ensures kotlin-debug-adapter is also installed
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"kotlin-debug-adapter", -- DAP adapter for Kotlin debugging
				"ktlint", -- Kotlin linter and formatter
			})
		end,
	},
}
