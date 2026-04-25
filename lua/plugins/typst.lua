return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "tinymist" })
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				tinymist = {
					autostart = true,
					settings = {
						exportPdf = "onSave",
						outputPath = "$root/$name",
						formatterMode = "typstyle",
						previewFeature = "enable",
						sysInputs = {},
					},
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern("typst.toml", ".git")(fname)
							or vim.fn.fnamemodify(fname, ":h")
					end,
					on_attach = function(_, bufnr)
						vim.keymap.set("n", "<leader>tp", function()
							vim.lsp.buf.execute_command({
								command = "tinymist.startDefaultPreview",
								arguments = { vim.api.nvim_buf_get_name(bufnr) },
							})
						end, { buffer = bufnr, desc = "Typst: start preview" })

						vim.keymap.set("n", "<leader>tP", function()
							vim.lsp.buf.execute_command({
								command = "tinymist.stopPreview",
								arguments = {},
							})
						end, { buffer = bufnr, desc = "Typst: stop preview" })

						vim.keymap.set("n", "<leader>te", function()
							vim.lsp.buf.execute_command({
								command = "tinymist.exportPdf",
								arguments = { vim.api.nvim_buf_get_name(bufnr) },
							})
						end, { buffer = bufnr, desc = "Typst: export PDF" })

						vim.keymap.set("n", "<leader>ts", function()
							vim.lsp.buf.execute_command({
								command = "tinymist.exportSvg",
								arguments = { vim.api.nvim_buf_get_name(bufnr) },
							})
						end, { buffer = bufnr, desc = "Typst: export SVG" })

						vim.keymap.set("n", "<leader>tv", function()
							local pdf = vim.fn.expand("%:r") .. ".pdf"
							vim.fn.jobstart({ "sioyek", pdf }, { detach = true })
						end, { buffer = bufnr, desc = "Typst: open in sioyek" })
					end,
				},
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "typst" })
		end,
	},

	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.typst = { "typstyle" }
			opts.formatters = opts.formatters or {}
			opts.formatters.typstyle = {
				command = "typstyle",
				args = { "-" },
				stdin = true,
			}
		end,
	},
}
