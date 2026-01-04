return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
	},
	config = function()
		local dap = require("dap")

		-- Swift/Xcode debugging
		dap.adapters.lldb = {
			type = "executable",
			command = "lldb-vscode",
			name = "lldb",
		}

		dap.configurations.swift = {
			{
				name = "Attach to Xcode debugger",
				type = "lldb",
				request = "attach",
				pid = "${command:pickProcess}",
				stopOnEntry = false,
				waitForTargetTime = 1000,
				console = "integratedTerminal",
			},
		}
	end,
	keys = {
		{
			"<leader>b",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dd",
			function()
				require("dap").continue()
			end,
			desc = "Continue Debugging",
		},
		{
			"<leader>ds",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>dx",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate Debugger",
		},
	},
}
