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

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup('plugins')

require("keymaps")
