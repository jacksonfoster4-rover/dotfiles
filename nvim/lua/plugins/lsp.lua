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

      -- ── Python formatting + lint (ruff) ───────────────────────────────
      -- Pyright is types-only and has no document-formatting capability, so
      -- the format-on-save autocmd (init.lua) had nothing to call for .py and
      -- errored with "no matching language servers". Ruff supplies formatting
      -- (and fast linting). When both are attached, vim.lsp.buf.format() picks
      -- ruff because it's the one advertising the formatting capability.
      vim.lsp.config('ruff', {
        -- Let pyright own hover/definitions; ruff only lints + formats. Without
        -- this you'd get duplicate hover popups from two servers on the same buffer.
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
        end,
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
      -- violations as LSP diagnostics, and auto-fixes what it can on save
      -- (formatting, unused imports, etc.).
      --
      -- The old `:EslintFixAll` user command was created by lspconfig's
      -- setup() flow; under the Neovim 0.11 vim.lsp.enable() path it's never
      -- registered, so an autocmd running "EslintFixAll" errored with
      -- "not an editor command" on every .ts/.tsx save. Instead we ask the
      -- eslint server to apply all fixes directly. request_sync BLOCKS until
      -- the edits are applied, so they land before the buffer is written
      -- (an async request would race the save and often miss it).
      vim.lsp.config('eslint', {
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              client.request_sync("workspace/executeCommand", {
                command = "eslint.applyAllFixes",
                arguments = {
                  {
                    uri = vim.uri_from_bufnr(bufnr),
                    -- eslint wants the document version it's fixing; this
                    -- internal table tracks the LSP version per buffer.
                    version = vim.lsp.util.buf_versions[bufnr],
                  },
                },
              }, nil, bufnr)
            end,
          })
        end,
      })

      -- Activate all three servers. nvim-lspconfig provides the cmd /
      -- filetype / root_dir defaults; the vim.lsp.config() calls above
      -- layer our settings on top.
      vim.lsp.enable({ 'pyright', 'ruff', 'ts_ls', 'eslint' })
    end,
  },
}
