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

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup('plugins')

require("keymaps")
