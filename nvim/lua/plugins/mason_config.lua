return {
  {
    -- Mason is the package manager for LSP servers, DAP adapters, linters,
    -- and formatters. It downloads and manages their binaries under
    -- ~/.local/share/nvim/mason/ so you don't need to install them globally
    -- via npm/pip/brew. :Mason opens the UI; :MasonUpdate refreshes the
    -- registry of available packages.
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function() require("mason").setup() end,
  },
  {
    -- mason-lspconfig bridges Mason and nvim-lspconfig.
    -- It translates between Mason package names and lspconfig server names
    -- (they sometimes differ), and ensures the listed servers are installed
    -- automatically the first time Neovim starts so you don't have to run
    -- :MasonInstall manually on a new machine.
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",   -- Python type checker + LSP
          "ts_ls",     -- TypeScript/JavaScript LSP (renamed from "tsserver" in 2024;
                       -- the old name causes a silent install-but-no-attach failure)
          "eslint",    -- ESLint language server for JS/TS linting rules
                       -- NOTE: "efm" removed — it was a generic formatter proxy that
                       -- required separate efm config files. ESLint LSP handles
                       -- linting directly without that extra layer.
        },
      })
    end,
  },
}
