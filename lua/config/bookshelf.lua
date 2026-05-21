local M = {}
local Path = require("plenary.path")

function M.vault_root()
  local root = vim.fs.find(".obsidian", { path = vim.uv.cwd(), upward = true, type = "directory", limit = 1 })[1]
  return root and vim.fs.dirname(root)
end

function M.books_dir()
  local root = M.vault_root()
  if not root then return nil end
  local dir = vim.fs.joinpath(root, "Books")
  if vim.fn.isdirectory(dir) ~= 1 then vim.fn.mkdir(dir, "p") end
  return dir
end

function M.covers_dir()
  local dir = vim.fs.joinpath(M.books_dir(), "covers")
  if vim.fn.isdirectory(dir) ~= 1 then vim.fn.mkdir(dir, "p") end
  return dir
end

function M.db_path()
  return vim.fs.joinpath(M.books_dir(), ".bookshelf.json")
end

-- slug from filename
local function slug(name)
  local s = name:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  return s
end

-- load db
function M.load_db()
  local dbp = M.db_path()
  if vim.fn.filereadable(dbp) == 1 then
    local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(dbp), "\n"))
    if ok and type(data) == "table" then return data end
  end
  return { books = {} }
end

function M.save_db(db)
  vim.fn.writefile(vim.fn.json_encode(db):gsub("},", "},\n"):gsub("^%[", "[\n"):gsub("%]$", "\n]"):gsub("%[{%s*\n", "[{"):gsub("}\n%]$", "}]"), M.db_path())
  -- cleaner write
  local ok, encoded = pcall(vim.fn.json_encode, db)
  if ok then
    local pretty = vim.fn.json_decode(encoded)
    vim.fn.writefile(vim.split(vim.fn.json_encode(pretty), "\n"), M.db_path())
  end
end

-- extract cover from pdf using imagemagick
function M.extract_cover(pdf_path, book_id)
  local cover_path = vim.fs.joinpath(M.covers_dir(), book_id .. ".png")
  if vim.fn.filereadable(cover_path) == 1 then return cover_path end
  local cmd = { "magick", "-density", "150", pdf_path .. "[0]", "-quality", "85", "-resize", "400x600", "-background", "white", "-flatten", cover_path }
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Cover extraction failed for " .. book_id .. ": " .. (result or ""), vim.log.levels.WARN)
    return nil
  end
  return cover_path
end

