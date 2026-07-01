return {
  {
    -- claudecode.nvim — the same editor integration the VS Code / JetBrains
    -- Claude Code extensions use, reimplemented in pure Lua. It runs a small
    -- WebSocket server inside Neovim; the `claude` you launch on the SAME
    -- machine auto-discovers it (via a lockfile + env), so Claude Code can see
    -- your current selection, the files you @-mention, and show its edits back
    -- to you as diffs you accept or reject IN Neovim instead of blind writes.
    -- https://github.com/coder/claudecode.nvim
    --
    -- Works over SSH / in a Codespace with no extra setup: the server and the
    -- claude process live on the same box, so it's all localhost.
    "coder/claudecode.nvim",

    config = function()
      require("claudecode").setup({
        -- Launch claude in Neovim's own built-in :terminal split. Avoids
        -- pulling in snacks.nvim just for a terminal; this is separate from
        -- your toggleterm shells (those stay for plain shell work).
        terminal = { provider = "native", split_side = "right" },
      })
    end,

    -- All AI commands live under the ;a ("AI") prefix — no clash with the
    -- existing ;s (shells), ;g (git), ;t (tree), ;f (find), ;d (debug),
    -- ;b (buffer tabs) groups.
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",          desc = "Toggle Claude Code terminal" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",     desc = "Focus the Claude terminal" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume a previous Claude session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last Claude session" },

      -- Send context to the running session:
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",           desc = "Add current file to Claude" },
      -- From inside the file tree, add the file/folder under the cursor:
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", ft = { "NvimTree" }, desc = "Add tree item to Claude" },

      -- Review Claude's proposed edits (opens as a diff in Neovim):
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's diff" },
      { "<leader>ax", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Reject Claude's diff" },
    },
  },
}
