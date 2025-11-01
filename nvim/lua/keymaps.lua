local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
-- Navigation
map('n', '<leader>tt', ':NvimTreeToggle<CR>', { noremap = true,  silent = true })
map('n', '<leader>to', ':NvimTreeOpen<CR>', { noremap = true,  silent = true })
map('n', '<leader>tc', ':NvimTreeClose<CR>', { noremap = true,  silent = true })
map('n', '<leader>tf', ':NvimTreeFocus<CR>', { noremap = true,  silent = true })
map('n', '<leader>sr', "<cmd>lua require('spectre').open()<CR>", { noremap = true, silent =true, desc = "Search and replace"})
-- Search
map('n', '<leader>f', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true, desc = "Search for filename" })
map('n', '<leader>ff', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>', { noremap = true,  silent = true, desc = "Search for string in files"})
map('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true, desc = "Search for string under cursor"})
map('n', '<leader>fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { noremap = true, silent = true, desc = "Search for string in open file"})
-- References
map('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true, desc = "Go to definition" })
map('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, silent = true })
map('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = true,  silent = true })
map('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true,  silent = true })
map('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true,  silent = true })
map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true,  silent = true })


