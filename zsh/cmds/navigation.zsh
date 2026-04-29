EZA_IGNORE='node_modules|__pycache__|.venv|venv|.mypy_cache|.pytest_cache|.ruff_cache|.next|.turbo|dist|build|target|.terraform|.DS_Store|*.pyc|*.pyo'
alias ls="eza --icons=auto --git-ignore -I '$EZA_IGNORE'"
alias la="eza --icons=auto -alf"
alias ll="eza --icons=auto -a"
alias lt="eza --icons=auto --git-ignore -I '$EZA_IGNORE' --tree"
alias lT="eza --icons=auto --git-ignore -I '$EZA_IGNORE' --tree -D"

cD() {
    cd $1 && ls
}

function ranger {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command
        ranger
        --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
    )

    ${ranger_cmd[@]} "$@"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}
