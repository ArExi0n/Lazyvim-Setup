return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			-- Basic keymaps
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon: Add file" })

			vim.keymap.set("n", "<C-p>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon: Toggle menu" })

			-- Navigate to files
			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon: File 1" })

			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon: File 2" })

			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon: File 3" })

			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon: File 4" })

			vim.keymap.set("n", "<C-P>", function()
				harpoon:list():prev()
			end, { desc = "Harpoon: Previous" })

			vim.keymap.set("n", "<C-N>", function()
				harpoon:list():next()
			end, { desc = "Harpoon: Next" })
		end,
	},
	{
		"ThePrimeagen/vim-apm",
		event = "VeryLazy",
		config = function()
			local apm = require("vim-apm")
			apm:setup({})

			-- Optional: Show APM in statusline
			vim.keymap.set("n", "<leader>apm", function()
				print(string.format("APM: %d", apm:get_apm()))
			end, { desc = "Show APM" })
		end,
	},
	-- vim-with-me - Collaborative editing (experimental)
	{
		"ThePrimeagen/vim-with-me",
		cmd = { "WithMe", "WithMeStart", "WithMeStop" },
		config = function()
			-- Auto-configured on load
		end,
	},
	-- Refactoring library
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup()

			vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "Extract function" })
			vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "Extract to file" })
			vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "Extract variable" })
			vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var", { desc = "Inline variable" })
			vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", { desc = "Inline function" })
			vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", { desc = "Extract block" })
			vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", { desc = "Extract block to file" })
		end,
	},
}
