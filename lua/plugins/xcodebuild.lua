return {
	"wojciech-kulik/xcodebuild. nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("xcodebuild").setup({
			-- Configuration for xcodebuild
			show_build_progress_bar = true,
		})
	end,
	keys = {
		{ "<leader>X", "<cmd>XcodebuildPicker<cr>", desc = "Xcode Actions" },
		{ "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Build" },
		{ "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },
		{ "<leader>xt", "<cmd>XcodebuildTest<cr>", desc = "Run Tests" },
		{ "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Logs" },
		{ "<leader>xc", "<cmd>XcodebuildToggleCoverage<cr>", desc = "Toggle Coverage" },
	},
}
