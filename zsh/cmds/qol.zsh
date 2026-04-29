source_zsh() {
    local query="${1%.zsh}"
    local file

    file=$(find "$DOTFILES/zsh" -name '*.zsh' -type f | fzf --query="$query" --select-1 --exit-0)

    if [[ -n "$file" ]]; then
        source "$file"
        echo "Sourced: ${file#$DOTFILES/}"
    fi
}
