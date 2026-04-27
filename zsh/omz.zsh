ZSH_THEME=""

# Save the location of the current completion dump file.
if [ -z "$ZSH_COMPDUMP" ]; then
  ZSH_COMPDUMP="${ZDOTDIR:-${ZSH}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

export NVM_LAZY_LOAD=true
# export NVM_COMPLETION=true

plugins=(
    fast-syntax-highlighting
    zsh-autosuggestions
    web-search
    zsh-interactive-cd
    zsh-nvm # Install: https://github.com/lukechilds/zsh-nvm
)

export ZSH="$HOME/.oh-my-zsh"
source "$ZSH"/oh-my-zsh.sh

export LANG=en_US.UTF-8


# To customize prompt, run `p10k configure` or edit ~/p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(thefuck --alias)"
eval "$(zoxide init zsh)"

[ -f "/Users/giladkestenberg/.ghcup/env" ] && . "/Users/giladkestenberg/.ghcup/env" # ghcup-env
