local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- ── Editor ───────────────────────────────────────────────────────────────--
-- Esc in normal mode clears the search highlight left over from /foo. Esc does
-- nothing useful in normal mode otherwise, so there's no conflict.
map('n', '<Esc>', '<cmd>noh<CR>', { noremap = true, silent = true, desc = "Clear search highlight" })

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
map('n', '<leader>fn', '<cmd>Telescope find_files<CR>',                { noremap = true, silent = true, desc = "Find file by name" })
-- Jump between already-open files (buffers). Faster than ;fn when the file is
-- already loaded — shows your open buffers most-recently-used first.
map('n', '<leader>fb', '<cmd>Telescope buffers sort_mru=true<CR>',     { noremap = true, silent = true, desc = "Switch between open files (buffers)" })
map('n', '<leader>ff', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>', { noremap = true, silent = true, desc = "Search string in files (with args)" })
map('n', '<leader>fc', '<cmd>Telescope grep_string<CR>',               { noremap = true, silent = true, desc = "Search word under cursor" })
map('n', '<leader>fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { noremap = true, silent = true, desc = "Fuzzy search in current file" })
-- ;fo jumps to a symbol IN the current file via the LSP (VS Code Ctrl-Shift-O).
-- Single-file, so it's fast — leave it on the language server.
map('n', '<leader>fo', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, silent = true, desc = "Symbols in current file (outline)" })

-- ;fw jumps to a symbol DEFINITION anywhere in the project (VS Code Ctrl-T).
-- The LSP workspace-symbol version (lsp_dynamic_workspace_symbols) re-queries
-- pyright/ts_ls on every keystroke and is painfully slow on a big monorepo, so
-- this uses ripgrep instead: near-instant, at the cost of being text-based
-- rather than semantic. It greps for lines where your typed name FOLLOWS a
-- definition keyword (def/class/function/const/…), so it lands on where things
-- are DEFINED, not every place they're used. Limitation: JS/TS class methods
-- (which have no keyword — `foo() {`) won't match; use ;gd/;gr for those.
vim.keymap.set('n', '<leader>fw', function()
  local pickers    = require("telescope.pickers")
  local finders    = require("telescope.finders")
  local conf       = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  pickers.new({}, {
    prompt_title = "Project symbols (ripgrep)",
    -- new_job re-runs the command each time the prompt changes and feeds the
    -- output straight into the list, so as you type more of the name ripgrep
    -- narrows the results (VS Code Ctrl-T feel) with no fuzzy layer on top.
    finder = finders.new_job(function(prompt)
      -- Empty prompt → return nil so ripgrep isn't run with no pattern (which
      -- would dump every definition in the repo).
      if not prompt or prompt == "" then return nil end
      -- Build the definition regex: a def keyword, whitespace, then the typed
      -- name. Covers Python (def/class), JS/TS (function/const/let/var/type/
      -- interface/enum/class), and Lua/Go-ish (function/func/struct).
      local pattern = string.format(
        [[(class|def|async def|func|function|const|let|var|type|interface|enum|struct)\s+%s]],
        prompt)
      return {
        "rg", "--color=never", "--no-heading", "--with-filename",
        "--line-number", "--column", "--smart-case", "-e", pattern,
      }
    end, make_entry.gen_from_vimgrep({}), nil, nil),
    -- Show the matched file with the line highlighted, same as ;ff.
    previewer = conf.grep_previewer({}),
    -- generic_sorter lets you still fuzzy-order what ripgrep returned.
    sorter = conf.generic_sorter({}),
  }):find()
end, { noremap = true, silent = true, desc = "Symbols across the project (ripgrep)" })

