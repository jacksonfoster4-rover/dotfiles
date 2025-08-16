require("lazy").setup({
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim", config = true },
    { "jose-elias-alvarez/null-ls.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "windwp/nvim-spectre" },
    { "lewis6991/gitsigns.nvim" },
    { "tpope/vim-fugitive" },
	{
	  "mfussenegger/nvim-dap",
	  config = function()
	    require("dap-setup")
	  end,
	},
    { "rcarriga/nvim-dap-ui" },
{
  "nvim-neotest/nvim-nio",
  lazy = true,  -- load only when required
}
})
