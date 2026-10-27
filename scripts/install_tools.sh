#!/usr/bin/env bash
#
# install_tools installs everything tracked in Brewfile and npmfile, plus the
# tools that can't be installed through either

cd "$(dirname "$0")"

# set up symlinks
./link.sh

# homebrew
if command -v brew &> /dev/null; then
    echo "✅ Homebrew is already installed"
    brew --version
else
    echo "❌ Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew bundle install --file=Brewfile
brew completions link

# npm (global packages, one per line)
grep -v -e '^\s*#' -e '^\s*$' npmfile | xargs npm install -g

# gvm
if command -v gvm &> /dev/null; then
    echo "✅ GVM is already installed"
    gvm version
else
    echo "❌ GVM not found. Installing..."
    curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
fi

# sketchybar lua bindings
rm -rf /tmp/SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# tmux
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# graphite
gt completion --shell zsh > ~/.gt-completion.zsh

# set-up gnupg
brew info pinentry-touchid
echo "Set-Up Settings -> Touch ID & Password -> Add Fingerprint"
echo "Set-Up Settings -> Control Center -> Automatically hide and show the menu bar"
