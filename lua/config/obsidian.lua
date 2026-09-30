local M = {}

local function expand(path)
	return vim.fn.expand(path)
end

local function env_or(name, fallback)
	local value = vim.env[name]

	if value ~= nil and value ~= "" then
		return expand(value)
	end

	return expand(fallback)
end

local function is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

local function normalize_workspace(workspace)
	if type(workspace) ~= "table" or type(workspace.path) ~= "string" then
		return nil
	end

	local normalized = vim.deepcopy(workspace)
	normalized.path = expand(normalized.path)

	if not is_dir(normalized.path) then
		return nil
	end

	if type(normalized.name) ~= "string" or normalized.name == "" then
		normalized.name = vim.fs.basename(normalized.path)
	end

	return normalized
end

local function detect_vault_root()
	local candidates = {
		vim.api.nvim_buf_get_name(0),
		vim.uv.cwd(),
	}

	for _, candidate in ipairs(candidates) do
		if type(candidate) == "string" and candidate ~= "" then
			local start = candidate

			if vim.fn.filereadable(start) == 1 then
				start = vim.fs.dirname(start)
			end

			local root = vim.fs.find(".obsidian", {
				path = start,
				upward = true,
				type = "directory",
				limit = 1,
			})[1]

			if root then
				return vim.fs.dirname(root)
			end
		end
	end

	return nil
end

local function disable_markdown_treesitter()
	if vim.g.salar_disable_markdown_treesitter then
		return
	end

	vim.g.salar_disable_markdown_treesitter = true

	local original_start = vim.treesitter.start

	vim.treesitter.start = function(bufnr, lang)
		local buffer = bufnr

		if type(buffer) ~= "number" or buffer == 0 then
			buffer = vim.api.nvim_get_current_buf()
		end

		local language = lang

		if type(language) ~= "string" or language == "" then
			if vim.api.nvim_buf_is_valid(buffer) then
				language = vim.bo[buffer].filetype
			end
		end

		local filetype = nil

		if vim.api.nvim_buf_is_valid(buffer) then
			filetype = vim.bo[buffer].filetype
		end

		if language == "markdown" or language == "markdown_inline" or filetype == "markdown" then
			return false
		end

		return original_start(bufnr, lang)
	end
end

local function slugify(text)
	local slug = text:lower()
	slug = slug:gsub("[^a-z0-9%s-]", "")
	slug = slug:gsub("%s+", "-")
	slug = slug:gsub("%-+", "-")
	slug = slug:gsub("^%-", "")
	slug = slug:gsub("%-$", "")

	return slug
end

local function open_with_system(path)
	if vim.ui.open then
		vim.ui.open(path)
		return
	end

	vim.fn.jobstart({ "xdg-open", path }, { detach = true })
end

	local function find_daily_template(workspaces)
	for _, workspace in ipairs(workspaces) do
		if type(workspace.path) == "string" then
			local template = vim.fs.joinpath(expand(workspace.path), "Extra", "Template", "journal.md")

			if vim.fn.filereadable(template) == 1 then
				return "Extra/Template/journal.md"
			end
		end
	end

	return nil
end

