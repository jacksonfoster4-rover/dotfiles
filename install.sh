#!/usr/bin/env bash
set -e

echo "Setting up dotfiles for Codespaces..."

# Neovim config
mkdir -p ~/.config/nvim
cp -r $(pwd)/nvim/* ~/.config/nvim/


# Git config (safe to overwrite)
ln -sf $(pwd)/.gitconfig ~/.gitconfig

# Append custom zshrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM ZSHRC" ~/.zshrc; then
    echo -e "\n# DOTFILES CUSTOM ZSHRC\nsource $(pwd)/.zshrc.append" >> ~/.zshrc
fi

# Append custom bashrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM BASHRC" ~/.bashrc; then
    echo -e "\n# DOTFILES CUSTOM BASHRC\nsource $(pwd)/.bashrc.append" >> ~/.bashrc
fi

echo "Dotfiles setup complete!"
