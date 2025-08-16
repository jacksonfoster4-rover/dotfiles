require("nvim-tree").setup({
    auto_reload_on_write = true,
    update_focused_file = { enable = true },
    view = { width = 30, side = "left", preserve_window_proportions = true },
    renderer = { icons = { show = { file = true, folder = true, folder_arrow = true, git = true } } },
    actions = { open_file = { resize_window = true } },
})
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function(data)
        if vim.fn.isdirectory(data.file) == 1 then
            vim.cmd.cd(data.file)
            require("nvim-tree.api").tree.open()
        end
    end
})
