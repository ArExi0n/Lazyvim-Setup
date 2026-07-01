return {
  {
    "supermaven-inc/supermaven-nvim",
    opts = {
      keymaps = {
        accept_suggestion = "<C-a>",
        clear_suggestion = "<C-]>",
        accept_word = "<M-C-j>",
      },
    },
    init = function()
      vim.g.ai_cmp = true
    end,
  },
}
