-- ── Active colorscheme switch ─────────────────────────────────────────────
-- Both themes below are installed. Flip this one string to switch; only the
-- matching plugin actually applies its colorscheme, the other just stays
-- available so you can swap back instantly (no reinstall).
--   "kanagawa" | "onedark"
local active = "kanagawa"

return {
  {
    -- kanagawa.nvim — warm, low-eyestrain theme inspired by Katsushika
    -- Hokusai. https://github.com/rebelot/kanagawa.nvim
    "rebelot/kanagawa.nvim",

    -- priority=1000 loads the colorscheme before other UI plugins draw;
    -- lazy=false loads it at startup.
    priority = 1000,
    lazy = false,

    config = function()
      require("kanagawa").setup({
        -- Sub-themes: "wave" (default, dark), "dragon" (darker), "lotus"
        -- (light). Set the one used when `background` doesn't override it.
        theme = "wave",

        -- Map light/dark backgrounds to sub-themes when you toggle
        -- `:set background`. Leave both as you like.
        background = { dark = "wave", light = "lotus" },

        -- Set true if you run a transparent terminal.
        transparent = false,

        commentStyle   = { italic = true },
        keywordStyle   = { italic = true },
        functionStyle  = { bold = true },
      })

      if active == "kanagawa" then
        vim.cmd.colorscheme("kanagawa")
      end
    end,
  },

  {
    -- onedark.nvim — a Lua port of the Atom One Dark theme with several
    -- built-in style variants. https://github.com/navarasu/onedark.nvim
    "navarasu/onedark.nvim",

    priority = 1000,
    lazy = false,

    config = function()
      require("onedark").setup({
        -- Style variants: "dark", "darker", "cool", "deep", "warm",
        -- "warmer", "light". Swap this string to change the whole palette.
        style = "warmer",

        -- Set true if you run a transparent terminal.
        transparent = false,

        -- Apply theme colors to the built-in :terminal (and toggleterm).
        term_colors = true,

        -- code_style styles whole token CLASSES so they read differently at a
        -- glance — comments dimmed/italic, keywords italic, etc.
        -- Each accepts "none" or a comma list of: italic, bold, underline.
        code_style = {
          comments  = "italic",
          keywords  = "italic",
          functions = "bold",
          strings   = "none",
          variables = "none",
        },
      })

      -- load() applies onedark. Only call it when it's the active theme so it
      -- doesn't clobber kanagawa when that's selected.
      if active == "onedark" then
        require("onedark").load()
      end
    end,
  },
}
