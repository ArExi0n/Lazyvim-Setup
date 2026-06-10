local function is_cpp_file()
  local ext = vim.fn.expand("%:e")
  return ext == "cpp" or ext == "cc" or ext == "cxx" or ext == "c"
end

local function pause_cmd(cmd)
  return cmd .. "; echo ''; echo 'Press ENTER to close'; read"
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = false,
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      float_opts = {
        border = "rounded",
        winblend = 3,
      },
    },
    keys = {
      {
        "<leader>cb",
        function()
          if not is_cpp_file() then
            vim.notify("Not a C/C++ file", vim.log.levels.WARN)
            return
          end
          local src = vim.fn.expand("%:p")
          local ext = vim.fn.expand("%:e")
          local out = vim.fn.expand("%:p:r") .. ".out"
          local compiler = ext == "c" and "cc" or "c++"
          local cmd = compiler .. " -std=c++20 -Wall -Wextra -g -o " .. out .. " " .. src
          local Terminal = require("toggleterm.terminal").Terminal
          local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
          term:toggle()
        end,
        desc = "Build C++",
      },
      {
        "<leader>cr",
        function()
          if not is_cpp_file() then
            vim.notify("Not a C/C++ file", vim.log.levels.WARN)
            return
          end
          local out = vim.fn.expand("%:p:r") .. ".out"
          local Terminal = require("toggleterm.terminal").Terminal
          local term = Terminal:new({ cmd = pause_cmd(out), direction = "float" })
          term:toggle()
        end,
        desc = "Run C++",
      },
      {
        "<leader>cB",
        function()
          if not is_cpp_file() then
            vim.notify("Not a C/C++ file", vim.log.levels.WARN)
            return
          end
          local src = vim.fn.expand("%:p")
          local ext = vim.fn.expand("%:e")
          local out = vim.fn.expand("%:p:r") .. ".out"
          local compiler = ext == "c" and "cc" or "c++"
          local cmd = compiler .. " -std=c++20 -Wall -Wextra -g -o " .. out .. " " .. src .. " && " .. out
          local Terminal = require("toggleterm.terminal").Terminal
          local term = Terminal:new({ cmd = pause_cmd(cmd), direction = "float" })
          term:toggle()
        end,
        desc = "Build & Run C++",
      },
    },
  },
}
