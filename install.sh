#!/usr/bin/env bash
set -e

echo "Setting up dotfiles for Codespaces..."

# Neovim config
mkdir -p ~/.config/nvim
cp -r $(pwd)/nvim/* ~/.config/nvim/

# Install plugins in headless mode
nvim --headless "$@" +qa

# config help text
nvim --headless +"helptags ALL" +qa

# Ghostty terminfo — when SSH'd into this codespace from Ghostty, TERM is
# xterm-ghostty, which the box doesn't know ("unknown terminal type"), breaking
# clear/less/vim. Compile the bundled terminfo source into ~/.terminfo so those
# work. (gh codespace ssh isn't wrapped by Ghostty's ssh-terminfo integration,
# so we install it here instead.)
if command -v tic >/dev/null 2>&1 && [ -f "$(pwd)/ghostty.terminfo" ]; then
    tic -x "$(pwd)/ghostty.terminfo" 2>/dev/null || true
fi


# tmux MCP server — isolated venv so the `mcp` SDK never fights the monorepo's
# own Python env. Guarded on the venv python existing so the slow pip install
# only runs on first setup (keeps re-runs fast + idempotent). Non-fatal: a
# failure here warns but doesn't abort the rest of the install (nvim, shell).
TMUX_MCP_VENV="$HOME/.tmux-mcp-venv"
if [ ! -x "$TMUX_MCP_VENV/bin/python" ]; then
    echo "Provisioning tmux MCP server venv..."
    # The venv/pip commands live inside the `if` condition so `set -e` treats a
    # failure as a false branch (warn + continue) instead of aborting install.sh.
    if python3 -m venv "$TMUX_MCP_VENV" &&
        "$TMUX_MCP_VENV/bin/pip" install --quiet --upgrade pip mcp; then
        echo "tmux MCP server venv ready."
    else
        echo "WARNING: tmux MCP server venv setup failed; skipping it (rest of install continues)." >&2
    fi
fi
# Make the server directly executable too (handy for local testing on the box).
[ -f "$(pwd)/bin/tmux-mcp-server.py" ] && chmod +x "$(pwd)/bin/tmux-mcp-server.py"

# Git config (safe to overwrite)
ln -sf $(pwd)/.gitconfig ~/.gitconfig

DOTFILES_ROOT=/workspaces/.codespaces/.persistedshare/dotfiles

# shared bashrc and zshrc config
if ! grep -q "# DOTFILES CUSTOM SHARED SHELL CONFIG" $DOTFILES_ROOT/.bashrc.append; then
    echo -e "\n# DOTFILES CUSTOM SHARED SHELL CONFIG \nsource $DOTFILES_ROOT/.sharedrc.append" >> $DOTFILES_ROOT/.bashrc.append
fi

if ! grep -q "# DOTFILES CUSTOM SHARED SHELL CONFIG" $DOTFILES_ROOT/.zshrc.append; then
    echo -e "\n# DOTFILES CUSTOM SHARED SHELL CONFIG \nsource $DOTFILES_ROOT/.sharedrc.append" >> $DOTFILES_ROOT/.zshrc.append
fi

# Append custom zshrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM ZSHRC" ~/.zshrc; then
    echo -e "\n# DOTFILES CUSTOM ZSHRC\nsource $DOTFILES_ROOT/.zshrc.append" >> ~/.zshrc
fi

# Append custom bashrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM BASHRC" ~/.bashrc; then
    echo -e "\n# DOTFILES CUSTOM BASHRC\nsource $DOTFILES_ROOT/.bashrc.append" >> ~/.bashrc
fi

echo "Dotfiles setup complete!"
