ZSH_THEME=""

# Save the location of the current completion dump file.
if [ -z "$ZSH_COMPDUMP" ]; then
  ZSH_COMPDUMP="${ZDOTDIR:-${ZSH}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

export NVM_LAZY_LOAD=true

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

CACHE=~/.zsh/cache
mkdir -p $CACHE

# Cache a tool's shell-init output, regenerating only when the file is missing.
# Usage: _cache_init <name> <command...>
_cache_init() {
  local name=$1; shift
  local file=$CACHE/$name.zsh
  [[ -f $file ]] || "$@" >$file 2>/dev/null
  source $file
}

_cache_init thefuck thefuck --alias
_cache_init zoxide  zoxide init zsh


[ -f "/Users/giladkestenberg/.ghcup/env" ] && . "/Users/giladkestenberg/.ghcup/env" # ghcup-env
