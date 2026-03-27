return {
  {
    -- gitsigns decorates the sign column with +/~/- indicators for added,
    -- changed, and deleted lines based on the current git diff. It also
    -- provides hunk-level actions (stage a single hunk, preview the diff,
    -- toggle per-line blame) without leaving the buffer.
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "-" },
          topdelete    = { text = "-" },
          changedelete = { text = "~" },
        },

        -- Show the commit message and author inline at the end of the current
        -- line. Off by default (can be noisy); toggle with <leader>gb.
        current_line_blame = false,
        current_line_blame_opts = {
          delay = 400,
          virt_text_pos = "eol",
        },

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Helper to create buffer-local keymaps (only active in git files).
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          -- Hunk navigation
          -- A "hunk" is a contiguous block of changed lines. These let you
          -- step through every change in the file one block at a time.
          map('n', ']h', gs.next_hunk, "Next git hunk")
          map('n', '[h', gs.prev_hunk, "Prev git hunk")

          -- Preview hunk
          -- Opens a small floating window showing the before/after diff for
          -- just the hunk under the cursor. Good for reviewing before staging.
          map('n', '<leader>gp', gs.preview_hunk, "Preview hunk diff")

          -- Stage / unstage a single hunk
          -- Stage: add this hunk to the git index (partial commit preparation).
          -- Undo stage: remove it from the index without losing your edits.
          map('n', '<leader>ga', gs.stage_hunk,      "Stage hunk")
          map('n', '<leader>gu', gs.undo_stage_hunk, "Unstage hunk")

          -- Reset hunk
          -- Discards all local changes in this hunk, reverting to HEAD.
          -- Destructive -- use with care.
          map('n', '<leader>gx', gs.reset_hunk, "Reset hunk to HEAD")

          -- Inline blame
          -- Shows "hash  Author  N days ago: commit message" at the end of
          -- the line. Toggling keeps it out of the way until you need it.
          map('n', '<leader>gb', gs.toggle_current_line_blame, "Toggle inline blame")

          -- View full file diff
          -- NOTE: <leader>gd is taken globally for LSP "go to definition",
          -- so this uses <leader>gv ("view diff") to avoid shadowing it.
          map('n', '<leader>gv', function() gs.diffthis("~") end, "View file diff against HEAD")
        end,
      })
    end,
  },

  -- vim-fugitive is the gold-standard git client inside Neovim.
  -- :Git (or :G) opens an interactive status window where you can stage
  -- individual files/hunks, write a commit message, push, pull, and resolve
  -- merge conflicts -- all without leaving Neovim.
  -- Other useful commands: :Git log, :Git blame, :Git diff
  { "tpope/vim-fugitive" },

  {
    -- vim-rhubarb extends fugitive with GitHub awareness.
    -- Enables :GBrowse to open the current file/line on github.com.
    -- Also required by gitlinker for URL host detection.
    "tpope/vim-rhubarb",
  },

  {
    -- gitlinker generates a permanent, shareable GitHub (or GitLab/Gitea)
    -- permalink for the current line or visual selection and copies it to
    -- the clipboard.
    --
    -- Why "permalink"? The URL contains the exact commit SHA, not the branch
    -- name. This means the link always points to the same code even after the
    -- branch moves forward or gets deleted.
    --
    -- Default keymaps (set automatically):
    --   <leader>gy  (normal)  -- permalink for current line
    --   <leader>gy  (visual)  -- permalink for selected line range
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitlinker").setup({
        -- Puts the generated URL on the system clipboard so you can paste
        -- it straight into Slack/GitHub/Jira.
        action_callback = require("gitlinker.actions").copy_to_clipboard,
        -- Also prints the URL in the command line so you can see it.
        print_url = true,
      })
    end,
  },
}
