-- Swift-specific keymaps
-- These are automatically loaded when you open a Swift file

local function setup_swift_keymaps()
	local opts = { buffer = true, noremap = true, silent = true }

	-- Quick access to Swift documentation
	vim.keymap.set("n", "<leader>sd", function()
		local word = vim.fn.expand("<cword>")
		vim.cmd("!open dash://swift:" .. word)
	end, vim.tbl_extend("force", opts, { desc = "Swift: Search in Dash" }))

	-- Open Swift Package Manager
	vim.keymap.set("n", "<leader>sp", function()
		vim.cmd("e Package.swift")
	end, vim.tbl_extend("force", opts, { desc = "Swift: Open Package.swift" }))

	-- Create new Swift file
	vim.keymap.set("n", "<leader>sf", function()
		local filename = vim.fn.input("New Swift file name: ")
		if filename ~= "" then
			if not filename:match("%.swift$") then
				filename = filename .. ".swift"
			end
			vim.cmd("e " .. filename)
		end
	end, vim.tbl_extend("force", opts, { desc = "Swift: New Swift File" }))

	-- Print statement shortcut
	vim.keymap.set(
		"n",
		"<leader>sp",
		"oprint()<Esc>i",
		vim.tbl_extend("force", opts, { desc = "Swift: Insert print()" })
	)

	-- Debug print with file and line
	vim.keymap.set(
		"n",
		"<leader>sP",
		'oprint("DEBUG: \\(#file):\\(#line)")<Esc>0f"a',
		vim.tbl_extend("force", opts, { desc = "Swift: Insert debug print" })
	)
end

-- Auto-setup Swift keymaps for Swift files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "swift",
	callback = setup_swift_keymaps,
	desc = "Setup Swift-specific keymaps",
})

-- Additional Swift file type settings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "swift",
	callback = function()
		-- Set tab width to 4 for Swift (Apple's convention)
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true

		-- Enable spell check for comments
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
	desc = "Swift file settings",
})
