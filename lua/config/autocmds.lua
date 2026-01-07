local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local function start_sourcekit(root_dir)
	if not root_dir then
		return
	end

	-- Check if already running for this root
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "sourcekit" and client.config.root_dir == root_dir then
			return
		end
	end

	local cmd = vim.fn.trim(vim.fn.system("xcrun -f sourcekit-lsp 2>/dev/null"))
	if cmd == "" then
		cmd = "sourcekit-lsp"
	end

	vim.lsp.start({
		name = "sourcekit",
		cmd = { cmd },
		root_dir = root_dir,
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		on_init = function(client)
			client.offset_encoding = "utf-8"
		end,
	})
end

local function attach_swift(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	if fname == "" then
		return
	end

	local root = util.root_pattern("Package.swift", ".xcodeproj", ".xcworkspace", ".git")(fname)

	start_sourcekit(root)

	vim.defer_fn(function()
		vim.lsp.buf_attach_client(bufnr, vim.lsp.get_clients({ name = "sourcekit" })[1].id)
	end, 300)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = "*.swift",
	callback = function(ev)
		attach_swift(ev.buf)
	end,
})
