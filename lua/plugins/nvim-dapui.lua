return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	lazy = true,

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- UI SETUP

		dapui.setup({
			controls = {
				element = "repl",
				enabled = true,
				icons = {
					disconnect = "",
					run_last = "",
					terminate = "⏹︎",
					pause = "⏸︎",
					play = "",
					step_into = "󰆹",
					step_out = "󰆸",
					step_over = "",
					step_back = "",
				},
			},

			floating = {
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},

			icons = {
				collapsed = "",
				expanded = "",
				current_frame = "",
			},

			layouts = {
				{
					elements = {
						{ id = "stacks", size = 0.25 },
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					position = "left",
					size = 40,
				},
				{
					elements = {
						{ id = "repl", size = 0.4 },
						{ id = "console", size = 0.6 },
					},
					position = "bottom",
					size = 10,
				},
			},
		})

		-- AUTOCMDS

		local group = vim.api.nvim_create_augroup("dapui_config", { clear = true })

		-- Hide ~ in DAP UI buffers
		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = group,
			pattern = "DAP*",
			callback = function()
				vim.wo.fillchars = "eob: "
			end,
		})

		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = group,
			pattern = "\\[dap\\-repl\\]",
			callback = function()
				vim.wo.fillchars = "eob: "
			end,
		})

		-- AUTO OPEN / CLOSE UI

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- KEYMAPS

		vim.keymap.set("n", "<leader>du", dapui.toggle, {
			desc = "DAP UI toggle",
		})

		-- Add watch
		vim.keymap.set("n", "<leader>dw", function()
			local expr = vim.fn.input("Watch expression: ")
			if expr ~= "" then
				dapui.elements.watches.add(expr)
			end
		end, {
			desc = "DapUI add watch",
		})

		-- Remove selected watch
		vim.keymap.set("n", "<leader>dW", function()
			dapui.elements.watches.remove()
		end, {
			desc = "DapUI remove watch",
		})

		-- Clear all watches
		vim.keymap.set("n", "<leader>dC", function()
			dapui.elements.watches.clear()
		end, {
			desc = "DapUI clear watches",
		})
	end,
}
