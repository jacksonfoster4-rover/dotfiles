local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<leader>sf', "<cmd>Telescope find_files<cr>", opts)
map('n', '<leader>sg', "<cmd>Telescope live_grep<cr>", opts)
map('n', '<leader>sb', "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts)
map('n', '<leader>sr', "<cmd>lua require('spectre').open()<CR>", opts)
map('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true, desc = "Go to definition" })
map('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, silent = true })
map('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = true,  silent = true })
map('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true,  silent = true })
