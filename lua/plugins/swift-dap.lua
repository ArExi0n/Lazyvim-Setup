return {
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			{
				"wojciech-kulik/xcodebuild.nvim",
				opts = {
					-- Xcodebuild configuration will be handled in swift-xcodebuild.lua
				},
			},
		},
		opts = function()
			local dap = require("dap")

			-- Configure LLDB adapter for Swift/iOS debugging
			dap.adapters.lldb = {
				type = "executable",
				command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
				name = "lldb",
			}

			-- Swift debugging configuration
			dap.configurations.swift = {
				{
					name = "iOS App Debugger",
					type = "lldb",
					request = "launch",
					program = function()
						-- This will be populated by xcodebuild.nvim
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
			}
		end,
	},
}
