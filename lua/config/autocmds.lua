-- Auto-start Swift LSP when opening Swift files

local function ensure_sourcekit_for_buf(bufnr)
	local ok, lspconfig = pcall(require, "lspconfig")
	if not ok or not lspconfig or not lspconfig.sourcekit then
		return
	end

	-- If not set up yet → set it up
	if not lspconfig.sourcekit.manager then
		local path = vim.trim(vim.fn.system("xcrun -f sourcekit-lsp 2>/dev/null") or "")
		if path == "" and vim.fn.executable("sourcekit-lsp") == 1 then
			path = "sourcekit-lsp"
		end
		if path == "" then
			return
		end

		lspconfig.sourcekit.setup({
			cmd = { path },
			single_file_support = true,
			on_init = function(client)
				client.offset_encoding = "utf-8"
			end,
		})
	end

	-- Attach to current buffer
	pcall(function()
		lspconfig.sourcekit.manager.try_add(bufnr)
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "swift",
	callback = function(ev)
		ensure_sourcekit_for_buf(ev.buf)
	end,
})
