__CHANGE_FILENAME_SCRIPT=~/projects/scripts

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


# ------------
# GIT COMMANDS 
# ------------

_ensure_commit() {
    if [ $# -eq 1 ]; then
        echo "usage: $1 <commit message>"
        return 1
    fi
    return 0
}

gc() {
    _ensure_commit $0 "$@" || return
    git commit -m "$@"
}
gac() {
    _ensure_commit $0 "$@" || return
    git add . && git commit -m "$@"
}
gac() {
    _ensure_commit $0 "$@" || return
    git add . && git commit -m "$@"
}
gcmp() {
    _ensure_commit $0 "$@" || return
    git add -A && git commit -m \"$@\" && git push
}
alias ga="git add ."
alias gw="git worktree"
alias gdiff="git diff"
alias gf="git fetch"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gp="git push"
alias gs="git status"

# -------------
# MISC COMMANDS
# -------------

# I want to use $@ for all arguments but they don't contain space for me
flutter-watch(){
  tmux send-keys "flutter run $@ --pid-file=/tmp/tf1.pid" Enter \;\
  split-window -v \;\
  send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter \;\
  resize-pane -y 5 -t 1 \;\
  select-pane -t 0 \;
}


alias cl="clear"

EZA_IGNORE='node_modules|__pycache__|.venv|venv|.mypy_cache|.pytest_cache|.ruff_cache|.next|.turbo|dist|build|target|.terraform|.DS_Store|*.pyc|*.pyo'
alias ls="eza --icons=auto --git-ignore -I '$EZA_IGNORE'"
alias la="eza --icons=auto -alf"
alias ll="eza --icons=auto -a"
alias lt="eza --icons=auto --git-ignore -I '$EZA_IGNORE' --tree"
alias lT="eza --icons=auto --git-ignore -I '$EZA_IGNORE' --tree -D"

alias bat="bat --style=plain"
alias python="python3"
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tn="tmux new -s"

alias py="uv run"

alias sv="source .venv/bin/activate"
alias svu="sv && uv sync"
alias gtc="gt checkout"
alias gts="gt submit --stack --ai"
alias lz="lazygit"

if command -v nvim >/dev/null 2>&1; then
    alias v="nvim"
else
    alias v="vim"
fi

cD() {
    cd $1 && ls
}

# --------------
# Helper Scripts
# --------------

g_fname() { py "$__CHANGE_FILENAME_SCRIPT/change_filename.py" "$@" }
g_gettext() { py "$__CHANGE_FILENAME_SCRIPT/extract_text.py" "$@" }  

# ------------------------
# Service Helper Functions
# ------------------------

_print_process_status() {
    local orange="\033[33m" 
    local green="\033[32m" 
    local reset="\033[0m"

    case "$1" in
        start_on)  echo -e "[START] ${orange}$2${reset} is already running." ;;
        start_off) echo -e "[START] ${green}$2${reset} is starting..." ;;
        stop_off)  echo -e "[STOP] ${orange}$2${reset} is not running." ;;
        stop_on)   echo -e "[STOP] ${green}$2${reset} is stopping..." ;;
    esac
}

start() {
    if [[ -z "$1" ]]; then
        start "yabai" "skhd" "borders"
        return
    fi

    for service in "$@"; do
        case "$service" in
            yabai)
                if [[ -z $(pgrep yabai) ]]; then
                    (nohup yabai & disown) >/dev/null 2>&1
                    _print_process_status start_off yabai
                else
                    _print_process_status start_on yabai
                fi
                ;;
            borders)
                brew services start borders
                ;;
            skhd)
                skhd --start-service
                ;;
            sketch)
                brew services start sketchybar
                ;;
            *)
                echo "[ERROR] Unsupported service: $service"
                echo "Usage: start <yabai|borders|skhd>"
                ;;
        esac
    done
}

stop() {
    for service in "$@"; do
        case "$service" in
            yabai)
                kill $(pgrep "$service")
                ;;
            borders)
                brew services stop borders
                ;;
            skhd)
                skhd --restart-service
                ;;
            sketch)
                brew services stop sketchybar
                ;;
            *)
                echo "[ERROR] Unsupported service: $service"
                echo "Usage: stop <yabai|borders|skhd>"
                ;;
        esac
        _print_process_status stop_on "$service"
    done
}

restart() {
    case "$1" in
        yabai)
            stop "yabai"
            start "yabai"
            ;;
        borders)
            brew services restart borders
            ;;
        skhd)
            skhd --restart-service
            ;;
        sketch)
            brew services restart sketchybar
            ;;
        *)
            echo "Usage: restart <yabai|borders|skhd>"
            return 1
            ;;
    esac
}

goinit() {
  local gh_user repo_name

  if ! command -v gh &>/dev/null; then
    echo "GitHub CLI (gh) not found."
    return 1
  fi

  if ! gh auth status &>/dev/null; then
    echo "You are not logged into GitHub CLI. Run 'gh auth login' first."
    return 1
  fi

  gh_user=$(gh api user --jq .login)

  if [ -n "$1" ]; then
    repo_name="$1"
  else
    repo_name=$(basename "$PWD")
  fi

  go mod init "github.com/$gh_user/$repo_name"
}

ghpr() {
  gh pr create --title "$1" --body "$2"
}

alias g_wt='cd $(git worktree list | fzf | awk "{print \$1}")'

# Soft rebase to graphite parent
gt_r() {
  local parent=$(gt log --steps 1 2>/dev/null | grep -oE 'gk/[a-zA-Z0-9_-]+|main' | tail -1)
  if [[ -z "$parent" ]]; then
    echo "Could not determine parent branch"
    return 1
  fi
  echo "Soft rebasing to: $parent"
  git reset --soft "$parent"
}

alias gtl="gt log short --no-interactive"

killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port>"
    return 1
  fi
  
  local pid=$(lsof -ti :$1)
  
  if [ -z "$pid" ]; then
    echo "No process found on port $1"
    return 1
  fi
  
  echo "Killing process $pid on port $1"
  kill -9 $pid
}

parse() {
    local use_jq=false
    
    if [[ "$1" == "-j" ]]; then
        use_jq=true
    fi
    
    # Try clipboard first, fallback to read
    local input
    if command -v pbpaste &> /dev/null; then
        input=$(pbpaste)
    else
        print -n "Paste base64: "
        read -r input
    fi
    
    local decoded=$(echo "$input" | base64 -d 2>/dev/null)
    
    if [[ -z "$decoded" ]]; then
        echo "Error: Failed to decode base64"
        return 1
    fi
    
    echo "=== Decoded ==="
    
    # Format with jq if requested
    if $use_jq; then
        echo "$decoded" | jq
    else
        echo "$decoded"
    fi
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

bg() {
  (
    output=$("$@" 2>&1)
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "Command failed ($status): $*" >&2
      echo "$output" >&2
    fi
  ) & disown
}

_PROMPT_DIR="${0:A:h}"

g_c() {
  uv run --script "${_PROMPT_DIR}/scripts/git_checkout.py" "$@"
}
_g_c() {
  _arguments '1: :(-a --all)'
}
compdef _g_c g_c

g_s() {
    uv run --script "${_PROMPT_DIR}/scripts/git_submit.py" "$@"
}
