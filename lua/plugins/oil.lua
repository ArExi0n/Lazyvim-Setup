return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Oil" },
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
