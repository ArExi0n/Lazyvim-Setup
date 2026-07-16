return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<C-j>"] = { "select_next", "fallback" }
      opts.keymap["<C-k>"] = { "select_prev", "fallback" }
      opts.keymap["<C-n>"] = nil
      opts.keymap["<C-p>"] = nil

      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        keymap = {
          ["<C-j>"] = { "select_next" },
          ["<C-k>"] = { "select_prev" },
        },
      })

      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.frecency = { enabled = true }
      opts.fuzzy.use_proximity = true
      opts.fuzzy.sorts = { "score", "sort_text", "kind" }

      opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
        default = { "lsp", "path", "snippets", "buffer" },
      })
    end,
  },
}
