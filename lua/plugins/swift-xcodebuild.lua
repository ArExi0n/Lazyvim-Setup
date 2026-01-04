return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-tree.lua", -- Optional: for file tree integration
		},
		config = function()
			require("xcodebuild").setup({
				-- Restore previous session on startup
				restore_on_start = true,

				-- Auto-save before building
				auto_save = true,

				-- Show build progress notifications
				show_build_progress_bar = true,

				-- Logs configuration
				logs = {
					auto_open_on_success_tests = false,
					auto_open_on_failed_tests = true,
					auto_open_on_success_build = false,
					auto_open_on_failed_build = true,
					auto_focus = true,
					auto_close_on_success = true,
					notify = function(message, severity)
						vim.notify(message, severity)
					end,
				},

				-- Code coverage
				code_coverage = {
					enabled = true,
					file_pattern = "*.swift",
				},

				-- Test explorer
				test_explorer = {
					enabled = true,
					auto_open = true,
					auto_focus = false,
				},

				-- Commands configuration
				commands = {
					cache_devices = true,
				},
			})

			-- Keymaps for Xcodebuild
			local opts = { noremap = true, silent = true }

			-- Build & Run
			vim.keymap.set(
				"n",
				"<leader>xb",
				"<cmd>XcodebuildBuild<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Build Project" })
			)
			vim.keymap.set(
				"n",
				"<leader>xr",
				"<cmd>XcodebuildBuildRun<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Build & Run" })
			)
			vim.keymap.set(
				"n",
				"<leader>xR",
				"<cmd>XcodebuildRun<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Run Without Building" })
			)

			-- Testing
			vim.keymap.set(
				"n",
				"<leader>xt",
				"<cmd>XcodebuildTest<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Run Tests" })
			)
			vim.keymap.set(
				"n",
				"<leader>xT",
				"<cmd>XcodebuildTestClass<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Test Current Class" })
			)
			vim.keymap.set(
				"n",
				"<leader>x.",
				"<cmd>XcodebuildTestSelected<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Test Selected" })
			)

			-- Device & Scheme Selection
			vim.keymap.set(
				"n",
				"<leader>xd",
				"<cmd>XcodebuildSelectDevice<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Select Device" })
			)
			vim.keymap.set(
				"n",
				"<leader>xs",
				"<cmd>XcodebuildSelectScheme<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Select Scheme" })
			)
			vim.keymap.set(
				"n",
				"<leader>xp",
				"<cmd>XcodebuildSelectTestPlan<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Select Test Plan" })
			)

			-- Actions
			vim.keymap.set(
				"n",
				"<leader>xc",
				"<cmd>XcodebuildCleanBuild<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Clean Build" })
			)
			vim.keymap.set(
				"n",
				"<leader>xC",
				"<cmd>XcodebuildCleanDerivedData<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Clean Derived Data" })
			)
			vim.keymap.set(
				"n",
				"<leader>xq",
				"<cmd>XcodebuildCancel<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Cancel Operation" })
			)

			-- Logs & Reports
			vim.keymap.set(
				"n",
				"<leader>xl",
				"<cmd>XcodebuildToggleLogs<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Toggle Logs" })
			)
			vim.keymap.set(
				"n",
				"<leader>xL",
				"<cmd>XcodebuildShowLogs<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Show Logs" })
			)
			vim.keymap.set(
				"n",
				"<leader>xv",
				"<cmd>XcodebuildCodeCoverage<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Code Coverage" })
			)
			vim.keymap.set(
				"n",
				"<leader>xV",
				"<cmd>XcodebuildToggleCodeCoverage<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Toggle Coverage Display" })
			)

			-- Quickfix & Diagnostics
			vim.keymap.set(
				"n",
				"<leader>xf",
				"<cmd>XcodebuildFailingSnapshots<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Show Failing Snapshots" })
			)
			vim.keymap.set(
				"n",
				"<leader>xD",
				"<cmd>XcodebuildQuickfixLine<cr>",
				vim.tbl_extend("force", opts, { desc = "Xcode: Quickfix Current Line" })
			)
		end,
	},
}
