return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-a>",
          accept_word = "<M-C-j>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
    },
    init = function()
      vim.g.ai_cmp = true
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_all = "<C-a>",
        accept_word = "<M-C-j>",
        clear_suggestion = "<C-]>",
      },
      ignore_filetypes = {
        "yaml", "markdown", "help", "gitcommit", "gitrebase",
        "hgcommit", "svn", "cvs",
      },
    },
  },
}
