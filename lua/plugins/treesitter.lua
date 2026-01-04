return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},
		opts = {
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
				"cpp",
				"go",
				"python",

				-- Scripting & Config
				"lua",
				"vim",
				"vimdoc",
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

				-- Data formats
				"yaml",
				"toml",
				"xml",
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

			-- Text objects
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]C"] = "@class.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
					},
				},
			},
		},
		config = function(_, opts)
			-- Setup treesitter
			require("nvim-treesitter.configs").setup(opts)

			-- Fold settings for treesitter
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldenable = false -- Don't fold by default
		end,
	},
}
