return {
  {
    -- diffview.nvim — a full-window, multi-file diff and merge viewer. Great
    -- for reviewing everything Claude Code (or a branch) changed at once: one
    -- panel lists every changed file, the main area shows the side-by-side
    -- diff. Much easier than hopping file to file with gitsigns.
    -- https://github.com/sindrets/diffview.nvim
    "sindrets/diffview.nvim",

    -- Load only when one of its commands is first used.
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },

    keys = {
      -- ;gV reads as "git, big View" — review all uncommitted changes (i.e.
      -- everything Claude just edited in your working tree).
      { "<leader>gV", "<cmd>DiffviewOpen<cr>",        desc = "Diffview: review working changes" },
      { "<leader>gQ", "<cmd>DiffviewClose<cr>",       desc = "Diffview: close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: history of current file" },
    },

    opts = {
      enhanced_diff_hl = true,   -- clearer added/removed highlighting
    },
  },
}
