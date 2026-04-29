# -------------------------------------
# Displays All Relevant Custom Messages
# -------------------------------------

__COMMANDS=(
"cl|clear"
"gac|git add and commit (usage: gac <commit message>)"
"ga|git add ."
"gw|git worktree"
"gcmp|git add, commit, push (usage: gcmp <commit message>)"
"gc|git commit with message (usage: gc <commit message>)"
"gdiff|git diff"
"gd|git diff"
"gf|git fetch"
"glog|git log"
"gp|git push"
"gs|git status"
"la|ls -alf"
"ll|ls -a"
"lt|ls --tree"
"lT|ls --tree -D"
"py|uv run"
"ta|tmux attach -t"
"tl|tmux ls"
"tn|tmux new -s"
"v|nvim"
"nn|nix new"
"sv|python venv sync"
"svu|python venv sync (w uv)"
"gtc|gt checkout"
"gts|gt submit --stack --ai"
"fmt_name|formats filenames"
"killport|kills port"
)


_create_top_border() {
    local top_border="╭"
    top_border+=$(printf '─%.0s' {1..$1})
    top_border+="╮"
    echo "$top_border"
}
_create_title() {
    local title="Custom Aliases and Functions:"
    printf "│ %-$(($1 - 2))s │\n" "$title"
}
_create_mid_border() {
    local mid_border="├────────────┬"
    mid_border+=$(printf '─%.0s' {1..$(($1 - 13))})
    mid_border+="┤"
    echo "$mid_border"
}
_create_bottom_border() {
    local bot_border="╰────────────┴"
    bot_border+=$(printf '─%.0s' {1..$(($1 - 13))})
    bot_border+="╯"
    echo "$bot_border"

}
_clean_up() {
    while true; do
        read -q "REPLY?Press the enter key to continue... "
        if [[ "$REPLY" ]] then
            for ((i = 0; i < $(($1 + 5)); i++)); do
                echo -ne "\033[1A" # Move cursor up one line
                echo -ne "\033[2K" # Clear line
            done
            break
        fi
    done
}

custom() {

    local term_width=$(($(tput cols) - 2)) # get terminal width
    local col2_width=$((term_width - 10 - 5))

    _create_top_border $term_width # ╭──────╮
    _create_title $term_width
    _create_mid_border $term_width # ───────


    local format="│ \033[92m%-10s\033[0m │ %-${col2_width}s │\n"

    for cmd in "${__COMMANDS[@]}"; do
        IFS='|' read -r alias description <<< "$cmd"
        printf "$format" "$alias" "$description"
    done

    _create_bottom_border $term_width # ╰─────╯
    _clean_up  ${#__COMMANDS[@]}
}
