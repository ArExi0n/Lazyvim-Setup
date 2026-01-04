return {
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			-- Ensure formatters_by_ft exists
			opts.formatters_by_ft = opts.formatters_by_ft or {}

			-- Add swift-format for Swift files
			opts.formatters_by_ft.swift = { "swift_format" }

			-- Configure swift-format formatter
			opts.formatters = opts.formatters or {}
			opts.formatters.swift_format = {
				command = "swift-format",
				args = { "$FILENAME" },
				stdin = false,
			}

			return opts
		end,
	},
}
