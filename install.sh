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
# Install CLI Tools
# ----------------------------------------------------------------------------
install_cli_tools() {
    info "Installing CLI tools..."

    # Ensure ~/.local/bin exists
    mkdir -p "$HOME/.local/bin"

    # APT packages
    local APT_PACKAGES=(
        fzf           # Fuzzy finder
        ripgrep       # Better grep
        fd-find       # Better find
        bat           # Better cat
        jq            # JSON processor
        btop          # Better top/htop
    )

    info "Installing apt packages..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${APT_PACKAGES[@]}" 2>/dev/null || true
    success "APT packages installed"

    # Create symlinks for differently named tools
    # fd-find installs as 'fdfind' on Ubuntu
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    fi
    # bat installs as 'batcat' on Ubuntu
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    fi

    # eza (modern ls replacement)
    if command -v eza >/dev/null 2>&1; then
        success "eza already installed"
    else
        info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update -qq && sudo apt-get install -y -qq eza 2>/dev/null || true
        success "eza installed"
    fi

    # zoxide (smarter cd)
    if command -v zoxide >/dev/null 2>&1; then
        success "zoxide already installed"
    else
        info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh 2>/dev/null
        success "zoxide installed"
    fi

    # lazygit
    if command -v lazygit >/dev/null 2>&1; then
        success "lazygit already installed"
    else
        info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -fsSLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C "$HOME/.local/bin" lazygit
        rm /tmp/lazygit.tar.gz
        success "lazygit installed"
    fi

    # lazydocker
    if command -v lazydocker >/dev/null 2>&1; then
        success "lazydocker already installed"
    else
        info "Installing lazydocker..."
        curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>/dev/null
        success "lazydocker installed"
    fi

    success "CLI tools installation complete"
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
# Install AI Coding Tools (OpenCode, Claude Code)
# ----------------------------------------------------------------------------
install_ai_tools() {
    info "Installing AI coding tools..."

    # OpenCode (https://opencode.ai)
    if command -v opencode >/dev/null 2>&1; then
        success "OpenCode already installed"
    else
        info "Installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash 2>/dev/null
        success "OpenCode installed"
    fi

    # Claude Code (https://claude.ai)
    if command -v claude >/dev/null 2>&1; then
        success "Claude Code already installed"
    else
        info "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null
        success "Claude Code installed"
    fi

    success "AI coding tools installation complete"
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
    install_cli_tools
    install_ai_tools
    create_symlinks

    # VM-only installs (skip in devcontainer)
    if [[ "$DEVCONTAINER" == false ]]; then
        install_fonts
        install_tailscale
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
