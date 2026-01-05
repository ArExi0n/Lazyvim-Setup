return {
	{
		"folke/neoconf.nvim",
		cmd = "Neoconf",
		priority = 1000, -- Load before LSP
		config = function()
			require("neoconf").setup({
				-- Import existing settings
				import = {
					vscode = true, -- .vscode/settings.json
					coc = false,
					nlsp = false,
				},
				-- Auto-reload on config changes
				live_reload = true,
				-- Enable for JSONC files
				filetype_jsonc = true,
				-- Plugin integrations
				plugins = {
					lspconfig = {
						enabled = true,
					},
					jsonls = {
						enabled = true,
						configured_servers_only = false,
					},
					lua_ls = {
						enabled = true,
						enabled_for_neovim_config = true,
					},
				},
			})
		end,
	},
}
