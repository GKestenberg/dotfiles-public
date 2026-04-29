autoload -Uz compinit
compinit

_source_if_exists () {
    if [[ -d "$1" ]]; then
        for f in "$1"/*.zsh(N) "$1"/*.sh(N); do
            source "$f"
        done
    elif [[ -r "$1" ]]; then
        source "$1"
    fi
}
export DOTFILES=/Users/giladkestenberg/dotfiles

_source_if_exists "$DOTFILES"/zsh/exports.zsh
_source_if_exists "$DOTFILES"/zsh/cmds
_source_if_exists "$DOTFILES"/zsh/options.zsh
_source_if_exists "$DOTFILES"/zsh/fzf.zsh
_source_if_exists "$DOTFILES"/zsh/fzf-git.sh
_source_if_exists "$DOTFILES"/zsh/eval.zsh
_source_if_exists "$DOTFILES"/zsh/porter_compdef.zsh
_source_if_exists "$DOTFILES"/zsh/compdef.zsh
_source_if_exists "$DOTFILES"/zsh/omz.zsh
_source_if_exists "$DOTFILES"/zsh/prompt_theme.zsh
_source_if_exists "$DOTFILES"/zsh/porter.zsh
_source_if_exists "$DOTFILES"/zsh/gt-compdef.zsh
_source_if_exists "$DOTFILES"/zsh/local.zsh
_source_if_exists "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "/Users/giladkestenberg/.gvm/scripts/gvm" ]] && source "/Users/giladkestenberg/.gvm/scripts/gvm"
