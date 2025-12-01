# ============================================================================
# Environment Variables & PATH
# ============================================================================

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Default editor
export EDITOR='code --wait'
export VISUAL='code --wait'

# History configuration
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Node.js
if [[ -d "$HOME/.local/opt/node/bin" ]]; then
    export PATH="$HOME/.local/opt/node/bin:$PATH"
fi

# Herd Lite (PHP, Composer, Laravel)
if [[ -d "$HOME/.config/herd-lite/bin" ]]; then
    export PATH="$HOME/.config/herd-lite/bin:$PATH"
fi

# OpenCode
if [[ -d "$HOME/.opencode/bin" ]]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi

# Cargo (Rust)
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go
if [[ -d "$HOME/go/bin" ]]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# envman
[[ -s "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"
