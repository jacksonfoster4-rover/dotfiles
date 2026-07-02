return {
  {
    -- nvim-autopairs auto-inserts the closing half of a pair as you type the
    -- opening one: type ( and you get (), type " and you get "", with the
    -- cursor left in the middle. VS Code does this out of the box; Neovim does
    -- not, so its absence is one of the first things that feels "broken".
    "windwp/nvim-autopairs",

    -- Only needed once you start typing, so defer loading until insert mode.
    event = "InsertEnter",

    -- We wire autopairs into the completion menu (see below), so cmp must be
    -- available when this configures.
    dependencies = { "hrsh7th/nvim-cmp" },

    config = function()
      require("nvim-autopairs").setup({
        -- check_ts uses treesitter to decide when NOT to pair — e.g. don't add
        -- a second " when you're already inside a string, or a ) inside a
        -- comment. Without it, pairing fires in places it shouldn't.
        check_ts = true,
      })

      -- Make accepting a function/method from the completion menu also add its
      -- parentheses: confirm `myFunc` and you get `myFunc()` with the cursor
      -- between them, ready for arguments. The cmp `confirm_done` event is the
      -- hook autopairs listens on to do this.
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
