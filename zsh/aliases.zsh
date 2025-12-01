# ============================================================================
# Aliases
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# List files
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias c='clear'
alias h='history'
alias q='exit'

# Git shortcuts (beyond oh-my-zsh git plugin)
alias gs='git status'
alias gd='git diff'
alias gp='git pull'
alias gpu='git push'
alias gco='git checkout'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gl='git log --oneline -10'
alias gla='git log --oneline --all --graph'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dex='docker exec -it'

# Laravel / PHP
alias art='php artisan'
alias sail='./vendor/bin/sail'
alias pest='./vendor/bin/pest'
alias phpunit='./vendor/bin/phpunit'

# Node / npm / pnpm
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias pn='pnpm'
alias pni='pnpm install'
alias pnr='pnpm run'

# System
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-code} ~/.zshrc'
alias dotfiles='cd ~/workspace/dotfiles-linux'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Show disk usage
alias df='df -h'
alias du='du -h'
alias dud='du -d 1 -h'

# Network
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
