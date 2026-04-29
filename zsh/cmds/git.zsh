# ------------
# GIT COMMANDS
# ------------

_ensure_commit() {
    if [ $# -eq 1 ]; then
        echo "usage: $1 <commit message>"
        return 1
    fi
    return 0
}

gc() {
    _ensure_commit $0 "$@" || return
    git commit -m "$@"
}
gac() {
    _ensure_commit $0 "$@" || return
    git add . && git commit -m "$@"
}
gcmp() {
    _ensure_commit $0 "$@" || return
    git add -A && git commit -m \"$@\" && git push
}
alias ga="git add ."
alias gw="git worktree"
alias gdiff="git diff"
alias gf="git fetch"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gp="git push"
alias gs="git status"

alias g_wt='cd $(git worktree list | fzf | awk "{print \$1}")'

# Soft rebase to graphite parent
gt_r() {
  local parent=$(gt log --steps 1 2>/dev/null | grep -oE 'gk/[a-zA-Z0-9_-]+|main' | tail -1)
  if [[ -z "$parent" ]]; then
    echo "Could not determine parent branch"
    return 1
  fi
  echo "Soft rebasing to: $parent"
  git reset --soft "$parent"
}

alias gtl="gt log short --no-interactive"
alias gtc="gt checkout"
alias gts="gt submit --stack --ai"

ghpr() {
  gh pr create --title "$1" --body "$2"
}

goinit() {
  local gh_user repo_name

  if ! command -v gh &>/dev/null; then
    echo "GitHub CLI (gh) not found."
    return 1
  fi

  if ! gh auth status &>/dev/null; then
    echo "You are not logged into GitHub CLI. Run 'gh auth login' first."
    return 1
  fi

  gh_user=$(gh api user --jq .login)

  if [ -n "$1" ]; then
    repo_name="$1"
  else
    repo_name=$(basename "$PWD")
  fi

  go mod init "github.com/$gh_user/$repo_name"
}
