autoload -Uz compinit
compinit

source_if_exists () {
    if [[ -d "$1" ]]; then
        for f in "$1"/*.zsh(N) "$1"/*.sh(N); do
            source "$f"
        done
    elif [[ -r "$1" ]]; then
        source "$1"
    fi
}
export DOTFILES=/Users/giladkestenberg/dotfiles

source_if_exists "$DOTFILES"/zsh/exports.zsh
source_if_exists "$DOTFILES"/zsh/cmds
source_if_exists "$DOTFILES"/zsh/options.zsh
source_if_exists "$DOTFILES"/zsh/fzf.zsh
source_if_exists "$DOTFILES"/zsh/fzf-git.sh
source_if_exists "$DOTFILES"/zsh/eval.zsh
source_if_exists "$DOTFILES"/zsh/porter_compdef.zsh
source_if_exists "$DOTFILES"/zsh/compdef.zsh
source_if_exists "$DOTFILES"/zsh/omz.zsh
source_if_exists "$DOTFILES"/zsh/prompt_theme.zsh
source_if_exists "$DOTFILES"/zsh/porter.zsh
source_if_exists "$DOTFILES"/zsh/gt-compdef.zsh
source_if_exists "$DOTFILES"/zsh/local.zsh
source_if_exists "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "/Users/giladkestenberg/.gvm/scripts/gvm" ]] && source "/Users/giladkestenberg/.gvm/scripts/gvm"
