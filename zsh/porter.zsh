pctx() {
  # pctx with no args will print all contexts that are available
  # otherwise, use `pctx myctx` to create a new context, or switch to an existing one
  if [ -z "${1}" ]; then
      ls -1 -d ~/.porter/*/ | xargs basename
      return
  fi
  export PCTX=$HOME/.porter/${1}
  mkdir -p $PCTX
  export PORTER_CONFIG=$PCTX/porter.yaml
  porter config
}

alias k=kubectl

alias pk="porter kubectl --"
alias ph="porter helm --"
alias lint="GOWORK=off golangci-lint run -c .github/golangci-lint.yaml"
alias getcreds="cat ~/.aws/credentials"
alias getfig="cat ~/.aws/config"
alias ns="k ns"
alias cx="k ctx"
alias psp="porter config set-project"
alias psc="porter config set-cluster"
alias psh="porter config set-host"
alias plc="porter cluster list"
alias plp="porter project list"
alias pout="porter auth logout"
alias pin="pout; porter auth login"
alias pin-here="pin --host=http://localhost:8081"
alias pin-there="pin --host=https://dashboard.porter.run"
alias backup-fig="cp -i ~/.aws/config_backup ~/.aws/config"
alias gpo="git pull origin"
alias gba='for k in `git branch|sed s/^..//`;do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" "$k"`\\t"$k";done|sort'
alias pk9s="porter kubectl --print-kubeconfig > /tmp/temp-kubeconfig &&  k9s --kubeconfig /tmp/temp-kubeconfig"
alias pc="porter config"

alias gm="goose -dir zarf/database/migrations"
alias plint="GOWORK=off golangci-lint run -c ../.github/golangci-lint.yaml --new-from-rev=origin/main"

alias t_gen="task generate > /dev/null 2>&1 &"

function ts {
  # Ensure exactly one argument is passed
  if [ "$#" -ne 1 ]; then
      echo "Usage: tsx <-|prod|it|.>"
      echo "  -    - disable exit node"
      echo "  prod - use prod exit node"
      echo "  it   - use internal tools exit node"
      echo "  .    - use work station exit node"
      return 1
  fi

  # Map shorthand to exit node hostnames
  case "$1" in
    -)
      tailscale set --exit-node=
      echo "Exit node disabled"
      ;;
    prod)
      tailscale set --exit-node=production
      echo "Using prod exit node"
      ;;
    it)
      tailscale set --exit-node=internal-tools-cluster-cqcrxf
      echo "Using internal tools exit node"
      ;;
    .)
      tailscale set --exit-node=porter-exit-node-us-east-2
      echo "Using work station exit node"
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: tsx <-|prod|it|.>"
      return 1
      ;;
  esac
}\

# Gilad Scripts

rm_porter_policies() {
  uv run --script "$DOTFILES/zsh/scripts/rm_porter_policies.py" "$@"
}
k8s_dockerhub() {
  uv run --script "$DOTFILES/zsh/scripts/k8s_dockerhub.py" "$@"
}

