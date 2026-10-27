# Plugins, sourced directly (no plugin manager).
# Installed by scripts/install_tools.sh: Brewfile + ~/.zsh/plugins clones.

_BREW_SHARE=${HOMEBREW_PREFIX:-/opt/homebrew}/share

# nvm: put the default node on PATH without loading nvm (~5ms vs ~300ms for
# zsh-nvm's lazy load); nvm itself loads on first `nvm` call.
export NVM_DIR=~/.nvm
if [[ -r $NVM_DIR/alias/default ]]; then
  _nvm_bin=($NVM_DIR/versions/node/v$(<$NVM_DIR/alias/default)*/bin(N/nOn[1]))
  (( $#_nvm_bin )) && path=($_nvm_bin $path)
  unset _nvm_bin
fi
nvm() { unfunction nvm; source $NVM_DIR/nvm.sh; nvm "$@"; }

# Vendored from oh-my-zsh: fzf-powered `cd <TAB>`
_source_if_exists "$DOTFILES"/zsh/vendor/zsh-interactive-cd.zsh

_source_if_exists "$_BREW_SHARE"/zsh-autosuggestions/zsh-autosuggestions.zsh

# Must be last: wraps ZLE widgets defined above
_source_if_exists "$_BREW_SHARE"/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

unset _BREW_SHARE
