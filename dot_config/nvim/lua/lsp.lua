require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "tsserver" },
})

local lspconfig = require("lspconfig")

-- LSP servers
require("mason-lspconfig").setup_handlers({
  function(server)
    lspconfig[server].setup({
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })
  end,
})

-- Autocomplete setup
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

-- Python Debugger (DAP)
local dap_python = require("dap-python")
dap_python.setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
