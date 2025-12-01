# ============================================================================
# CLI Tools Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# fzf - Fuzzy Finder
# ----------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    # Set up fzf key bindings and fuzzy completion
    source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null || true
    source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null || true

    # fzf configuration
    export FZF_DEFAULT_OPTS='
        --height 40%
        --layout=reverse
        --border
        --info=inline
        --preview-window=right:50%:wrap
    '

    # Use fd for fzf if available (faster, respects .gitignore)
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    # Preview with bat if available
    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    fi
fi

# ----------------------------------------------------------------------------
# zoxide - Smarter cd
# ----------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ----------------------------------------------------------------------------
# bat - Better cat
# ----------------------------------------------------------------------------
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="TwoDark"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ----------------------------------------------------------------------------
# eza - Modern ls
# ----------------------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
    # eza aliases are defined in aliases.zsh
    export EZA_COLORS="da=1;34:uu=33"
fi

# ----------------------------------------------------------------------------
# ripgrep
# ----------------------------------------------------------------------------
if command -v rg >/dev/null 2>&1; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# ----------------------------------------------------------------------------
# lazygit
# ----------------------------------------------------------------------------
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

# ----------------------------------------------------------------------------
# lazydocker
# ----------------------------------------------------------------------------
if command -v lazydocker >/dev/null 2>&1; then
    alias lzd='lazydocker'
fi

# ----------------------------------------------------------------------------
# btop
# ----------------------------------------------------------------------------
if command -v btop >/dev/null 2>&1; then
    alias top='btop'
    alias htop='btop'
fi
