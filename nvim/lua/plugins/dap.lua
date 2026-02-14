return {
  {
    "mfussenegger/nvim-dap",
    config = function() require("dap-setup") end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    config = function() require("dapui").setup() end,
  },
}
