return {
	{
		"sphamba/smear-cursor.nvim",
		enabled = false,
	},
	{
		"nvimdev/dashboard-nvim",
		enabled = false,
	},
	{
		"nvim-lualine/lualine.nvim",
		enabled = true,
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 5000,
			background_colour = "#000000",
			render = "wrapped-compact",
		},
	},

	-- buffer line (disabled, using native buffer keymaps instead)
	{
		"akinsho/bufferline.nvim",
		enabled = false,
	},

	-- filename
	{
		"b0o/incline.nvim",
		dependencies = {},
		event = "BufReadPre",
		priority = 1200,
		config = function()
			require("incline").setup({
				window = {
					padding = 0,
					margin = { horizontal = 0 },
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					local ft_icon = require("nvim-web-devicons").get_icon(filename)
					local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
					local bg = normal.bg or 0x000000
					local fg = normal.fg or 0xffffff
					local modified = vim.bo[props.buf].modified
					local buffer = {
						ft_icon and { " ", ft_icon, " ", guibg = bg, guifg = fg } or "",
						" ",
						{ filename, gui = modified and "bold,italic" or "bold" },
						" ",
						guibg = bg,
					}
					return buffer
				end,
			})
		end,
	},
	-- LazyGit integration with Telescope
	{
		"kdheepak/lazygit.nvim",
		keys = {
			{
				";c",
				":LazyGit<Return>",
				silent = true,
				noremap = true,
			},
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		keys = {
			{
				"<leader>d",
				"<cmd>tabnew<cr><bar><bar><cmd>DBUI<cr>",
			},
		},
	},
}