local function translate_obsidian_datetime_format(format)
	local tokens = {
		{ "YYYY", "%Y" },
		{ "YY", "%y" },
		{ "MMMM", "%B" },
		{ "MMM", "%b" },
		{ "MM", "%m" },
		{ "M", "%-m" },
		{ "dddd", "%A" },
		{ "ddd", "%a" },
		{ "DD", "%d" },
		{ "D", "%-d" },
		{ "HH", "%H" },
		{ "H", "%-H" },
		{ "hh", "%I" },
		{ "h", "%-I" },
		{ "mm", "%M" },
		{ "ss", "%S" },
		{ "A", "%p" },
		{ "a", "__SALAR_OBSIDIAN_LOWER_AMPM__" },
	}

	local chunks = {}
	local i = 1

	while i <= #format do
		local char = format:sub(i, i)

		if char == "[" then
			local close_idx = format:find("]", i + 1, true)

			if close_idx then
				chunks[#chunks + 1] = format:sub(i + 1, close_idx - 1)
				i = close_idx + 1
			else
				chunks[#chunks + 1] = char
				i = i + 1
			end
		else
			local matched = false

			for _, token in ipairs(tokens) do
				local source, target = token[1], token[2]

				if format:sub(i, i + #source - 1) == source then
					chunks[#chunks + 1] = target
					i = i + #source
					matched = true
					break
				end
			end

			if not matched then
				chunks[#chunks + 1] = char
				i = i + 1
			end
		end
	end

	return table.concat(chunks)
end

local function render_obsidian_datetime(format, time)
	time = time or os.time()
	local strftime_format = translate_obsidian_datetime_format(format)
	local rendered = os.date(strftime_format, time)

	return rendered:gsub("__SALAR_OBSIDIAN_LOWER_AMPM__", function()
		return os.date("%p", time):lower()
	end)
end

function M.patch_template_substitutions()
	if vim.g.salar_obsidian_template_patch_applied then
		return
	end

	local ok, templates = pcall(require, "obsidian.templates")

	if not ok then
		return
	end

	local original = templates.substitute_template_variables

	templates.substitute_template_variables = function(text, client, note)
		local now = os.time()
		text = text:gsub("{{date:([^}]+)}}", function(format)
			return render_obsidian_datetime(format, now)
		end)
		text = text:gsub("{{time:([^}]+)}}", function(format)
			return render_obsidian_datetime(format, now)
		end)
		text = text:gsub("{ date:([^}]+) }", function(format)
			return render_obsidian_datetime(format, now)
		end)
		text = text:gsub("{ time:([^}]+) }", function(format)
			return render_obsidian_datetime(format, now)
		end)

		return original(text, client, note)
	end

	vim.g.salar_obsidian_template_patch_applied = true
end

function M.setup_markdown_buffer(bufnr)
	disable_markdown_treesitter()

	local opt = vim.opt_local

	opt.wrap = true
	opt.linebreak = true
	opt.conceallevel = 0
	opt.concealcursor = ""
	opt.spell = true
	opt.textwidth = 100

	pcall(vim.treesitter.stop, bufnr)

	vim.api.nvim_buf_call(bufnr, function()
		vim.opt_local.formatoptions:append({ "n", "2" })
		vim.opt_local.formatoptions:remove("t")
	end)
end

function M.workspaces()
	if type(vim.g.obsidian_workspaces) == "table" and #vim.g.obsidian_workspaces > 0 then
		local workspaces = {}

		for _, workspace in ipairs(vim.g.obsidian_workspaces) do
			local normalized = normalize_workspace(workspace)

			if normalized then
				workspaces[#workspaces + 1] = normalized
			end
		end

		if #workspaces > 0 then
			return workspaces
		end
	end

	local workspaces = {
		{
			name = "personal",
			path = env_or("OBSIDIAN_VAULT_PERSONAL", "~/Projects/Notes/Obsidian Vault"),
		},
	}

	local existing = {}
	local seen = {}

	for _, workspace in ipairs(workspaces) do
		local normalized = normalize_workspace(workspace)

		if normalized and not seen[normalized.path] then
			seen[normalized.path] = true
			existing[#existing + 1] = normalized
		end
	end

	local detected_root = detect_vault_root()

	if detected_root and not seen[detected_root] then
		existing[#existing + 1] = {
			name = vim.fs.basename(detected_root),
			path = detected_root,
		}
	end

	return existing
end

function M.opts()
	local workspaces = M.workspaces()

	return {
		workspaces = workspaces,
		notes_subdir = "notes",
		new_notes_location = "notes_subdir",
		preferred_link_style = "wiki",
		sort_by = "modified",
		sort_reversed = true,
		open_notes_in = "current",
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		daily_notes = {
			folder = "Journal",
			date_format = "%Y-%m-%d",
			alias_format = "%A, %B %-d, %Y",
			default_tags = { "daily", "journal" },
		},
		templates = {
			folder = "Extra/Template",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			substitutions = {
				weekday = function()
					return os.date("%A")
				end,
				cursor = function()
					return "<++>"
				end,
			},
		},
		note_id_func = function(title)
			local suffix = title and slugify(title) or ""

			if suffix == "" then
				suffix = tostring(os.time())
			end

			return string.format("%s-%s", os.date("%Y%m%d-%H%M"), suffix)
		end,
		note_frontmatter_func = function(note)
			if note.title then
				note:add_alias(note.title)
			end

			local out = {
				id = note.id,
				aliases = note.aliases,
				tags = note.tags,
			}

			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for key, value in pairs(note.metadata) do
					out[key] = value
				end
			end

			return out
		end,
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<CR>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
			["<leader>oc"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true, desc = "Toggle checkbox" },
			},
		},
		picker = {
			name = "telescope.nvim",
			note_mappings = {
				new = "<C-x>",
				insert_link = "<C-l>",
			},
			tag_mappings = {
				tag_note = "<C-x>",
				insert_tag = "<C-l>",
			},
		},
		attachments = {
			img_folder = "assets/imgs",
			img_name_func = function()
				return string.format("%s-", os.date("%Y%m%d-%H%M%S"))
			end,
		},
		follow_url_func = function(url)
			local bookshelf = require("config.bookshelf")
			if bookshelf.follow_func(url) then return end
			open_with_system(url)
		end,
		follow_img_func = open_with_system,
		ui = {
			enable = false,
			update_debounce = 200,
			max_file_length = 5000,
			bullets = { char = "•", hl_group = "ObsidianBullet" },
			external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			hl_groups = {
				ObsidianTodo = { bold = true, fg = "#f78c6c" },
				ObsidianDone = { bold = true, fg = "#89ddff" },
				ObsidianRightArrow = { bold = true, fg = "#ffcb6b" },
				ObsidianTilde = { bold = true, fg = "#c3e88d" },
				ObsidianImportant = { bold = true, fg = "#ff5370" },
				ObsidianBullet = { bold = true, fg = "#82aaff" },
				ObsidianExtLinkIcon = { fg = "#89ddff" },
			},
		},
		callbacks = {
			enter_note = function()
				M.setup_markdown_buffer(0)
			end,
		},
	}
end

--- Absolute path to Extra/Template/typst.typ in the first workspace that has it.
---@return string|nil
function M.typst_template_path()
	for _, workspace in ipairs(M.workspaces()) do
		if type(workspace.path) == "string" then
			local candidate = vim.fs.joinpath(expand(workspace.path), "Extra", "Template", "typst.typ")
			if vim.fn.filereadable(candidate) == 1 then
				return candidate
			end
		end
	end
	return nil
end

--- Insert typst.typ template into current buffer.
--- If the buffer is empty it replaces the empty line, otherwise inserts below cursor.
function M.insert_typst_template()
	local template = M.typst_template_path()
	if not template then
		vim.notify("typst.typ template not found in Extra/Template", vim.log.levels.ERROR)
		return
	end
	local lines = vim.fn.readfile(template)
	if #lines == 0 then
		vim.notify("typst.typ template is empty", vim.log.levels.WARN)
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	-- Empty buffer (single empty line): replace it so we don't leave a leading blank line.
	if line_count == 1 and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == "" then
		vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, lines)
		vim.api.nvim_win_set_cursor(0, { #lines, 0 })
	else
		vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
		vim.api.nvim_win_set_cursor(0, { row + #lines, 0 })
	end
end

--- Wire up :TypstTemplate, BufNewFile *.typ and `:r typst.typ` expansion.
function M.setup_typst_template()
	if vim.g.salar_typst_template_setup then
		return
	end
	vim.g.salar_typst_template_setup = true

	vim.api.nvim_create_user_command("TypstTemplate", function()
		M.insert_typst_template()
	end, { desc = "Insert Extra/Template/typst.typ" })

	-- New *.typ files start from the template (BufNewFile only, so existing files are untouched).
	local group = vim.api.nvim_create_augroup("salar-typst-template", { clear = true })
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = group,
		pattern = "*.typ",
		callback = function()
			-- Only prefill empty new buffers.
			if vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" then
				M.insert_typst_template()
			end
		end,
	})

	-- Make the literal `:r typst.typ` work from any cwd by rewriting it to the
	-- vault template on <CR>. (cnoreabbrev can't be used: its lhs must be
	-- keyword chars, so `typst.typ` with a dot is rejected with E474.)
	vim.keymap.set("c", "<CR>", function()
		if vim.fn.getcmdtype() == ":" then
			local line = vim.fn.getcmdline()
			-- Match `:r typst.typ` / `:read typst.typ` with optional range
			-- (`0r`, `'<,'>r`, `%r`, ...). The `r`/`read` must not be part of
			-- a longer word, but may follow a range char like `0`, `$`, `%`, `'`, `>`, `,`.
			local is_read = line:match("^%s*r%s+typst%.typ%s*$")
				or line:match("[^%a]r%s+typst%.typ%s*$")
				or line:match("^%s*read%s+typst%.typ%s*$")
				or line:match("[^%a]read%s+typst%.typ%s*$")
			if is_read then
				-- Respect a real ./typst.typ in cwd if one exists.
				if vim.fn.filereadable("typst.typ") == 0 then
					local template = M.typst_template_path()
					if template then
						local expanded = line:gsub("typst%.typ%s*$", vim.fn.fnameescape(template))
						vim.fn.setcmdline(expanded)
					end
				end
			end
		end
		return "<CR>"
	end, { expr = true, desc = "Expand :r typst.typ to vault template" })
end

return M
