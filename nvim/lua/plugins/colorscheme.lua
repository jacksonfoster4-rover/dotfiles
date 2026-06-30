return {
  {
    -- onedark.nvim — a Lua port of the Atom One Dark theme with several
    -- built-in style variants. https://github.com/navarasu/onedark.nvim
    "navarasu/onedark.nvim",

    -- A colorscheme must load before any other UI plugin draws, otherwise
    -- those plugins pick up the default theme's highlight groups first and
    -- only repaint on the next redraw. priority=1000 makes lazy.nvim load
    -- this ahead of normal plugins; lazy=false loads it at startup rather
    -- than on-demand.
    priority = 1000,
    lazy = false,

    config = function()
      require("onedark").setup({
        -- Style variants: "dark", "darker", "cool", "deep", "warm",
        -- "warmer", "light". Swap this string to change the whole palette.
        style = "deep",

        -- Respect terminal/GUI transparency so the editor background uses
        -- your terminal's background instead of a solid color. Set true if
        -- you run a transparent terminal.
        transparent = false,

        -- Apply theme colors to the built-in :terminal (and toggleterm).
        term_colors = true,

        -- code_style styles whole token CLASSES so they read differently at a
        -- glance — comments dimmed/italic, keywords italic, etc. This works on
        -- top of treesitter + LSP, which already color tokens by syntax/meaning.
        -- Each accepts "none" or a comma list of: italic, bold, underline.
        code_style = {
          comments  = "italic",
          keywords  = "italic",  -- if/for/return/def — stand out from names
          functions = "bold",    -- function/method names pop
          strings   = "none",
          variables = "none",
        },

        -- ── Force contrast between token classes ────────────────────────────
        -- The "muddy" look comes from many different things resolving to the
        -- same few colors. Here we pin each class to a distinct hue. Values
        -- reference onedark's palette with "$name"; fmt adds italic/bold.
        --
        -- IMPORTANT: when an LSP attaches, its semantic tokens (@lsp.type.*)
        -- are drawn ON TOP of treesitter's captures (@variable, @string, ...).
        -- So each class is set in BOTH namespaces — miss the @lsp.* one and
        -- pyright/ts_ls will repaint it back to muddy.
        highlights = {
          -- local variables — keep neutral so the colored classes pop against them
          ["@variable"]            = { fg = "$fg" },
          ["@lsp.type.variable"]   = { fg = "$fg" },

          -- function arguments / parameters — orange + italic, very distinct
          ["@variable.parameter"]  = { fg = "$orange", fmt = "italic" },
          ["@lsp.type.parameter"]  = { fg = "$orange", fmt = "italic" },

          -- object properties / members / fields — cyan
          ["@variable.member"]     = { fg = "$cyan" },
          ["@property"]            = { fg = "$cyan" },
          ["@lsp.type.property"]   = { fg = "$cyan" },

          -- strings — green
          ["@string"]              = { fg = "$green" },

          -- the import/from keywords themselves — red italic, same as every
          -- other keyword (if/for/def) so all keywords read consistently
          ["@keyword.import"]      = { fg = "$red", fmt = "italic" },
          -- the module / imported names (os, numpy, MyClass) — purple, so the
          -- thing being imported is visually distinct from the keyword
          ["@module"]              = { fg = "$purple" },
          ["@lsp.type.namespace"]  = { fg = "$purple" },

          -- functions & calls — blue
          ["@function"]            = { fg = "$blue" },
          ["@function.call"]       = { fg = "$blue" },
          ["@function.method"]     = { fg = "$blue" },
          ["@lsp.type.function"]   = { fg = "$blue" },
          ["@lsp.type.method"]     = { fg = "$blue" },

          -- types / classes — yellow
          ["@type"]                = { fg = "$yellow" },
          ["@lsp.type.class"]      = { fg = "$yellow" },
          ["@lsp.type.type"]       = { fg = "$yellow" },

          -- constants / numbers — dark yellow so they differ from strings
          ["@constant"]            = { fg = "$dark_yellow" },
          ["@number"]              = { fg = "$dark_yellow" },
          ["@boolean"]             = { fg = "$dark_yellow" },

          -- keywords (if/for/return/def/import) — red + italic
          ["@keyword"]             = { fg = "$red", fmt = "italic" },
        },
      })

      -- load() applies the colorscheme. Calling it here (not :colorscheme
      -- onedark) lets onedark read the setup() options above.
      require("onedark").load()
    end,
  },
}
