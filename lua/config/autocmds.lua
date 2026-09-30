-- SourceKit-LSP is now managed by lspconfig in lua/plugins/lsp.lua
-- xcodebuild.nvim handles xcode_build_server integration for build settings

-- Auto-reload buffers when changed externally (e.g. from Obsidian)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		vim.cmd("checktime")
	end,
})

-- Per-filetype indentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"rust",
		"python",
		"py",
		"c",
		"cpp",
		"h",
		"hpp",
		"swift",
		"kotlin",
		"java",
		"zig",
	},
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.expandtab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go" },
	callback = function()
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.softtabstop = 4
		vim.bo.expandtab = false
	end,
})

-- Clear AI ghost text when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		pcall(function()
			require("copilot.suggestion").dismiss()
		end)
		pcall(function()
			require("supermaven-nvim.api").clear_suggestion()
		end)
		pcall(function()
			require("blink.cmp").hide()
		end)
	end,
})

-- Apply transparent backgrounds on every colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		require("config.transparent").apply()
	end,
})

require("config.diag-blob").setup()
require("config.snippet").setup()

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"yaml",
		"yml",
		"typst",
	},
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.expandtab = true
	end,
})

-- Typst template (vault Extra/Template/typst.typ): new *.typ files are
-- prefilled, plus :TypstTemplate and literal `:r typst.typ` from any cwd.
-- Registered here (startup) so it also applies to the file passed on the
-- command line; setup is idempotent so VeryLazy/obsidian re-calls are safe.
pcall(function()
	require("config.obsidian").setup_typst_template()
end)
