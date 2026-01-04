return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- Swift Language Server
				sourcekit = {
					autostart = true,
					cmd = {
						"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
					},
					root_dir = function(fname)
						local util = require("lspconfig.util")
						return util.root_pattern("buildServer.json")(fname)
							or util.root_pattern("*.xcodeproj", "*.xcworkspace")(fname)
							or util.root_pattern("compile_commands.json", "Package.swift")(fname)
							or util.find_git_ancestor(fname)
					end,
					filetypes = { "swift", "objc", "objcpp" },
					single_file_support = true,
					settings = {},
					capabilities = {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					},
				},
			},
		},
	},
}
