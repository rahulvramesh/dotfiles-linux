#!/bin/bash
# ============================================================================
# Devcontainer Post-Create Script
# This script runs after the devcontainer is created
# ============================================================================

set -e

echo "Setting up dotfiles in devcontainer..."

# Clone dotfiles if not present (for codespaces or fresh containers)
DOTFILES_DIR="$HOME/dotfiles-linux"

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles repository..."
    git clone https://github.com/rahulvramesh/dotfiles-linux.git "$DOTFILES_DIR"
fi

# Run the install script in devcontainer mode
if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
    chmod +x "$DOTFILES_DIR/install.sh"
    bash "$DOTFILES_DIR/install.sh" --devcontainer
fi

echo "Dotfiles setup complete!"
