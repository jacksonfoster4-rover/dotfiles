#!/bin/bash

# Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
    export PATH="$HOME/.local/bin:$PATH"
fi

# Apply dotfiles
chezmoi init --apply {{ .gitUser }}

~/.local/share/nvim/mason/bin/mason install pyright tsserver debugpy