-- extract all covers
function M.extract_all_covers()
  local entries = M.scan_pdfs()
  local count = 0
  for _, entry in ipairs(entries) do
    if M.extract_cover(entry.path, entry.id) then count = count + 1 end
  end
  vim.notify("Extracted " .. count .. "/" .. #entries .. " covers", vim.log.levels.INFO)
end

function M.scan_pdfs()
  local books_dir = M.books_dir()
  if not books_dir then return {} end
  local pdfs = vim.fn.globpath(books_dir, "**/*.pdf", false, true)
  local entries = {}
  for _, pdf in ipairs(pdfs) do
    local basename = vim.fs.basename(pdf):gsub("%.pdf$", "", 1)
    local id = slug(basename)
    local rel = vim.fn.fnamemodify(pdf, ":~:.")
    local size = vim.fn.getfsize(pdf)
    local size_str = size >= 1048576 and string.format("%.1f MB", size / 1048576) or (size >= 1024 and string.format("%.0f KB", size / 1024) or size .. " B")
    local mtime = vim.fn.getftime(pdf)
    local date = mtime > 0 and os.date("%Y-%m-%d", mtime) or "unknown"
    table.insert(entries, {
      path = pdf,
      rel = rel,
      id = id,
      name = basename,
      size = size_str,
      date = date,
    })
  end
  table.sort(entries, function(a, b) return a.name:lower() < b.name:lower() end)
  return entries
end

-- sync db with actual pdfs
function M.sync_db()
  local pdfs = M.scan_pdfs()
  local db = M.load_db()
  local book_map = {}
  for _, b in ipairs(db.books) do book_map[b.id] = b end

  for _, pdf in ipairs(pdfs) do
    if not book_map[pdf.id] then
      local cover_rel = "covers/" .. pdf.id .. ".png"
      table.insert(db.books, {
        id = pdf.id,
        pdf = pdf.rel,
        cover = cover_rel,
        name = pdf.name:gsub("%-", " "):gsub("_", " "),
        description = "",
        added = pdf.date,
      })
    else
      -- update path if moved
      book_map[pdf.id].pdf = pdf.rel
    end
  end

  -- remove books whose pdf no longer exists
  local pdf_ids = {}
  for _, pdf in ipairs(pdfs) do pdf_ids[pdf.id] = true end
  db.books = vim.tbl_filter(function(b) return pdf_ids[b.id] end, db.books)

  table.sort(db.books, function(a, b) return a.name:lower() < b.name:lower() end)
  M.save_db(db)
  M.extract_all_covers()
  return db
end

-- set book description
function M.set_description(book_id)
  local db = M.load_db()
  for _, book in ipairs(db.books) do
    if book.id == book_id then
      local desc = vim.fn.input("Description for '" .. book.name .. "': ", book.description or "")
      if desc then
        book.description = desc
        M.save_db(db)
        vim.notify("Description updated", vim.log.levels.INFO)
      end
      return
    end
  end
  vim.notify("Book not found: " .. book_id, vim.log.levels.ERROR)
end

function M.generate_bookshelf()
  local db = M.sync_db()
  local root = M.vault_root()
  if not root then vim.notify("No vault found", vim.log.levels.ERROR) return end

  local bs_path = vim.fs.joinpath(root, "Books", "Bookshelf.md")
  local lines = {}
  table.insert(lines, "---")
  table.insert(lines, "date: " .. os.date("%Y-%m-%d"))
  table.insert(lines, "class: bookshelf")
  table.insert(lines, "tags:")
  table.insert(lines, "  - bookshelf")
  table.insert(lines, "  - books")
  table.insert(lines, "  - catalog")
  table.insert(lines, "status: live")
  table.insert(lines, "cssclass: bookshelf")
  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, "# Bookshelf")
  table.insert(lines, "")
  table.insert(lines, "> `:ObsidianFollowLink` / `<CR>` on a book title to open it in sioyek")
  table.insert(lines, "")

  if #db.books == 0 then
    table.insert(lines, "_No PDFs found in the Books directory._")
  else
    table.insert(lines, "| # | Cover | Book | Size | Added |")
    table.insert(lines, "|---|-------|------|------|-------|")
    for i, book in ipairs(db.books) do
      local cover_tag = "![" .. book.name .. "](<" .. book.cover .. ">)"
      local link = "[" .. book.name .. "](<" .. book.pdf .. ">)"
      local desc = (book.description and book.description ~= "") and ("<br><small>" .. book.description .. "</small>") or ""
      table.insert(lines, string.format("| %d | %s | %s%s | %s | %s |", i, cover_tag, link, desc, book.size, book.added))
    end
  end
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, "Update with `:BookshelfRefresh` | Set desc with `:BookshelfDesc <id>`")
  table.insert(lines, "")

  vim.fn.writefile(vim.split(table.concat(lines, "\n"), "\n"), bs_path)
  vim.notify("Bookshelf updated: " .. #db.books .. " books", vim.log.levels.INFO)
end

-- === SIOYEK ===
function M.resolve_pdf_path(path)
  if not path or path == "" then return nil end
  if path:sub(1, 1) == "/" then return path end
  local root = M.vault_root()
  if not root then return nil end
  local abs = vim.fs.joinpath(root, path)
  if vim.fn.filereadable(abs) == 1 then return abs end
  return nil
end

function M.open_pdf_in_sioyek(path)
  local full = M.resolve_pdf_path(path)
  if not full then
    vim.notify("PDF not found: " .. tostring(path), vim.log.levels.ERROR)
    return
  end
  vim.fn.jobstart({ "sioyek", full }, { detach = true })
end

function M.follow_func(url)
  if url:match("%.pdf$") or url:match("^file://.*%.pdf$") then
    M.open_pdf_in_sioyek(url:gsub("^file://", ""))
    return true
  end
  return false
end

function M.open_pdf_under_cursor()
  local line = vim.fn.getline(".")
  for name, path in line:gmatch("%[([^%]]+)%]%b<>") do
    if path:match("%.pdf$") then
      M.open_pdf_in_sioyek(path)
      return
    end
  end
  local word = vim.fn.expand("<cfile>")
  if word ~= "" and vim.fn.filereadable(word) == 1 then
    M.open_pdf_in_sioyek(word)
    return
  end
  vim.notify("No PDF link under cursor", vim.log.levels.INFO)
end

-- === TELESCOPE PICKER ===
function M.picker()
  local has_telescope, telescope = pcall(require, "telescope")
  if not has_telescope then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  local db = M.sync_db()
  if #db.books == 0 then
    vim.notify("No books in database", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local state = require("telescope.state")

  local display_data = {}
  for _, book in ipairs(db.books) do
    local desc = (book.description and book.description ~= "") and ("  " .. book.description) or ""
    table.insert(display_data, {
      book = book,
      display = book.name .. "  [" .. book.size .. "]" .. desc,
      ordinal = book.name .. " " .. (book.description or ""),
    })
  end

  pickers.new({}, {
    prompt_title = " Bookshelf ",
    finder = finders.new_table {
      results = display_data,
      entry_maker = function(entry)
        return {
          value = entry.book,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.open_pdf_in_sioyek(selection.value.pdf)
        end
      end)
      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.set_description(selection.value.id)
        end
      end)
      map("i", "<C-o>", function()
        actions.close(prompt_bufnr)
        require("config.bookshelf").generate_bookshelf()
      end)
      return true
    end,
  }):find()
end

return M