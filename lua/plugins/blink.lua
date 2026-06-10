return {
	{
		"saghen/blink.cmp",
		opts = function(_, opts)
			opts.keymap = opts.keymap or {}
			opts.keymap["<C-j>"] = { "select_next", "fallback" }
			opts.keymap["<C-k>"] = { "select_prev", "fallback" }
			opts.keymap["<C-n>"] = nil
			opts.keymap["<C-p>"] = nil
		end,
	},
}
