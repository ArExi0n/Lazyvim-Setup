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
					local builtin = require("telescope.builtin")
					builtin.find_files({
						no_ignore = false,
						hidden = true,
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
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

			-- Search pickers
			{
				";r",
				function()
					local builtin = require("telescope.builtin")
					builtin.live_grep()
				end,
				desc = "Search for a string in your current working directory",
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
					local word = vim.fn.expand("<cword>")
					require("telescope.builtin").grep_string({ search = word })
				end,
				desc = "Search word under cursor",
			},
			{
				"<leader>pWs",
				function()
					local word = vim.fn.expand("<cWORD>")
					require("telescope.builtin").grep_string({ search = word })
				end,
				desc = "Search WORD under cursor",
			},

			-- Buffer and history pickers
			{
				"\\\\",
				function()
					local builtin = require("telescope.builtin")
					builtin.buffers()
				end,
				desc = "Lists open buffers",
			},
			{
				";;",
				function()
					local builtin = require("telescope.builtin")
					builtin.resume()
				end,
				desc = "Resume the previous telescope picker",
			},

			-- Diagnostic and code pickers
			{
				";e",
				function()
					local builtin = require("telescope.builtin")
					builtin.diagnostics()
				end,
				desc = "Lists Diagnostics for all open buffers",
			},
			{
				";s",
				function()
					local builtin = require("telescope.builtin")
					builtin.treesitter()
				end,
				desc = "Lists Function names, variables from Treesitter",
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
					local function telescope_buffer_dir()
						return vim.fn.expand("%:p:h")
					end
					telescope.extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = telescope_buffer_dir(),
						respect_gitignore = false,
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						layout_config = { height = 40 },
					})
				end,
				desc = "Open File Browser with the path of the current buffer",
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = telescope.extensions.file_browser.actions

			-- Default configurations
			opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
				wrap_results = true,
				layout_strategy = "horizontal",
				layout_config = {
					prompt_position = "top",
					preview_width = 0.55,
					width = 0.87,
					height = 0.80,
				},
				sorting_strategy = "ascending",
				winblend = 0,
				mappings = {
					n = {},
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
			})

			-- Picker-specific configurations
			opts.pickers = {
				diagnostics = {
					theme = "ivy",
					initial_mode = "normal",
					layout_config = {
						preview_cutoff = 9999,
					},
				},
				find_files = {
					hidden = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			}

			-- Extension configurations
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
						["n"] = {
							["N"] = fb_actions.create,
							["h"] = fb_actions.goto_parent_dir,
							["<C-u>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_previous(prompt_bufnr)
								end
							end,
							["<C-d>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_next(prompt_bufnr)
								end
							end,
						},
					},
				},
			}

			telescope.setup(opts)

			-- Load extensions
			telescope.load_extension("fzf")
			telescope.load_extension("file_browser")
		end,
	},
}