-- ── Buffer tabs (bufferline) ─────────────────────────────────────────────────
-- The tabs along the top are your open files (buffers). These move between them
-- like VS Code tabs. Switching files by fuzzy name is still ;fb.
map('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>',  { noremap = true, silent = true, desc = "Next buffer tab" })
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>',  { noremap = true, silent = true, desc = "Previous buffer tab" })
map('n', '<leader>bp', '<cmd>BufferLinePick<CR>',        { noremap = true, silent = true, desc = "Pick a buffer tab by letter" })
-- ;bd closes the current buffer tab. A window should only ever show a real
-- file or the tree — never a blank [No Name] buffer — so the behaviour depends
-- on whether other files remain:
--   • Other files open → switch this window to the PREVIOUS tab first, then
--     delete the old buffer. Net effect: close tab 2 → land on 1, tab 6 → 5.
--   • Closing the LAST file → plain :bdelete would leave a blank window (and
--     the tree fullscreen-ing next to it). Instead open the tree, delete the
--     file, and close the now-empty code window so ONLY the tree is left.
vim.keymap.set('n', '<leader>bd', function()
  local cur = vim.api.nvim_get_current_buf()
  -- getbufinfo({buflisted=1}) = the open file tabs (what bufferline shows).
  local listed = #vim.fn.getbufinfo({ buflisted = 1 })

  if listed > 1 then
    vim.cmd("BufferLineCyclePrev")   -- move this window off the buffer we're closing
    vim.cmd("bdelete " .. cur)       -- safe to delete; window still shows a file
    return
  end

  -- Last real file. Keep the tree, drop the blank window it would leave behind.
  local codewin = vim.api.nvim_get_current_win()
  require("nvim-tree.api").tree.open()      -- ensure a tree window exists
  vim.api.nvim_set_current_win(codewin)     -- return focus to the code window
  vim.cmd("bdelete " .. cur)                -- delete the file (window goes blank)
  -- If the tree is now a separate window, close the blank code window so the
  -- tree is all that remains (never leave the [No Name] buffer on screen).
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    pcall(vim.api.nvim_win_close, codewin, false)
  end
end, { noremap = true, silent = true, desc = "Close current buffer tab (keep layout)" })
map('n', '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', { noremap = true, silent = true, desc = "Close all other buffer tabs" })
map('n', '<leader>bh', '<cmd>BufferLineMovePrev<CR>',    { noremap = true, silent = true, desc = "Move buffer tab left" })
map('n', '<leader>bl', '<cmd>BufferLineMoveNext<CR>',    { noremap = true, silent = true, desc = "Move buffer tab right" })
-- Jump straight to a tab by its ordinal number (matches the number shown on it).
for i = 1, 9 do
  map('n', '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<CR>',
      { noremap = true, silent = true, desc = "Go to buffer tab " .. i })
end

-- ── Window navigation ──────────────────────────────────────────────────────
-- Move focus between split windows with ;w + direction so you don't have to
-- reach for Ctrl-w. hjkl = left/down/up/right, same as the built-in Ctrl-w
-- h/j/k/l (which still works). Mnemonic: w = window.
map('n', '<leader>wh', '<C-w>h', { noremap = true, silent = true, desc = "Window left" })
map('n', '<leader>wj', '<C-w>j', { noremap = true, silent = true, desc = "Window down" })
map('n', '<leader>wk', '<C-w>k', { noremap = true, silent = true, desc = "Window up" })
map('n', '<leader>wl', '<C-w>l', { noremap = true, silent = true, desc = "Window right" })

-- ── AI helpers (pair with claudecode.nvim / any chat) ───────────────────────
-- ;a* command keymaps (toggle/send/accept-diff) live in the claudecode plugin
-- spec. These two are plain register helpers, so they work even when pasting
-- into a chat by hand. Both write the + register (→ Mac clipboard, OSC 52 over
-- SSH) and the unnamed register (so a normal p pastes it too).

