local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<leader>sf', "<cmd>Telescope find_files<cr>", opts)
map('n', '<leader>sg', "<cmd>Telescope live_grep<cr>", opts)
map('n', '<leader>sb', "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts)
map('n', '<leader>sr', "<cmd>lua require('spectre').open()<CR>", opts)
map('n', '<leader>gd', "<cmd>Gitsigns preview_hunk<CR>", opts)
map('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to definition" })
map('n', 'gi', vim.lsp.buf.implementation, { silent = true })
map('n', 'gD', vim.lsp.buf.declaration, { silent = true })
map('n', 'gr', vim.lsp.buf.references, { silent = true })
