local M = {}

local win_id = nil
local buf = nil

local function get_diag_counts(bufnr)
  local diags = vim.diagnostic.get(bufnr)
  local errors = 0
  local warnings = 0
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      errors = errors + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      warnings = warnings + 1
    end
  end
  return errors, warnings
end

local border_hl = "FloatBorder"
local group = vim.api.nvim_create_augroup("DiagBlob", { clear = true })

local function close()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
  end
  win_id = nil
end

function M.update()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if ft == "" or ft == "oil" or ft == "NvimTree" or ft == "neo-tree" then
    return close()
  end

  local errors, warnings = get_diag_counts(bufnr)
  if errors == 0 and warnings == 0 then
    return close()
  end

  local parts = {}
  if errors > 0 then
    table.insert(parts, " " .. errors)
  end
  local text = table.concat(parts, " ")
  local width = vim.fn.strdisplaywidth(text)
  local height = 1
  local pad = 1

  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return
  end

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
  end

  close()

  local opts = {
    relative = "editor",
    width = width + pad * 2,
    height = height,
    row = ui.height - 2,
    col = ui.width - width - pad * 2 - 1,
    style = "minimal",
    border = "none",
    focusable = false,
    zindex = 50,
    noautocmd = true,
  }

  win_id = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep(" ", pad) .. text .. string.rep(" ", pad) })
  vim.api.nvim_set_option_value("winhl", "NormalFloat:NormalFloat", { win = win_id })
end

function M.setup()
  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufEnter", "CursorHold" }, {
    group = group,
    callback = M.update,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = close,
  })
end

return M
