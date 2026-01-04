return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
			disable = { "yaml" },
		},
		opts = {
			ensure_installed = {
				"javascript",
				"typescript",
				"tsx",
				"css",
				"gitignore",
				"graphql",
				"http",
				"json",
				"scss",
				"swift",
				"rust",
				"sql",
				"vim",
				"lua",
				"html",
				"markdown",
				"markdown_inline",
				"bash",
				"c",
				"go",
				"python",
			},
			query_linter = {
				enable = true,
				use_virtual_text = true,
				lint_events = { "BufWrite", "CursorHold" },
			},
		},
	},
}