-- ;ay — yank the visual selection WITH a "path:startline-endline" header, so
-- the snippet you paste tells the model exactly where it came from.
vim.keymap.set('x', '<leader>ay', function()
  local s, e = vim.fn.line('v'), vim.fn.line('.')
  if s > e then s, e = e, s end
  local body = table.concat(vim.fn.getline(s, e), '\n')
  local text = string.format('%s:%d-%d\n%s', vim.fn.expand('%:.'), s, e, body)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  vim.api.nvim_input('<Esc>')
end, { desc = "Yank selection + location for AI chat" })

-- ;ae — yank ALL diagnostics in the current file (line + severity + message),
-- ready to paste so the model can see the errors without a screenshot.
vim.keymap.set('n', '<leader>ae', function()
  local diags = vim.diagnostic.get(0)
  if vim.tbl_isempty(diags) then
    vim.notify('No diagnostics in this file')
    return
  end
  table.sort(diags, function(a, b) return a.lnum < b.lnum end)
  local names = { 'ERROR', 'WARN', 'INFO', 'HINT' }
  local out = { vim.fn.expand('%:.') }
  for _, d in ipairs(diags) do
    out[#out + 1] = string.format('  L%d [%s] %s', d.lnum + 1,
      names[d.severity] or '?', (d.message or ''):gsub('\n', ' '))
  end
  local text = table.concat(out, '\n')
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  vim.notify(string.format('Yanked %d diagnostics', #diags))
end, { desc = "Yank file diagnostics for AI chat" })

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
-- ;ih  Toggle inlay hints — the greyed inline type/return/parameter-name hints
--       VS Code shows. Off by default (they add visual noise); flip per-buffer.
--       Uses vim.keymap.set (not map()) because the rhs is a Lua function.
vim.keymap.set('n', '<leader>ih', function()
  -- is_enabled / enable take a filter table; { bufnr = 0 } means the current
  -- buffer. Read the current state, invert it, apply it back.
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(on, { bufnr = 0 })
  vim.notify("Inlay hints: " .. (on and "ON" or "OFF"))
end, { noremap = true, silent = true, desc = "Toggle inlay hints" })

-- ── Comments ─────────────────────────────────────────────────────────────--
-- Ctrl-/ toggles comments, matching VS Code's muscle memory. Neovim already
-- ships the gc operator (gcc = toggle line, gc in visual = toggle selection);
-- these just bind the VS Code keystroke to it. Terminals send <C-_> for Ctrl-/
-- (a historical quirk), while GUI/newer terminals send a literal <C-/>, so map
-- both. remap = true is REQUIRED: the rhs (gcc/gc) is itself a mapping, and
-- without remap Neovim would treat it as the built-in (nonexistent) commands.
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true, silent = true, desc = "Toggle comment line" })
vim.keymap.set('x', '<C-_>', 'gc',  { remap = true, silent = true, desc = "Toggle comment selection" })
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true, silent = true, desc = "Toggle comment line" })
vim.keymap.set('x', '<C-/>', 'gc',  { remap = true, silent = true, desc = "Toggle comment selection" })

-- ── Diagnostics ────────────────────────────────────────────────────────────
-- Navigate between LSP errors/warnings in the current file.
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true, desc = "Next diagnostic" })
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true, desc = "Prev diagnostic" })
-- Show all diagnostics for the project in a Telescope picker.
map('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>',  { noremap = true, silent = true, desc = "All diagnostics" })

