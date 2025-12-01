# ============================================================================
# Custom Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.tar.xz)    tar xJf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill process by name
killnamed() {
    ps aux | grep -v grep | grep -i "$1" | awk '{print $2}' | xargs kill -9
}

# Quick backup of a file
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Git: show diff of uncommitted changes in VS Code
gdiff() {
    git diff HEAD | code -
}

# Docker: remove all stopped containers
docker-clean() {
    docker container prune -f
    docker image prune -f
    docker volume prune -f
}

# Docker: shell into a running container
dsh() {
    docker exec -it "$1" /bin/sh
}

# Docker: bash into a running container
dbash() {
    docker exec -it "$1" /bin/bash
}

# Find files by name
ff() {
    find . -type f -iname "*$1*"
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*"
}

# Get weather
weather() {
    curl -s "wttr.in/${1:-}"
}

# Start a simple HTTP server in current directory
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Create a new Laravel project
laravel-new() {
    composer create-project laravel/laravel "$1"
    cd "$1"
}

# JSON pretty print
json() {
    if [[ -t 0 ]]; then
        python3 -m json.tool "$@"
    else
        python3 -m json.tool
    fi
}
