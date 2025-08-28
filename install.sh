#!/usr/bin/env bash
set -e

echo "Setting up dotfiles for Codespaces..."

# Neovim config
mkdir -p ~/.config/nvim
cp -r $(pwd)/nvim/* ~/.config/nvim/

# Install plugins in headless mode
nvim --headless "$@" +qa


# Git config (safe to overwrite)
ln -sf $(pwd)/.gitconfig ~/.gitconfig

# shared bashrc and zshrc config
if ! grep -q "# DOTFILES CUSTOM SHARED SHELL CONFIG" ~/.bashrc; then
    echo -e "\n# DOTFILES CUSTOM SHARED SHELL CONFIG \nsource $(pwd)/.sharedrc.append" >> $(pwd)/.bashrc.append
fi

if ! grep -q "# DOTFILES CUSTOM SHARED SHELL CONFIG" ~/.zshrc; then
    echo -e "\n# DOTFILES CUSTOM SHARED SHELL CONFIG \nsource $(pwd)/.sharedrc.append" >> $(pwd)/.zshrc.append
fi

# Append custom zshrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM ZSHRC" ~/.zshrc; then
    echo -e "\n# DOTFILES CUSTOM ZSHRC\nsource $(pwd)/.zshrc.append" >> ~/.zshrc
fi

# Append custom bashrc without losing Codespaces defaults
if ! grep -q "# DOTFILES CUSTOM BASHRC" ~/.bashrc; then
    echo -e "\n# DOTFILES CUSTOM BASHRC\nsource $(pwd)/.bashrc.append" >> ~/.bashrc
fi


echo "Dotfiles setup complete!"
