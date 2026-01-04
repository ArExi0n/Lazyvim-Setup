return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					-- Web Development
					"javascript",
					"typescript",
					"tsx",
					"css",
					"html",
					"json",
					"scss",
					"graphql",
					"http",

					-- Systems Programming
					"swift",
					"rust",
					"c",
					"go",
					"python",

					-- Scripting & Config
					"lua",
					"vim",
					"bash",
					"sql",

					-- Documentation
					"markdown",
					"markdown_inline",

					-- Version Control
					"gitignore",
					"git_config",
					"git_rebase",
					"gitcommit",
					"gitattributes",
				},

				-- Automatically install missing parsers when entering buffer
				auto_install = true,

				highlight = {
					enable = true,
					-- Disable for very large files
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
					-- Setting this to true will run `:h syntax` and tree-sitter at the same time
					additional_vim_regex_highlighting = false,
				},

				indent = {
					enable = true,
					-- Disable indentation for yaml as it can be problematic
					disable = { "yaml" },
				},

				-- Enable incremental selection
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},

				-- Query linter for debugging treesitter queries
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
			})

			-- Fold settings for treesitter
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldenable = false -- Don't fold by default
		end,
	},
}
