local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- ── File tree ──────────────────────────────────────────────────────────────
map('n', '<leader>tt', ':NvimTreeToggle<CR>',   { noremap = true, silent = true, desc = "Toggle file tree" })
map('n', '<leader>to', ':NvimTreeOpen<CR>',     { noremap = true, silent = true, desc = "Open file tree" })
map('n', '<leader>tc', ':NvimTreeClose<CR>',    { noremap = true, silent = true, desc = "Close file tree" })
map('n', '<leader>tf', ':NvimTreeFocus<CR>',    { noremap = true, silent = true, desc = "Focus file tree" })
-- Reveal the current buffer's file in the tree. Useful when you opened a file
-- via Telescope and want to see where it sits in the directory structure.
map('n', '<leader>tn', ':NvimTreeFindFile<CR>', { noremap = true, silent = true, desc = "Find current file in tree" })

-- ── Search ─────────────────────────────────────────────────────────────────
map('n', '<leader>sr', "<cmd>lua require('spectre').open()<CR>",       { noremap = true, silent = true, desc = "Search and replace (project)" })
map('n', '<leader>f',  '<cmd>Telescope find_files<CR>',                { noremap = true, silent = true, desc = "Find file by name" })
map('n', '<leader>ff', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>', { noremap = true, silent = true, desc = "Search string in files (with args)" })
map('n', '<leader>fc', '<cmd>Telescope grep_string<CR>',               { noremap = true, silent = true, desc = "Search word under cursor" })
map('n', '<leader>fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { noremap = true, silent = true, desc = "Fuzzy search in current file" })

-- ── LSP navigation ─────────────────────────────────────────────────────────
-- Ctrl-o jumps back after any of these; Ctrl-i jumps forward again.
map('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>',      { noremap = true, silent = true, desc = "Go to definition" })
map('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',  { noremap = true, silent = true, desc = "Go to implementation" })
map('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>',     { noremap = true, silent = true, desc = "Go to declaration" })
map('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>',      { noremap = true, silent = true, desc = "Show all references" })
map('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true, desc = "Go to type definition" })
map('n', '<leader>h',  '<cmd>lua vim.lsp.buf.hover()<CR>',           { noremap = true, silent = true, desc = "Hover docs" })
-- Rename symbol across the whole project (all references update together).
map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>',          { noremap = true, silent = true, desc = "Rename symbol" })
-- Code actions: quick-fixes, import suggestions, extract-to-function, etc.
map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',     { noremap = true, silent = true, desc = "Code actions" })

-- ── Diagnostics ────────────────────────────────────────────────────────────
-- Navigate between LSP errors/warnings in the current file.
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true, desc = "Next diagnostic" })
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true, desc = "Prev diagnostic" })
-- Show all diagnostics for the project in a Telescope picker.
map('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>',  { noremap = true, silent = true, desc = "All diagnostics" })

-- ── Git (Telescope) ────────────────────────────────────────────────────────
-- All changed/staged/untracked files in the repo. Press <CR> to open a file,
-- <Tab> to stage/unstage it directly from the picker.
map('n', '<leader>gs', '<cmd>Telescope git_status<CR>',   { noremap = true, silent = true, desc = "Git changed files" })
-- Full commit log for the repo. Press <CR> to check out a commit in a diff.
map('n', '<leader>gc', '<cmd>Telescope git_commits<CR>',  { noremap = true, silent = true, desc = "Git repo history" })
-- Commit history for the current file only. Great for tracking when a line
-- or function was last changed and by whom.
map('n', '<leader>gF', '<cmd>Telescope git_bcommits<CR>', { noremap = true, silent = true, desc = "Git file history" })
-- All local and remote branches. <CR> checks out the selected branch.
map('n', '<leader>gB', '<cmd>Telescope git_branches<CR>', { noremap = true, silent = true, desc = "Git branches" })

-- ── Git (fugitive) ─────────────────────────────────────────────────────────
-- :Git opens the interactive status window (stage hunks, commit, push, etc.)
map('n', '<leader>G',  '<cmd>Git<CR>',          { noremap = true, silent = true, desc = "Open Git status (fugitive)" })
map('n', '<leader>gl', '<cmd>Git log --oneline<CR>', { noremap = true, silent = true, desc = "Git log (oneline)" })

-- ── GitHub permalink (gitlinker) ───────────────────────────────────────────
-- <leader>gy is gitlinker's default in both normal and visual mode.
-- Normal:  copies permalink for the current line.
-- Visual:  copies permalink for the selected line range.
-- The URL is pinned to the current commit SHA, not the branch name, so it
-- won't drift as the branch moves. Result goes to system clipboard.

