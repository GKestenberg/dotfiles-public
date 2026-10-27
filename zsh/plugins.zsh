# Plugins, sourced directly (no plugin manager).
# Installed by scripts/install_tools.sh: Brewfile + ~/.zsh/plugins clones.

_BREW_SHARE=${HOMEBREW_PREFIX:-/opt/homebrew}/share

export NVM_LAZY_LOAD=true
_source_if_exists ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh

# Vendored from oh-my-zsh: fzf-powered `cd <TAB>`
_source_if_exists "$DOTFILES"/zsh/vendor/zsh-interactive-cd.zsh

_source_if_exists "$_BREW_SHARE"/zsh-autosuggestions/zsh-autosuggestions.zsh

# Must be last: wraps ZLE widgets defined above
_source_if_exists "$_BREW_SHARE"/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

unset _BREW_SHARE