-- ── Trouble (VS Code "Problems" panel) ───────────────────────────────────--
-- A persistent, grouped list you keep open while cleaning up, vs the one-shot
-- ;fd picker. All go through :Trouble, which lazy-loads the plugin on first use.
-- ;xx  every diagnostic in the project   ;xX  just the current file
-- ;xs  symbol outline of the current file (like a live table of contents)
-- ;xr  LSP references/definitions for the symbol under the cursor
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>',                        { noremap = true, silent = true, desc = "Trouble: project diagnostics" })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',           { noremap = true, silent = true, desc = "Trouble: current-file diagnostics" })
map('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<CR>',                { noremap = true, silent = true, desc = "Trouble: symbol outline" })
map('n', '<leader>xr', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', { noremap = true, silent = true, desc = "Trouble: LSP references/defs" })

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
-- Each terminal has a numeric id; the same id always reopens the same shell
-- session, so you can keep several long-running processes side by side.
-- These give named shortcuts for the common ids:
map('n', '<leader>sh', '<cmd>1ToggleTerm direction=float<CR>',      { noremap = true, silent = true, desc = "Toggle shell 1 (float)" })
-- Horizontal split terminal at the bottom — useful alongside a code buffer.
-- Reuses id 1 so ;sh and ;sv flip the same session between float and split.
map('n', '<leader>sv', '<cmd>1ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Toggle shell 1 (horizontal)" })
-- Independent terminal instances. Each id is a separate shell session, so you
-- can run a dev server in 1, tests in 2, a REPL in 3, etc.
map('n', '<leader>s2', '<cmd>2ToggleTerm direction=float<CR>',     { noremap = true, silent = true, desc = "Toggle shell 2 (float)" })
map('n', '<leader>s3', '<cmd>3ToggleTerm direction=float<CR>',     { noremap = true, silent = true, desc = "Toggle shell 3 (float)" })
map('n', '<leader>s4', '<cmd>4ToggleTerm direction=float<CR>',     { noremap = true, silent = true, desc = "Toggle shell 4 (float)" })
-- Horizontal split variants of shells 2–4 (like ;sv is for shell 1). Same id
-- as the float shortcut above, so ;s2 and ;sv2 flip the one session between
-- float and split rather than making a new one.
map('n', '<leader>sv2', '<cmd>2ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Toggle shell 2 (horizontal)" })
map('n', '<leader>sv3', '<cmd>3ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Toggle shell 3 (horizontal)" })
map('n', '<leader>sv4', '<cmd>4ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Toggle shell 4 (horizontal)" })
-- Manage them all: :TermSelect lists every open terminal in a menu so you can
-- jump straight to one by number/name without remembering which id is which.
map('n', '<leader>ss', '<cmd>TermSelect<CR>',                      { noremap = true, silent = true, desc = "Select / switch terminal" })
-- Close every open terminal at once (kills all the shell sessions).
map('n', '<leader>sq', '<cmd>ToggleTermToggleAll<CR>',             { noremap = true, silent = true, desc = "Toggle all terminals open/closed" })
-- Inside a terminal buffer, a single <Esc> is passed straight through to the
-- running program so TUIs that rely on Esc (Claude Code, vim, fzf, less) work.
-- Use a double <Esc><Esc> to leave terminal mode for Neovim normal mode, where
-- you can yank output, scroll, or close the window without killing the shell.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "Exit terminal insert mode" })

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
-- Workflow: set breakpoints with ;db, then ;da to attach. debugpy is always
-- listening in the Codespaces web container (ENABLE_DEBUGPY=true) — no script
-- to start. See plugins/debug.lua for the full workflow.
--
-- ;da  Attach to Django — connects to BOTH uwsgi workers (5678 + 5680) at once.
--       Use this to start debugging. uwsgi spreads requests across both
--       workers, so attaching to only one would miss half your breakpoints.
map('n', '<leader>da', '<cmd>DjangoDebugAttach<CR>',                      { noremap = true, silent = true, desc = "Debug: attach to Django (both workers)" })

-- ;dc  Continue / attach
--       While paused: resumes execution until the next breakpoint.
--       While idle: prompts to attach to a single worker (prefer ;da instead).
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

-- ;de  Toggle stopping on unhandled exceptions on/off.
--       Default is OFF — only ;db line breakpoints stop. Press ;de to also
--       pause the moment an exception goes unhandled (uncaught + userUnhandled);
--       press again to turn it back off. Applies to both worker sessions.
map('n', '<leader>de', '<cmd>DapToggleExceptions<CR>',                    { noremap = true, silent = true, desc = "Debug: toggle stop-on-exception" })