-- ── Terminal ───────────────────────────────────────────────────────────────
-- <C-\> (mapped in terminal.lua config) toggles the floating terminal globally.
-- These give named shortcuts for specific use-cases:
map('n', '<leader>sh', '<cmd>ToggleTerm direction=float<CR>',      { noremap = true, silent = true, desc = "Open floating shell" })
-- Horizontal split terminal at the bottom — useful alongside a code buffer.
map('n', '<leader>sv', '<cmd>ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Open split shell (horizontal)" })
-- Open a second independent terminal instance (id=2). Each id is a separate
-- shell session, so you can run a dev server in 1 and tests in 2.
map('n', '<leader>s2', '<cmd>2ToggleTerm direction=float<CR>',     { noremap = true, silent = true, desc = "Open shell instance 2" })
-- While inside a terminal buffer, <Esc> returns to normal mode so you can
-- yank output, scroll, or close the window without killing the shell.
map('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "Exit terminal insert mode" })

-- macOS clipboard (Cmd+C / Cmd+V)
-- These require your terminal emulator to forward Cmd key events to Neovim.
-- In iTerm2: Preferences > Keys > Key Bindings, ensure "Left Command" sends
-- escape sequences. In WezTerm/Kitty/Alacritty this is usually on by default.
--
-- Because we set clipboard=unnamedplus in init.lua, regular y/p already use
-- the system clipboard. These mappings just add the familiar macOS shortcuts
-- on top so muscle memory works.
--
-- <D-c>: Cmd+C — copy visual selection to system clipboard
map('v', '<D-c>', '"+y',        { noremap = true, silent = true, desc = "Copy selection to system clipboard" })
-- <D-v>: Cmd+V — paste from system clipboard
map('n', '<D-v>', '"+p',        { noremap = true, silent = true, desc = "Paste from system clipboard" })
-- In insert mode, <C-r>+ inserts the contents of the + (system clipboard)
-- register without triggering auto-indent or other insert-mode side effects.
map('i', '<D-v>', '<C-r>+',     { noremap = true, silent = true, desc = "Paste from system clipboard (insert)" })
-- In visual mode Cmd+V replaces the selection with the clipboard contents.
map('v', '<D-v>', '"+p',        { noremap = true, silent = true, desc = "Paste over selection from clipboard" })

-- ── Debugging (DAP) ────────────────────────────────────────────────────────
-- Workflow: run ./bin/debugpy.sh in ;sh, wait for "Starting development server",
-- then press ;dc to attach. Set breakpoints first with ;db.
--
-- ;dc  Continue / attach to debugpy
--       On first press: opens the DAP UI and attaches to localhost:5678.
--       On subsequent presses: resumes execution until the next breakpoint.
map('n', '<leader>dc', '<cmd>lua require("dap").continue()<CR>',          { noremap = true, silent = true, desc = "Debug: continue / attach" })

-- ;db  Toggle breakpoint on the current line
--       A red dot appears in the sign column. The next request that hits
--       this line will pause execution here.
map('n', '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<CR>',  { noremap = true, silent = true, desc = "Debug: toggle breakpoint" })

-- ;dB  Conditional breakpoint — only pauses when an expression is true
--       e.g. enter  user.id == 42  to stop only for a specific user
--       NOTE: vim.keymap.set is used here (not the map() alias above) because
--       nvim_set_keymap only accepts strings as rhs, not Lua functions.
vim.keymap.set('n', '<leader>dB', function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { noremap = true, silent = true, desc = "Debug: conditional breakpoint" })

-- ;dn  Step over — execute the current line, stop at the next line
--       Does not descend into function calls.
map('n', '<leader>dn', '<cmd>lua require("dap").step_over()<CR>',          { noremap = true, silent = true, desc = "Debug: step over" })

-- ;di  Step into — if the current line calls a function, follow it inside
map('n', '<leader>di', '<cmd>lua require("dap").step_into()<CR>',          { noremap = true, silent = true, desc = "Debug: step into" })

-- ;do  Step out — run until the current function returns, stop at the caller
map('n', '<leader>do', '<cmd>lua require("dap").step_out()<CR>',           { noremap = true, silent = true, desc = "Debug: step out" })

-- ;dt  Terminate the debug session
--       Disconnects from debugpy. Django will continue running normally.
map('n', '<leader>dt', '<cmd>lua require("dap").terminate()<CR>',          { noremap = true, silent = true, desc = "Debug: terminate session" })

-- ;dr  Open the DAP REPL (interactive Python console in the paused frame)
--       You can inspect variables, call functions, evaluate expressions.
map('n', '<leader>dr', '<cmd>lua require("dap").repl.open()<CR>',          { noremap = true, silent = true, desc = "Debug: open REPL" })

-- ;dl  List all breakpoints in a Telescope picker
map('n', '<leader>dl', '<cmd>lua require("dap").list_breakpoints()<CR>',   { noremap = true, silent = true, desc = "Debug: list breakpoints" })

-- ;dC  Clear ALL breakpoints in every file
map('n', '<leader>dC', '<cmd>lua require("dap").clear_breakpoints()<CR>',  { noremap = true, silent = true, desc = "Debug: clear all breakpoints" })

-- ;du  Toggle the DAP UI open/closed manually (it also auto-opens on attach)
map('n', '<leader>du', '<cmd>lua require("dapui").toggle()<CR>',           { noremap = true, silent = true, desc = "Debug: toggle UI" })

-- ;dh  Hover: show the value of the variable/expression under the cursor
--       Only works while paused at a breakpoint.
map('n', '<leader>dh', '<cmd>lua require("dap.ui.widgets").hover()<CR>',   { noremap = true, silent = true, desc = "Debug: hover value" })
