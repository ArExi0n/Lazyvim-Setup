-- Set leader key
vim.g.mapleader = " "

-- Buffer navigation
vim.keymap.set("n", "<C-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-h>", "<Cmd>bprev<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "[b", "<Cmd>bprev<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next buffer" })

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- tab management
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>n", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


-- Plenary test
vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { noremap = false, silent = false })

-- Better scrolling & joins
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")

-- LSP restart
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })

-- Vim With Me
vim.keymap.set("n", "<leader>vwm", function()
	require("vim-with-me").StartVimWithMe()
end, { desc = "Start Vim With Me" })

vim.keymap.set("n", "<leader>svwm", function()
	require("vim-with-me").StopVimWithMe()
end, { desc = "Stop Vim With Me" })

-- Clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- Better escape
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable Ex mode
vim.keymap.set("n", "Q", "<nop>")

-- Tmux helpers
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")

-- Quickfix & location list
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location" })

-- Search & replace word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Go error helpers
vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Insert error check" })
vim.keymap.set("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', { desc = "Insert assert.NoError" })
vim.keymap.set(
	"n",
	"<leader>ef",
	'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
	{ desc = "Insert log.Fatalf" }
)
vim.keymap.set(
	"n",
	"<leader>el",
	'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
	{ desc = "Insert logger.Error" }
)

-- ========================
-- LSP KEYMAPS
-- ========================
vim.keymap.set("n", "gd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>vws", function()
	require("telescope.builtin").lsp_workspace_symbols()
end, { desc = "Workspace symbols" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help" })

vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })

-- Cellular automaton
vim.keymap.set("n", "<leader>ca", function()
	require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Make it rain" })

-- Reload config
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Reload config" })

vim.keymap.set("n", "<leader>tp", function()
	vim.lsp.buf.execute_command({
		command = "tinymist.startDefaultPreview",
		arguments = { vim.api.nvim_buf_get_name(0) },
	})
end, { desc = "Typst: start preview" })

vim.keymap.set("n", "<leader>tP", function()
	vim.lsp.buf.execute_command({
		command = "tinymist.stopPreview",
		arguments = {},
	})
end, { desc = "Typst: stop preview" })

vim.keymap.set("n", "<leader>te", function()
	vim.lsp.buf.execute_command({
		command = "tinymist.exportPdf",
		arguments = { vim.api.nvim_buf_get_name(0) },
	})
end, { desc = "Typst: export PDF" })

vim.keymap.set("n", "<leader>tv", function()
	local pdf = vim.fn.expand("%:r") .. ".pdf"
	if vim.fn.filereadable(pdf) == 1 then
		vim.fn.jobstart({ "sioyek", pdf }, { detach = true })
	else
		vim.notify("PDF not found: " .. pdf, vim.log.levels.ERROR)
	end
end, { desc = "Typst: open in sioyek" })

-- Theme switching
vim.keymap.set("n", "<leader>ts", "<cmd>Theme<CR>", { desc = "Select theme" })
vim.keymap.set("n", "<leader>tn", "<cmd>ThemeNext<CR>", { desc = "Next theme" })

-- ========================
-- OBSIDIAN NOTE CREATION
-- ========================
local fmt_map = {
	["YYYY"] = "%Y",
	["YY"] = "%y",
	["MMMM"] = "%B",
	["MMM"] = "%b",
	["MM"] = "%m",
	["M"] = "%-m",
	["dddd"] = "%A",
	["ddd"] = "%a",
	["DD"] = "%d",
	["D"] = "%-d",
	["HH"] = "%H",
	["H"] = "%-H",
	["hh"] = "%I",
	["h"] = "%-I",
	["mm"] = "%M",
	["ss"] = "%S",
	["A"] = "%p",
	["a"] = "%p",
}

local function vault_root()
	return vim.fs.dirname(
		vim.fs.find(".obsidian", { path = vim.uv.cwd(), upward = true, type = "directory", limit = 1 })[1]
	)
end

local function render_content(content, title)
	local slug = title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-"):gsub("%-+", "-")
	local function fmt(s)
		return s:gsub("%w+", function(m)
			return fmt_map[m] or m
		end)
	end
	local now = os.time()
	for _, pat in ipairs({ "{ date:([^}]+) }", "{ time:([^}]+) }", "{{date:([^}]+)}}", "{{time:([^}]+)}}" }) do
		content = content:gsub(pat, function(f)
			return os.date(fmt(f), now)
		end)
	end
	content = content:gsub("{{title}}", title)
	content = content:gsub("{{slug}}", slug)
	return content
end

local function new_obsidian_note(subdir, template_file, prompt, auto_title)
	return function()
		local title = auto_title or vim.fn.input(prompt .. ": ")
		if title == "" then
			return
		end
		local root = vault_root()
		if not root then
			vim.notify("No vault found", vim.log.levels.ERROR)
			return
		end

		local slug = title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-"):gsub("%-+", "-")
		local filepath = vim.fs.joinpath(root, subdir, slug .. ".md")
		if vim.fn.filereadable(filepath) == 1 then
			vim.cmd("edit " .. filepath)
			return
		end

		local tpl_path = vim.fs.joinpath(root, "Extra", "Template", template_file)
		local content
		if vim.fn.filereadable(tpl_path) == 1 then
			content = render_content(table.concat(vim.fn.readfile(tpl_path), "\n"), title)
		else
			content = "---\ntags: []\n---\n\n# " .. title
		end

		vim.fn.mkdir(vim.fs.dirname(filepath), "p")
		vim.fn.writefile(vim.split(content, "\n"), filepath)
		vim.cmd("edit " .. filepath)
	end
end

vim.keymap.set("n", "<leader>on", new_obsidian_note("Notes", "notes.md", "Note title"), { desc = "New note in Notes" })
vim.keymap.set(
	"n",
	"<leader>oj",
	new_obsidian_note("Journal", "journal.md", nil, os.date("%Y-%m-%d")),
	{ desc = "New journal entry" }
)
vim.keymap.set("n", "<leader>op", new_obsidian_note("Extra", "projects.md", "Project title"), { desc = "New project" })
vim.keymap.set("n", "<leader>obk", new_obsidian_note("Books", "book-note.md", "Book title"), { desc = "New book note" })
vim.keymap.set("n", "<leader>ou", new_obsidian_note("Uni", "uni-note.md", "Note title"), { desc = "New uni note" })

-- ========================
-- USER COMMANDS
-- ========================
vim.api.nvim_create_user_command("Bookshelf", function()
	require("config.bookshelf").picker()
end, { desc = "Browse bookshelf" })
vim.api.nvim_create_user_command("BookshelfRefresh", function()
	require("config.bookshelf").generate_bookshelf()
end, { desc = "Refresh bookshelf catalog" })
vim.api.nvim_create_user_command("BookshelfOpen", function(opts)
	require("config.bookshelf").open_pdf_in_sioyek(opts.args)
end, { nargs = 1, desc = "Open PDF in sioyek" })

-- ========================
-- BOOKSHELF
-- ========================
vim.keymap.set("n", "<leader>bb", function()
	require("config.bookshelf").picker()
end, { desc = "Bookshelf: browse books (Telescope)" })
vim.keymap.set("n", "<leader>bc", function()
	require("config.bookshelf").generate_bookshelf()
end, { desc = "Bookshelf: refresh catalog & covers" })
vim.keymap.set("n", "<leader>bo", function()
	require("config.bookshelf").open_pdf_under_cursor()
end, { desc = "Bookshelf: open PDF under cursor" })
vim.keymap.set("n", "<leader>bO", function()
	require("config.bookshelf").open_pdf_in_sioyek(vim.fn.expand("%:p"))
end, { desc = "Bookshelf: open current file in sioyek" })
vim.keymap.set("n", "<leader>bm", "<cmd>e Books/Bookshelf.md<CR>", { desc = "Bookshelf: open markdown catalog" })

-- Book description editing (prompts for book id)
vim.keymap.set("n", "<leader>bd", function()
	local db = require("config.bookshelf").load_db()
	if #db.books == 0 then
		vim.notify("No books", vim.log.levels.INFO)
		return
	end
	local items = vim.tbl_map(function(b)
		return b.id .. "  (" .. b.name .. ")"
	end, db.books)
	vim.ui.select(items, { prompt = "Select book to describe:" }, function(choice)
		if not choice then
			return
		end
		local id = choice:match("^(%S+)")
		if id then
			require("config.bookshelf").set_description(id)
		end
	end)
end, { desc = "Bookshelf: edit book description" })
