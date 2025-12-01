#!/bin/bash
# ============================================================================
# Dotfiles Installation Script
# Usage: ./install.sh [--devcontainer]
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Determine script location
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Check if running in devcontainer
DEVCONTAINER=false
if [[ "$1" == "--devcontainer" ]] || [[ -f /.dockerenv ]] || [[ -n "$CODESPACES" ]] || [[ -n "$REMOTE_CONTAINERS" ]]; then
    DEVCONTAINER=true
    info "Running in devcontainer mode"
fi

# ----------------------------------------------------------------------------
# Backup function
# ----------------------------------------------------------------------------
backup_file() {
    local file="$1"
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
        warn "Backed up $(basename "$file") to $BACKUP_DIR/"
    elif [[ -L "$file" ]]; then
        rm "$file"
    fi
}

# ----------------------------------------------------------------------------
# Symlink function
# ----------------------------------------------------------------------------
create_symlink() {
    local src="$1"
    local dest="$2"

    backup_file "$dest"
    ln -sf "$src" "$dest"
    success "Linked $dest -> $src"
}

# ----------------------------------------------------------------------------
# Install Oh-My-Zsh
# ----------------------------------------------------------------------------
install_omz() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh-My-Zsh already installed"
    else
        info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh-My-Zsh installed"
    fi
}

# ----------------------------------------------------------------------------
# Install Powerlevel10k Theme
# ----------------------------------------------------------------------------
install_p10k() {
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ -d "$P10K_DIR" ]]; then
        success "Powerlevel10k already installed"
    else
        info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
        success "Powerlevel10k installed"
    fi
}

# ----------------------------------------------------------------------------
# Install External Plugins
# ----------------------------------------------------------------------------
install_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        success "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        success "zsh-autosuggestions installed"
    fi

    # zsh-syntax-highlighting
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        success "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting installed"
    fi
}

# ----------------------------------------------------------------------------
# Create Symlinks
# ----------------------------------------------------------------------------
create_symlinks() {
    info "Creating symlinks..."

    # ZSH
    create_symlink "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

    # Git
    create_symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

    # Ghostty (only if not in devcontainer)
    if [[ "$DEVCONTAINER" == false ]]; then
        mkdir -p "$HOME/.config/ghostty"
        create_symlink "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
    fi
}

# ----------------------------------------------------------------------------
# Install Recommended Fonts (optional)
# ----------------------------------------------------------------------------
install_fonts() {
    if [[ "$DEVCONTAINER" == true ]]; then
        return
    fi

    local FONT_DIR="$HOME/.local/share/fonts"

    if fc-list | grep -qi "JetBrains Mono"; then
        success "JetBrains Mono font already installed"
        return
    fi

    info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"

    # Download and install JetBrains Mono Nerd Font
    local TEMP_DIR=$(mktemp -d)
    curl -fsSL -o "$TEMP_DIR/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"

    unzip -q "$TEMP_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
    rm -rf "$TEMP_DIR"

    # Refresh font cache
    fc-cache -fv > /dev/null 2>&1
    success "JetBrains Mono Nerd Font installed"
}

# ----------------------------------------------------------------------------
# Install Tailscale (VM only)
# ----------------------------------------------------------------------------
install_tailscale() {
    if [[ "$DEVCONTAINER" == true ]]; then
        return
    fi

    if command -v tailscale >/dev/null 2>&1; then
        success "Tailscale already installed ($(tailscale version | head -1))"
        return
    fi

    info "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
    success "Tailscale installed"

    echo ""
    info "To start Tailscale, run:"
    echo "  sudo tailscale up"
    echo ""
}

# ----------------------------------------------------------------------------
# Main Installation
# ----------------------------------------------------------------------------
main() {
    echo ""
    echo "=============================================="
    echo "       Dotfiles Installation Script          "
    echo "=============================================="
    echo ""

    # Check for required commands
    command -v git >/dev/null 2>&1 || error "git is required but not installed"
    command -v curl >/dev/null 2>&1 || error "curl is required but not installed"
    command -v zsh >/dev/null 2>&1 || error "zsh is required but not installed"

    # Run installation steps
    install_omz
    install_p10k
    install_plugins
    create_symlinks

    # Optional installs (skip in devcontainer)
    if [[ "$DEVCONTAINER" == false ]]; then
        # Fonts
        read -p "Install JetBrains Mono Nerd Font? (recommended for Powerlevel10k) [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_fonts
        fi

        # Tailscale
        read -p "Install Tailscale? (VPN for secure networking) [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_tailscale
        fi
    fi

    echo ""
    echo "=============================================="
    success "Dotfiles installation complete!"
    echo "=============================================="
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Run 'p10k configure' to customize your prompt"
    if [[ "$DEVCONTAINER" == false ]]; then
        echo "  3. Run 'sudo tailscale up' to connect to Tailscale (if installed)"
        echo "  4. (Optional) Edit $DOTFILES/zsh/local.zsh for machine-specific config"
    else
        echo "  3. (Optional) Edit $DOTFILES/zsh/local.zsh for machine-specific config"
    fi
    echo ""
}

main "$@"
