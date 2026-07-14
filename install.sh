#!/usr/bin/env bash
set -e

echo "Setting up dotfiles for Codespaces..."

# Neovim — install a modern build if the box doesn't have one. The plugin +
# treesitter steps below want nvim >= 0.9 (apt's build is too old), and a
# Codespace base image doesn't always ship nvim at all, so grab the official
# stable linux tarball into ~/.local. Best-effort: if it can't be installed we
# warn and skip the nvim steps rather than aborting the whole install (set -e
# is suspended inside the `if` condition, so a mid-chain failure just warns).
if ! command -v nvim >/dev/null 2>&1; then
    echo "nvim not found — installing a stable build..."
    case "$(uname -m)" in
        x86_64)        nvim_asset="nvim-linux-x86_64.tar.gz" ;;
        aarch64|arm64) nvim_asset="nvim-linux-arm64.tar.gz" ;;
        *)             nvim_asset="" ;;
    esac
    if [ -n "$nvim_asset" ] &&
        curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$nvim_asset" -o /tmp/nvim.tar.gz &&
        mkdir -p "$HOME/.local/bin" &&
        tar -C "$HOME/.local" -xzf /tmp/nvim.tar.gz; then
        # The tarball's top-level dir matches the asset name minus .tar.gz.
        ln -sf "$HOME/.local/${nvim_asset%.tar.gz}/bin/nvim" "$HOME/.local/bin/nvim"
        # Put it on PATH for the rest of THIS script; ~/.local/bin is already on
        # PATH for future interactive shells on Codespaces.
        export PATH="$HOME/.local/bin:$PATH"
        rm -f /tmp/nvim.tar.gz
        echo "nvim installed to $HOME/.local/${nvim_asset%.tar.gz}."
    else
        echo "WARNING: could not install nvim automatically ($(uname -m)); skipping nvim config steps." >&2
    fi
fi

# Neovim config + plugins — only if nvim is actually available (present already
# or just installed above); otherwise skip so the shell/git config still runs.
if command -v nvim >/dev/null 2>&1; then
    mkdir -p ~/.config/nvim
    cp -r $(pwd)/nvim/* ~/.config/nvim/

    # Install plugins in headless mode
    nvim --headless "$@" +qa

    # config help text
    nvim --headless +"helptags ALL" +qa
fi

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

# Codespace CLAUDE.md guidance — teach every Claude agent on this box the
# worktree/run rules (only /workspaces/web can run the site + aliases). We APPEND
# an @import line (a plain markdown comment as the idempotency marker, so it's
# invisible in the rendered memory) instead of overwriting ~/.claude/CLAUDE.md,
# which may already hold other content. Because it's an import, edits to the
# guidance file are picked up without re-running install.sh.
CLAUDE_MEMORY="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
touch "$CLAUDE_MEMORY"
if ! grep -qF "<!-- dotfiles:codespace-worktree-guidance -->" "$CLAUDE_MEMORY"; then
    printf '\n<!-- dotfiles:codespace-worktree-guidance -->\n@%s\n' \
        "$DOTFILES_ROOT/claude/codespace-worktree.md" >> "$CLAUDE_MEMORY"
fi

echo "Dotfiles setup complete!"
