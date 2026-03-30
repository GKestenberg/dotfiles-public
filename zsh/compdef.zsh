# Adds completion for start and stop commands
# Purely for zsh completions
#
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org#toc-completion-for-a-command-with-multiple-arguments

_complete_cmds() {
    local -a options=("sketch" "yabai")

    # Provide completion only if the user is typing the second argument
    if [[ $CURRENT -eq 2 ]]; then
        compadd -W '' -- "${options[@]}"
    fi
}
compdef _complete_cmds start
compdef _complete_cmds stop

if command -v porter &>/dev/null; then
      eval "$(porter completion zsh)"
fi

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
