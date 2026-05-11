# This file is pretty customizable, you should probably delete it, although some
# of these exports are neccessary for my setup.

export PATH=$HOME/.pub-cache/bin:$PATH
export PATH=$HOME/development/flutter/bin:$PATH
export PATH=$HOME/Library/Python/3.11/bin:$PATH
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:$HOME/bin
export PATH="/Users/giladkestenberg/.local/bin:$PATH"

export EDITOR='nvim'

export BAT_THEME=Coldark-Dark

# if val=$(timeout 3s pass ai/anthropic/porter 2>/dev/null); then
#   export ANTHROPIC_API_KEY="$val"
# fi
# if val=$(timeout 3s pass ai/openai/personal 2>/dev/null); then
#   export OPENAI_API_KEY="$val"
# fi

export HOMEBREW_NO_INSTALL_CLEANUP=TRUE

export PNPM_HOME="/Users/giladkestenberg/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export DOCKER_CLI_HINTS=false # stop weird ads

export GOOSE_DRIVER=postgres GOOSE_DBSTRING="postgresql://porter:porter@localhost:5432/porter"

export ENABLE_LSP_TOOL=1
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

export AWS_PROFILE="porter-dev"
