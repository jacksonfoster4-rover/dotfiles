return {
  {
    -- which-key pops up a small menu of the possible next keys whenever you
    -- start a multi-key mapping and pause. Press ; (the leader) and wait a
    -- beat — a panel lists every ;-mapping and what it does. This is the single
    -- biggest discoverability win coming from a GUI editor: you no longer have
    -- to memorise the maps, you can browse them live.
    "folke/which-key.nvim",

    -- VeryLazy = load after startup finishes, so it never slows the initial
    -- launch. The popup is only needed once you're actually editing.
    event = "VeryLazy",

    opts = {
      -- Show the popup after 400ms of holding a prefix. Low enough to feel
      -- responsive, high enough that fast full mappings don't flash the menu.
      delay = 400,
    },

    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- Name the leader groups so the popup shows "AI", "Git", "Debug" etc.
      -- as section headers instead of a flat undifferentiated key list. These
      -- prefixes match the keymaps defined in keymaps.lua.
      wk.add({
        { "<leader>a", group = "AI / Claude" },
        { "<leader>b", group = "Buffer tabs" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find / search" },
        { "<leader>g", group = "Git / goto" },
        { "<leader>s", group = "Shell / search-replace" },
        { "<leader>t", group = "File tree" },
        { "<leader>x", group = "Trouble (diagnostics)" },
      })
    end,
  },
}
