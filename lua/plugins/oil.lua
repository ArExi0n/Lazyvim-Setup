return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Oil" },
		keys = {
			{
				"<leader>e",
				function()
					if vim.bo.filetype == "oil" then
						local prev = vim.g.oil_prev_buf
						if prev and vim.api.nvim_buf_is_valid(prev) then
							vim.api.nvim_win_set_buf(0, prev)
							return
						end
						vim.cmd("b#")
					else
						vim.g.oil_prev_buf = vim.api.nvim_get_current_buf()
						local dir = vim.fn.expand("%:p:h")
						if dir == "" then dir = vim.fn.getcwd() end
						require("oil").open(dir)
					end
				end,
				desc = "Toggle file explorer",
			},
		},
		opts = {
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<C-p>"] = false,
				["<C-c>"] = false,
			},
		},
	},
}
