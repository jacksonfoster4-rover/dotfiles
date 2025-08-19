#!/usr/bin/env bash
set -e

echo "Setting up dotfiles for Codespaces..."

# Neovim config
mkdir -p ~/.config
ln -sf $(pwd)/.config/nvim ~/.config/nvim

# Git config (safe to overwrite)
ln -sf $(pwd)/.gitconfig ~/.gitconfig

# Append custom zshrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM ZSHRC" ~/.zshrc; then
    echo -e "\n# DOTFILES CUSTOM ZSHRC\nsource $(pwd)/.zshrc.append" >> ~/.zshrc
fi

source ~/.zshrc

echo "Dotfiles setup complete!"
