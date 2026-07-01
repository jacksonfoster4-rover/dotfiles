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
vim.opt.clipboard = "unnamedplus"

-- Over SSH (e.g. editing inside a Codespace) there is no macOS clipboard and no
-- pbcopy/pbpaste, so unnamedplus yanks would go nowhere. Route the + and *
-- registers through OSC 52 instead: an escape sequence the terminal forwards to
-- your real system clipboard across the SSH link. Gated on $SSH_TTY so local
-- Neovim keeps using the native pbcopy/pbpaste provider untouched.
-- Requires a terminal with OSC 52 enabled (iTerm2: "Applications in terminal
-- may access clipboard"; kitty/wezterm/ghostty: on by default). If routed
-- through tmux, also set `set -g set-clipboard on`.
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy  = { ["+"] = osc52.copy("+"),  ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup('plugins')

require("keymaps")
