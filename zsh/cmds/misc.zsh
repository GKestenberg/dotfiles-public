__CHANGE_FILENAME_SCRIPT=~/projects/scripts

alias cl="clear"
alias bat="bat --style=plain"
alias python="python3"
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tn="tmux new -s"
alias py="uv run"
alias sv="source .venv/bin/activate"
alias svu="sv && uv sync"
alias lz="lazygit"

if command -v nvim >/dev/null 2>&1; then
    alias v="nvim"
else
    alias v="vim"
fi

# I want to use $@ for all arguments but they don't contain space for me
flutter-watch(){
  tmux send-keys "flutter run $@ --pid-file=/tmp/tf1.pid" Enter \;\
  split-window -v \;\
  send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter \;\
  resize-pane -y 5 -t 1 \;\
  select-pane -t 0 \;
}

# --------------
# Helper Scripts
# --------------

g_fname() { py "$__CHANGE_FILENAME_SCRIPT/change_filename.py" "$@" }
g_gettext() { py "$__CHANGE_FILENAME_SCRIPT/extract_text.py" "$@" }

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

_PROMPT_DIR="${0:A:h}/.."

alias g_c="gk git checkout"
alias g_s="gk git submit"
