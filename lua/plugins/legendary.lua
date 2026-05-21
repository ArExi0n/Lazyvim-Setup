return {
  "mrjones2014/legendary.nvim",
  keys = {
    { "<leader>?", desc = "Find keybindings" },
  },
  config = function()
    require("legendary").setup({
      which_key = {
        auto_register = true,
      },
    })

    vim.keymap.set("n", "<leader>?", "<cmd>Legendary<CR>", { desc = "Find keybindings" })
  end,
}
