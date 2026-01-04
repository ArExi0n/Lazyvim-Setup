return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			sourcekit = {
				filetypes = { "swift", "objective-c", "objective-cpp" },
				cmd = {
					"sourcekit-lsp",
				},
				root_dir = require("lspconfig.util").root_pattern("Package.swift", ". git", "*. xcodeproj"),
				single_file_support = true,
			},
		},
	},
}
