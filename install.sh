#!/usr/bin/env bash
set -e

# Resolve the dotfiles checkout from THIS script's own location, so the installer
# works wherever the repo is cloned — a GitHub Codespace, a Coder workspace, or a
# plain local machine — instead of assuming Codespaces' persisted-share path.
# Everything below references $DOTFILES_ROOT, so there's a single source of truth.
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles..."

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
    cp -r "$DOTFILES_ROOT"/nvim/* ~/.config/nvim/

    # Install plugins in headless mode
    nvim --headless "$@" +qa

    # config help text
    nvim --headless +"helptags ALL" +qa

    # Language servers behind the LSP shortcuts (;gd go-to-definition, ;gr
    # references, ;rn rename, ;ca code actions, ;h hover, ;fo symbols …). Mason
    # manages these binaries. mason-lspconfig's `ensure_installed`
    # (plugins/mason_config.lua) kicks the installs off ASYNCHRONOUSLY — but the
    # `+qa` above quits the headless nvim before they finish, so on a fresh box
    # the servers aren't on disk at first launch and ;gd fails with a Mason
    # "not installed" error. Install them SYNCHRONOUSLY here instead: run
    # headless, `:MasonInstall` BLOCKS until every package is downloaded (Mason's
    # built-in headless/CI behaviour), so this line returns only once ;gd et al.
    # actually work. The names are Mason PACKAGE names (eslint-lsp,
    # typescript-language-server) — they differ from the lspconfig server names
    # used in ensure_installed. pyright, ts_ls and eslint are npm packages, so
    # Mason needs node + npm on PATH to build them; warn (don't abort) if missing.
    if ! command -v node >/dev/null 2>&1; then
        echo "WARNING: node not found — Mason can't build pyright/ts_ls/eslint; the LSP shortcuts (;gd, ;gr, …) stay dead until node is on PATH." >&2
    fi
    nvim --headless -c 'MasonInstall pyright ruff typescript-language-server eslint-lsp' -c 'qall' ||
        echo "WARNING: Mason server install failed; open nvim and run :Mason to finish it — the LSP shortcuts need these." >&2
fi

# ripgrep — telescope's live_grep / live_grep_args pickers (the ;ff and ;fc
# maps) hard-require it; without a real `rg` on PATH they error out with
# "'ripgrep' ... is a required dependency". The Codespace base image and a
# fresh Mac don't always ship it, so install it when missing. Best-effort like
# the nvim block above: warn and carry on rather than aborting the whole
# install. Guarded by `command -v rg` so re-runs are a no-op.
if ! command -v rg >/dev/null 2>&1; then
    echo "ripgrep not found — installing (needed for nvim ;ff search)..."
    if command -v brew >/dev/null 2>&1; then
        brew install ripgrep || echo "WARNING: 'brew install ripgrep' failed; install ripgrep manually so nvim ;ff works." >&2
    elif command -v apt-get >/dev/null 2>&1; then
        # Codespaces base images grant passwordless sudo; ripgrep is in apt.
        sudo apt-get update -y && sudo apt-get install -y ripgrep ||
            echo "WARNING: 'apt-get install ripgrep' failed; install ripgrep manually so nvim ;ff works." >&2
    else
        echo "WARNING: no brew/apt-get found to install ripgrep; nvim ;ff (telescope live_grep) needs it — install ripgrep manually." >&2
    fi
fi

# fd — the fast file finder telescope's find_files picker (;fn) prefers. Without
# it telescope falls back to `rg --files`, so ;fn still works, just slower. Best
# effort + idempotent like the ripgrep block above. On Debian/apt the package is
# `fd-find` and it installs the binary as `fdfind` (NOT `fd`) — telescope accepts
# either — so the guard checks for both before deciding it's missing.
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
    echo "fd not found — installing (speeds up the nvim ;fn file finder)..."
    if command -v brew >/dev/null 2>&1; then
        brew install fd || echo "WARNING: 'brew install fd' failed; ;fn still works via ripgrep." >&2
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y && sudo apt-get install -y fd-find ||
            echo "WARNING: 'apt-get install fd-find' failed; ;fn still works via ripgrep." >&2
    else
        echo "WARNING: no brew/apt-get found to install fd; ;fn will fall back to ripgrep (fine, just slower)." >&2
    fi
fi

# difit — GitHub-like local diff viewer for pre-PR review with inline comments.
# The `review` function in .sharedrc.append launches it for the current branch
# vs master, headless on a fixed port that Coder's port forwarding surfaces.
# Install globally via npm; guarded by `command -v difit` so re-runs are a no-op,
# and best-effort like the blocks above — warn and carry on if npm is missing.
if ! command -v difit >/dev/null 2>&1; then
    if command -v npm >/dev/null 2>&1; then
        echo "difit not found — installing (local diff review)..."
        npm install -g difit || echo "WARNING: 'npm install -g difit' failed; install it manually (npm i -g difit) for the 'review' alias." >&2
    else
        echo "WARNING: npm not found — skipping difit install; the 'review' alias needs it (npm i -g difit)." >&2
    fi
fi

# Ghostty terminfo — when SSH'd into this codespace from Ghostty, TERM is
# xterm-ghostty, which the box doesn't know ("unknown terminal type"), breaking
# clear/less/vim. Compile the bundled terminfo source into ~/.terminfo so those
# work. (gh codespace ssh isn't wrapped by Ghostty's ssh-terminfo integration,
# so we install it here instead.)
if command -v tic >/dev/null 2>&1 && [ -f "$DOTFILES_ROOT/ghostty.terminfo" ]; then
    tic -x "$DOTFILES_ROOT/ghostty.terminfo" 2>/dev/null || true
fi

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
# worktree/run rules (only /workspaces/web can run the site + aliases). The
# guidance file now lives in the synced claude-settings repo (versioned with the
# rest of the Claude config), not in dotfiles. We surface it on THIS box only:
# install.sh runs on dev boxes only, so the symlink below is created only on dev
# boxes. The @import line may sync into CLAUDE.md everywhere, but it points at the
# symlink path — so it resolves on a dev box and silently no-ops on the laptop,
# where the link is never created. We APPEND the @import (a markdown-comment
# idempotency marker keeps it invisible and re-runs safe) instead of overwriting
# ~/.claude/CLAUDE.md. Because it's an import, edits to the guidance file are
# picked up without re-running install.sh.
CLAUDE_MEMORY="$HOME/.claude/CLAUDE.md"
WORKTREE_GUIDANCE="$HOME/.local/share/claude-sync/repo/codespace-worktree.md"
mkdir -p "$HOME/.claude"
touch "$CLAUDE_MEMORY"
# Dev-box-only symlink into ~/.claude so the @import resolves here but not on the
# laptop (install.sh never runs there, so the link is never created).
[ -f "$WORKTREE_GUIDANCE" ] && ln -sf "$WORKTREE_GUIDANCE" "$HOME/.claude/codespace-worktree.md"
if ! grep -qF "<!-- dotfiles:codespace-worktree-guidance -->" "$CLAUDE_MEMORY"; then
    printf '\n<!-- dotfiles:codespace-worktree-guidance -->\n@%s\n' \
        "$HOME/.claude/codespace-worktree.md" >> "$CLAUDE_MEMORY"
fi

# Obsidian vault — the notes vault lives on the Mac, which the codespace can't
# see, so clone the separate GitHub repo onto the box and expose it to every
# Claude session as an additional readable directory (no manual /add-dir).
# Best-effort: git/jq failures warn but don't abort the rest of install.sh (the
# ops live inside the `if` so `set -e` treats a failure as a false branch). The
# `git pull` only runs on codespace create/reload — use `reload_dotfiles` (or a
# manual pull) to refresh mid-life.
VAULT_DIR="$HOME/rover-vault"
VAULT_REPO="jacksonfoster4-rover/rover-vault"
# A codespace's default gh/GITHUB_TOKEN is scoped to the source repo + its org and
# CANNOT read a private repo under my personal account, so there we authenticate with
# a fine-grained PAT exposed as the ROVER_VAULT_TOKEN Codespaces secret. Anywhere else
# (a Coder/Roverspace workspace, a local box) the ambient gh login is a token on my own
# account, which can read it — so hand the clone to `gh` and skip the PAT entirely.
clone_vault() {
    if [ "${CODESPACES:-}" = "true" ]; then
        if [ -z "${ROVER_VAULT_TOKEN:-}" ]; then
            echo "WARNING: ROVER_VAULT_TOKEN not set — skipping rover-vault clone. Add it as a Codespaces secret (fine-grained PAT, Contents: read+write)." >&2
            return 1
        fi
        # Embed the token in the remote URL so the Stop-hook's later pull/push also
        # authenticate without any extra credential-helper setup.
        git clone "https://oauth2:${ROVER_VAULT_TOKEN}@github.com/${VAULT_REPO}.git" "$VAULT_DIR"
        return
    fi
    if ! command -v gh >/dev/null 2>&1; then
        echo "WARNING: gh not installed — skipping rover-vault clone." >&2
        return 1
    fi
    if ! gh auth status >/dev/null 2>&1; then
        echo "WARNING: gh is not authenticated — skipping rover-vault clone. Run 'gh auth login' (or set GH_TOKEN) and re-run install.sh." >&2
        return 1
    fi
    gh repo clone "$VAULT_REPO" "$VAULT_DIR" || return 1
    # The remote carries no token, so point it at gh for credentials — repo-locally,
    # to leave ~/.gitconfig alone. The Stop hook's later pull/push then authenticate
    # the same way, and keep working after the ambient token rotates.
    git -C "$VAULT_DIR" config credential.helper '!gh auth git-credential'
}

if [ -d "$VAULT_DIR/.git" ]; then
    git -C "$VAULT_DIR" pull --ff-only || true
elif clone_vault; then
    echo "rover-vault cloned to $VAULT_DIR."
else
    echo "WARNING: could not clone rover-vault; skipping vault setup." >&2
fi

# Register the vault in Claude's global settings so every session can read it.
# Merge into permissions.additionalDirectories (idempotent via `unique`) instead
# of clobbering whatever else lives in settings.json.
if [ -d "$VAULT_DIR" ] && command -v jq >/dev/null 2>&1; then
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    [ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"
    settings_tmp=$(mktemp)
    if jq --arg d "$VAULT_DIR" \
        '.permissions.additionalDirectories = ((.permissions.additionalDirectories // []) + [$d] | unique)' \
        "$CLAUDE_SETTINGS" > "$settings_tmp"; then
        mv "$settings_tmp" "$CLAUDE_SETTINGS"
    else
        rm -f "$settings_tmp"
        echo "WARNING: could not register vault dir in $CLAUDE_SETTINGS." >&2
    fi
fi

echo "Dotfiles setup complete!"
