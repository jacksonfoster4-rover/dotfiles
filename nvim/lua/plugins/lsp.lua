return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local servers = { "pyright", "tsserver", "eslint", "efm" }

    for _, s in ipairs(servers) do
      lspconfig[s].setup({ capabilities = capabilities })
    end
  end,
}
