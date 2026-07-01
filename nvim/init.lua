-- Bootstrap and load all modules
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- format on save
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = {"*.py", "*.ts", "*.tsx", "*.js"},
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- show inline errors
vim.diagnostic.config({
    virtual_text = true,  -- show inline text
    signs = true,         -- show in sign column
    float = { border = "rounded" },
})

vim.api.nvim_command("helptags ALL")

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- Use the system clipboard as the default yank/paste register.
-- This means y, d, p etc. all read/write the macOS clipboard automatically,
-- so text copied in Neovim is immediately pasteable in the browser, Slack, etc.
-- and vice versa. Requires a clipboard provider; on macOS this uses pbcopy/pbpaste
-- which are built-in, so no extra setup is needed.
if vim.env.SSH_TTY then
  -- Over SSH (e.g. inside a Codespace) there is no macOS clipboard and no
  -- pbcopy/pbpaste. Rather than route the whole clipboard through OSC 52 —
  -- which makes `p` issue an OSC 52 *read* query that most terminals never
  -- answer, so paste hangs or breaks — keep y/p on the normal unnamed register
  -- (so `p` stays instant and reliable) and just MIRROR every yank up to the
  -- macOS clipboard with an OSC 52 *copy* (write-only, always works).
  --
  -- Result: y (and d/c) fill the normal register AND land in your Mac
  -- clipboard; p pastes from the normal register with no network round-trip.
  -- Needs a terminal with OSC 52 enabled (Ghostty/kitty/wezterm: on by
  -- default; iTerm2: enable "Applications in terminal may access clipboard").
  -- Through tmux, also set `set -g set-clipboard on`.
  vim.opt.clipboard = ""
  local osc52 = require("vim.ui.clipboard.osc52")

  -- A copy-only OSC 52 provider: explicit "+y / "+p (and the <D-c> mapping)
  -- still write to the Mac clipboard, but paste reads from Neovim's own +
  -- register instead of firing an OSC 52 read query that would hang.
  vim.g.clipboard = {
    name = "OSC 52 (copy-only)",
    copy  = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = {
      ["+"] = function() return { vim.fn.getreg('+', 1, true), vim.fn.getregtype('+') } end,
      ["*"] = function() return { vim.fn.getreg('*', 1, true), vim.fn.getregtype('*') } end,
    },
  }

  -- Mirror every yank/delete on the normal register up to the Mac clipboard.
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("osc52_yank_mirror", { clear = true }),
    callback = function()
      local ev = vim.v.event
      osc52.copy("+")(ev.regcontents, ev.regtype)
    end,
  })
else
  -- Locally, macOS pbcopy/pbpaste back the clipboard, so the simple approach
  -- works: make y/d/p read and write the system clipboard by default.
  vim.opt.clipboard = "unnamedplus"
end

-- Auto-reload buffers when files change on disk. Claude Code (and git
-- checkouts, formatters, etc.) edit files behind Neovim's back; without this
-- your open buffer stays stale and saving would clobber those external edits.
-- autoread lets Neovim re-read a file it notices has changed; the autocmd
-- forces that check on the events where you'd notice — refocusing the window,
-- entering a buffer, or leaving a terminal (e.g. after the claude TUI writes).
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave", "TermClose" }, {
  group = vim.api.nvim_create_augroup("auto_reload_files", { clear = true }),
  command = "checktime",
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup('plugins')

require("keymaps")
