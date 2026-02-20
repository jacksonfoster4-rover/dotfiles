return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "tsserver", "eslint", "efm" },
      })
    end,
  },
}
