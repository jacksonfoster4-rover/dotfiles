return {
  {
    "neovim/nvim-lspconfig",

    -- nvim-lspconfig provides server definitions (the command to run,
    -- which filetypes to attach to, default root detection). As of
    -- Neovim 0.11, you configure servers with vim.lsp.config() and enable
    -- them with vim.lsp.enable() instead of calling lspconfig.<server>.setup().
    -- The old setup() still works but prints a deprecation error.
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
      -- Apply capabilities to ALL servers at once using the '*' wildcard.
      -- default_capabilities() adds the extra fields nvim-cmp needs for
      -- completion (snippetSupport, resolveSupport, etc.).
      vim.lsp.config('*', {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- ── Python (pyright) ──────────────────────────────────────────────
      vim.lsp.config('pyright', {
        settings = {
          python = {
            analysis = {
              -- Add src/ and other subdirs to pyright's import search path
              -- so local modules resolve without a pyrightconfig.json.
              autoSearchPaths = true,

              -- Infer types from installed package source when no type stubs
              -- exist. Without this, packages like Django show as Unknown and
              -- generate false missing-import errors.
              useLibraryCodeForTypes = true,

              -- Analyse every .py file in the project, not just open buffers,
              -- so cross-file imports resolve correctly.
              diagnosticMode = "workspace",

              -- Catch real type errors without flagging every missing annotation.
              typeCheckingMode = "basic",
            },
          },
        },
      })

      -- ── TypeScript / JavaScript (ts_ls) ───────────────────────────────
      vim.lsp.config('ts_ls', {
        settings = {
          typescript = {
            preferences = {
              -- Keep auto-imports as ../foo rather than absolute paths that
              -- break when files are moved.
              importModuleSpecifier = "relative",
            },
          },
          javascript = {
            preferences = { importModuleSpecifier = "relative" },
          },
        },
      })

      -- ── ESLint ────────────────────────────────────────────────────────
      -- Reads the project's .eslintrc / eslint.config.* and surfaces rule
      -- violations as LSP diagnostics. EslintFixAll on save auto-fixes
      -- anything eslint can fix automatically (formatting, unused imports, etc.)
      vim.lsp.config('eslint', {
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      -- Activate all three servers. nvim-lspconfig provides the cmd /
      -- filetype / root_dir defaults; the vim.lsp.config() calls above
      -- layer our settings on top.
      vim.lsp.enable({ 'pyright', 'ts_ls', 'eslint' })
    end,
  },
}
