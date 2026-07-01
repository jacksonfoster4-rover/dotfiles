return {
  {
    -- bufferline.nvim — renders your open buffers as VS Code-style tabs along
    -- the top of the screen. NOTE: these are BUFFERS shown as tabs, not Vim's
    -- native :tabpages. One tab per open file, which is the behaviour you get
    -- in VS Code. https://github.com/akinsho/bufferline.nvim
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- Load after startup once files begin opening.
    event = "VeryLazy",

    config = function()
      require("bufferline").setup({
        options = {
          -- "buffers" = one tab per open file (VS Code style). The alternative
          -- "tabs" mode would instead mirror Vim's native tabpages.
          mode = "buffers",

          -- Close a buffer with a left-click on its x; middle-click also closes.
          close_command = "bdelete! %d",
          middle_mouse_command = "bdelete! %d",

          -- Show a numbered prefix so <leader>1..9 (see keymaps) map to what
          -- you see.
          numbers = "ordinal",

          diagnostics = "nvim_lsp",           -- show LSP error/warn counts on tabs
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "thin",

          -- Leave room for the file-tree sidebar so tabs don't sit under it.
          offsets = {
            {
              filetype = "NvimTree",
              text = "Files",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },
}
