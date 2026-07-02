return {
  {
    -- trouble.nvim is the equivalent of VS Code's "Problems" panel: a single
    -- persistent, navigable list of all your diagnostics (and, optionally, LSP
    -- references and a symbol outline). You already have ]d/[d to hop errors
    -- and ;fd for a one-shot picker; Trouble is the always-open, grouped-by-file
    -- view you keep on screen while cleaning things up.
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- Load only when a :Trouble command actually runs (all the ;x* keymaps in
    -- keymaps.lua go through :Trouble), so it costs nothing at startup.
    cmd = "Trouble",

    -- Defaults are good; an empty opts table still triggers require+setup so the
    -- :Trouble command exists.
    opts = {},
  },
}
