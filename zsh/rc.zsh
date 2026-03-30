# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz compinit
compinit

source_if_exists () {
    if test -r $1; then
        source $1
    fi
}


source_if_exists "$HOME"/.env.sh
source_if_exists "$DOTFILES"/zsh/welcome.zsh
source_if_exists "$DOTFILES"/zsh/exports.zsh
source_if_exists "$DOTFILES"/zsh/p10k.zsh
source_if_exists "$DOTFILES"/zsh/alias.zsh
source_if_exists "$DOTFILES"/zsh/options.zsh
source_if_exists "$DOTFILES"/zsh/fzf.zsh
source_if_exists "$DOTFILES"/zsh/fzf-git.sh
source_if_exists "$DOTFILES"/zsh/eval.zsh
source_if_exists "$DOTFILES"/zsh/porter_compdef.zsh
source_if_exists "$DOTFILES"/zsh/compdef.zsh
source_if_exists "$DOTFILES"/zsh/omz.zsh
source_if_exists "$DOTFILES"/zsh/porter.zsh
source_if_exists "$DOTFILES"/zsh/gt-compdef.zsh
source_if_exists "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "/Users/giladkestenberg/.gvm/scripts/gvm" ]] && source "/Users/giladkestenberg/.gvm/scripts/gvm"
