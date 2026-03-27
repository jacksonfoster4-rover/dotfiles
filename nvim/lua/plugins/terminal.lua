return {
  {
    -- toggleterm gives you one or more persistent terminal instances that
    -- survive buffer switches. Each terminal keeps its shell session alive,
    -- so you can run a dev server in one, a test watcher in another, and
    -- flip between them without losing state.
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        -- Default size for horizontal/vertical splits (not used by float).
        size = 16,

        -- open_mapping is the global toggle key. <C-\> is the traditional
        -- terminal escape prefix in Vim, so this feels natural.
        -- In terminal mode it toggles the terminal closed; in normal mode
        -- it opens or brings it to focus.
        open_mapping = [[<C-\>]],

        -- "float" opens a centered overlay rather than splitting the window.
        -- You can override per-call: ToggleTerm direction=horizontal
        direction = "float",

        float_opts = {
          border = "curved",
          -- winblend adds transparency; 0 = fully opaque, 10 = slightly see-through
          winblend = 3,
        },

        -- Automatically enter insert mode when opening a terminal so you can
        -- type immediately without pressing 'i'.
        start_in_insert = true,

        -- Persist the terminal's working directory across toggles. If you
        -- :cd inside the terminal, that directory is remembered.
        persist_mode = true,
      })
    end,
  },
}
