# Adds completion for start and stop commands
# Purely for zsh completions
#
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org#toc-completion-for-a-command-with-multiple-arguments

COMPDIR=~/.zsh/completions
mkdir -p $COMPDIR
fpath=($COMPDIR $fpath)

# Generate completion once, only if it doesn't already exist
if [[ ! -f $COMPDIR/_porter ]] && command -v porter &>/dev/null; then
  porter completion zsh > $COMPDIR/_porter
fi

if [[ ! -f $COMPDIR/_gk ]] && command -v gk &>/dev/null; then
  gk completion zsh > $COMPDIR/_gk
fi

autoload -Uz compinit
(( $+_comps )) || compinit

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

_complete_cmds() {
    local -a options=("sketch" "yabai")

    # Provide completion only if the user is typing the second argument
    if [[ $CURRENT -eq 2 ]]; then
        compadd -W '' -- "${options[@]}"
    fi
}
compdef _complete_cmds start
compdef _complete_cmds stop


