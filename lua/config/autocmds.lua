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
    "rust", "python", "py", "c", "cpp", "h", "hpp",
    "swift", "kotlin", "java", "zig",
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
    pcall(function() require("supermaven-nvim.api").clear_suggestion() end)
    pcall(function() require("blink.cmp").hide() end)
  end,
})

require("config.diag-blob").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "yaml", "yml", "typst",
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
