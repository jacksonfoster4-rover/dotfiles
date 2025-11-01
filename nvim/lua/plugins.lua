require("lazy").setup({
  -- LSP and completion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },

  -- Telescope core
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- Telescope FZF Native
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").setup{
        defaults = {
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
          path_display = { "smart" }, -- options: "smart", "truncate", "absolute"
        },
        extensions = {
          fzf = {
            fuzzy = true,                    -- enables fuzzy matching
            override_file_sorter = true,     -- smarter path-based ranking
            override_generic_sorter = true,
            case_mode = "smart_case",        -- case-insensitive unless capitals
          }
        }
      }

      require("telescope").load_extension("fzf")
    end
  },
  {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { 
        "nvim-telescope/telescope-live-grep-args.nvim" ,
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.load_extension("live_grep_args")
  end
},

  -- Search/replace
  { "windwp/nvim-spectre" },

  -- Git integrations
  { "lewis6991/gitsigns.nvim" },
  { "tpope/vim-fugitive" },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("dap-setup")
    end,
  },
  { "rcarriga/nvim-dap-ui" },

  -- Nvim nio (required by dap-ui)
  {
    "nvim-neotest/nvim-nio",
    lazy = true, -- load only when required
  },

  -- Mason (LSP/DAP/Linters)
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls", "eslint", "efm" },
      })
    end,
  },
})
