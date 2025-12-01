# ============================================================================
# Oh-My-Zsh Plugin Configuration
# ============================================================================

# Define plugins to load
plugins=(
    git                         # Git aliases and functions
    docker                      # Docker completions
    docker-compose              # Docker Compose completions
    composer                    # PHP Composer completions
    node                        # Node.js helpers
    npm                         # npm completions
    history-substring-search    # Better history search with up/down arrows
    zsh-autosuggestions         # Fish-like autosuggestions (external)
    zsh-syntax-highlighting     # Command syntax highlighting (external)
)

# Plugin-specific configurations

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# history-substring-search - bind to arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
