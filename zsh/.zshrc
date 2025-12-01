# ============================================================================
# ZSH Configuration
# Dotfiles: https://github.com/rahulvramesh/dotfiles-linux
# ============================================================================

# Path to dotfiles
export DOTFILES="$HOME/workspace/dotfiles-linux"

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# ----------------------------------------------------------------------------
# Theme: Powerlevel10k
# ----------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt (should stay at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

# ----------------------------------------------------------------------------
# Oh-My-Zsh Configuration
# ----------------------------------------------------------------------------
# Disable auto-update prompts (update manually)
zstyle ':omz:update' mode reminder

# Display red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files as dirty (faster for large repos)
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History timestamp format
HIST_STAMPS="yyyy-mm-dd"

# ----------------------------------------------------------------------------
# Load Plugins Configuration
# ----------------------------------------------------------------------------
source "$DOTFILES/zsh/plugins.zsh"

# ----------------------------------------------------------------------------
# Initialize Oh-My-Zsh
# ----------------------------------------------------------------------------
source "$ZSH/oh-my-zsh.sh"

# ----------------------------------------------------------------------------
# Load Custom Modules
# ----------------------------------------------------------------------------
source "$DOTFILES/zsh/exports.zsh"
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/functions.zsh"

# ----------------------------------------------------------------------------
# Powerlevel10k Configuration
# ----------------------------------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ----------------------------------------------------------------------------
# Local overrides (not tracked in git)
# ----------------------------------------------------------------------------
[[ -f "$DOTFILES/zsh/local.zsh" ]] && source "$DOTFILES/zsh/local.zsh"
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
