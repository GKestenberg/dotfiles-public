# Shell defaults that oh-my-zsh's lib/ used to provide.

export LANG=en_US.UTF-8

# -- History --
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
  hist_ignore_space hist_verify share_history

# -- Directories --
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus
alias -g ...='../..'
alias -g ....='../../..'
alias -- -='cd -'
alias d='dirs -v | head -10'
for i in {1..9}; do alias "$i"="cd -$i"; done; unset i

# -- Completion --
setopt complete_in_word always_to_end
unsetopt menu_complete flowcontrol
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
zmodload -i zsh/complist
bindkey -M menuselect '^o' accept-and-infer-next-history

# -- Key bindings (emacs mode) --
bindkey -e
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# -- Misc --
setopt interactive_comments
alias grep='grep --color=auto'

# Replaces omz's web-search plugin (only `google` was used)
google() { open "https://www.google.com/search?q=${(j:+:)@}"; }
