return {
{
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    view = {
      -- Hybrid line numbers in the tree: the cursor line shows its absolute
      -- number, every other line shows its distance from the cursor. That
      -- distance is the count for a motion, so you can read "7" next to a file
      -- and press 7j to land on it in one jump instead of tapping j repeatedly.
      number = true,
      relativenumber = true,
    },
    -- Keep all of nvim-tree's default in-tree keymaps, but drop the ones that
    -- open files in a NEW NATIVE TAB — we use bufferline buffer-tabs, not
    -- native tabpages, so "t" / "<C-t>" opening a native tab is unwanted.
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(bufnr)
      pcall(vim.keymap.del, "n", "t", { buffer = bufnr })       -- "open: new tab"
      pcall(vim.keymap.del, "n", "<C-t>", { buffer = bufnr })   -- same, ctrl variant

      -- The bufferline buffer-tab keymaps (keymaps.lua) are global, so inside
      -- the tree window ;1..;9 / Shift-h/l etc. would load an editor buffer
      -- INTO the tree window and clobber the tree. Shadow them with buffer-local
      -- no-ops so they do nothing while the tree is focused.
      local nop = { buffer = bufnr, silent = true }
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, "<Nop>", nop)
      end
      for _, k in ipairs({ "<S-l>", "<S-h>", "<leader>bp", "<leader>bd",
                           "<leader>bo", "<leader>bl", "<leader>bh" }) do
        vim.keymap.set("n", k, "<Nop>", nop)
      end
    end,
  },
}
}
