return {
  {
    -- nvim-treesitter provides real syntax highlighting using concrete syntax
    -- trees rather than regex-based Vim syntax files.
    --
    -- Why this matters:
    -- - Regex highlighting breaks on multi-line strings, template literals,
    --   JSX, and nested languages (CSS-in-JS, f-strings, etc.).
    -- - Treesitter parses the actual grammar so it correctly highlights these
    --   cases and stays accurate even when the file is not fully valid yet.
    -- - It also enables smarter indentation heuristics.
    --
    -- Without this plugin, Neovim falls back to built-in regex syntax files
    -- which are incomplete for modern TypeScript/TSX.
    "nvim-treesitter/nvim-treesitter",

    -- :TSUpdate compiles the C parser for every installed language after a
    -- plugin update. Parsers are compiled native binaries and must be
    -- rebuilt when treesitter's ABI version changes.
    build = ":TSUpdate",

    -- lazy = false forces treesitter to load at startup rather than on-demand.
    -- The `main` field approach also fails for the same reason: lazy.nvim tries
    -- to require nvim-treesitter.configs before the plugin's runtime directory
    -- is on the path. Loading eagerly at startup avoids that timing issue.
    lazy = false,

    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python",     -- .py
          "typescript", -- .ts
          "tsx",        -- .tsx  separate grammar from typescript, needed for JSX
          "javascript", -- .js / .mjs / .cjs
          "json",       -- .json
          "jsonc",      -- .jsonc, tsconfig.json (JSON with comments)
          "html",       -- .html
          "css",        -- .css
          "lua",        -- Neovim config files
          "bash",       -- shell scripts
          "markdown",   -- .md
        },

        highlight = {
          -- Activates treesitter highlighting for every buffer whose filetype
          -- has an installed parser.
          enable = true,
        },

        indent = {
          -- Treesitter indentation is more accurate than Vim's smartindent for
          -- deeply nested structures (JSX, Python decorators, etc.).
          enable = true,
        },
      })
    end,
  },
}
