#!/bin/bash

# set up symlinks
./bootstrap.sh

# homebrew
if command -v brew &> /dev/null; then
    echo "✅ Homebrew is already installed"
    brew --version
else
    echo "❌ Homebrew not found. Installing..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle install --file=Brewfile
brew completions link

# gvm
if command -v gvm &> /dev/null; then
    echo "✅ GVM is already installed"
    gvm version
else
    echo "❌ GVM not found. Installing..."
    curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
fi

(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# set-up gnupg
brew info pinentry-touchid
echo "Set-Up Settings -> Touch ID & Password -> Add Fingerprint"
echo "Set-Up Settings -> Control Center -> Automatically hide and show the menu bar"

# graphite
gt completion --shell zsh >> ~/.gt-completion.zsh
