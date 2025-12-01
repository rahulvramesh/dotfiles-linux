#!/bin/bash
# ============================================================================
# Symlink Script - Create/update symlinks without full installation
# Usage: ./scripts/symlink.sh
# ============================================================================

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Creating symlinks from $DOTFILES..."

# ZSH
ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
echo "Linked ~/.zshrc"

# Git
ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
echo "Linked ~/.gitconfig"

# Ghostty
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
echo "Linked ~/.config/ghostty/config"

echo ""
echo "Done! Run 'source ~/.zshrc' to reload configuration."
