return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		priority = 1000,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},

		keys = {
			-- File pickers
			{
				";f",
				function()
					require("telescope.builtin").find_files({ hidden = true })
				end,
				desc = "Find files (respects .gitignore)",
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<C-S>",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Git files",
			},

			-- Search
			{
				";r",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
				end,
				desc = "Grep search",
			},
			{
				"<leader>pws",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
				end,
			},
			{
				"<leader>pWs",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") })
				end,
			},

			-- Buffers & history
			{
				"\\\\",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				";;",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume picker",
			},

			-- Diagnostics & code
			{
				";e",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				";s",
				function()
					require("telescope.builtin").treesitter()
				end,
				desc = "Treesitter symbols",
			},

			-- Help
			{
				"<leader>vh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},

			-- File browser
			{
				"sf",
				function()
					local telescope = require("telescope")
					local function buffer_dir()
						return vim.fn.expand("%:p:h")
					end
					telescope.extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = buffer_dir(),
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						layout_config = { height = 0.85 },
					})
				end,
				desc = "File browser",
			},
		},

		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = telescope.extensions.file_browser.actions

			opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
				wrap_results = true,
				sorting_strategy = "ascending",
				winblend = 0,
				layout_strategy = "horizontal",

				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						width = 0.87,
						height = 0.80,
					},
					vertical = {
						prompt_position = "top",
						preview_cutoff = 40,
						width = 0.87,
						height = 0.80,
					},
					center = {
						prompt_position = "top",
						width = 0.87,
						height = 0.60,
					},
				},

				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
			})

			opts.pickers = {
				diagnostics = {
					theme = "ivy",
					initial_mode = "normal",
					layout_config = { preview_cutoff = 9999 },
				},
				find_files = {
					hidden = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			}

			opts.extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				file_browser = {
					theme = "dropdown",
					hijack_netrw = true,
					mappings = {
						n = {
							["N"] = fb_actions.create,
							["h"] = fb_actions.goto_parent_dir,
							["<C-u>"] = function(buf)
								for _ = 1, 10 do
									actions.move_selection_previous(buf)
								end
							end,
							["<C-d>"] = function(buf)
								for _ = 1, 10 do
									actions.move_selection_next(buf)
								end
							end,
						},
					},
				},
			}

			telescope.setup(opts)
			telescope.load_extension("fzf")
			telescope.load_extension("file_browser")
		end,
	},
}
