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

    -- Pin to the classic "master" branch. lazy.nvim now defaults to the
    -- "main" branch (a 2024 rewrite) where require("nvim-treesitter").setup()
    -- IGNORES ensure_installed/highlight/indent and highlighting must be
    -- started manually per-buffer. On "master" the options below work as
    -- written. Without this pin, highlighting silently never turns on and
    -- Neovim falls back to legacy regex syntax (the pythonConditional groups).
    branch = "master",

    -- :TSUpdate compiles the C parser for every installed language after a
    -- plugin update. Parsers are compiled native binaries and must be
    -- rebuilt when treesitter's ABI version changes.
    build = ":TSUpdate",

    -- lazy = false forces treesitter to load at startup rather than on-demand,
    -- ensuring the plugin's runtime directory is on the path before config runs.
    lazy = false,

    config = function()
      -- On the master branch the highlight/indent/ensure_installed options
      -- are configured through the nvim-treesitter.configs module, NOT the
      -- top-level nvim-treesitter module.
      require("nvim-treesitter.configs").setup({
        -- Install parsers synchronously so they are ready before highlighting
        -- kicks in. Without this, async installs can race with buffer loads
        -- and cause intermittent highlighting failures on first open.
        sync_install = true,

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

  {
    -- nvim-ts-autotag auto-closes and auto-renames HTML/JSX/TSX tags using the
    -- treesitter parse tree: type <div> and you get the matching </div>; edit
    -- one end of a tag pair and the other end renames to match. VS Code does
    -- this for JSX by default — high value since the RN frontend is all TSX.
    "windwp/nvim-ts-autotag",

    -- Only load for the tag-based filetypes it acts on, so it costs nothing in
    -- Python/Lua/etc. buffers.
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "tsx",
      "jsx",
      "xml",
    },

    -- The modern plugin has its own setup() and no longer hangs off the
    -- nvim-treesitter config, so it configures itself independently here.
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
