# Create worktree at ./.conductor/<name> checked out on <branch>
# Usage: gw_add <name> [branch]   (branch defaults to <name>)
gw_add() {
    if [[ -z "$1" ]]; then
        echo "Usage: gw_add <name> [branch]" >&2
        return 1
    fi
    local name="$1"
    local branch="${2:-$1}"
    git worktree add "./.conductor/$name" "$branch"
}

# Remove the worktree that holds <branch>, then checkout <branch> in this repo
# Usage: gw_rm <branch>
gw_rm() {
    if [[ -z "$1" ]]; then
        echo "Usage: gw_rm <branch>" >&2
        return 1
    fi
    local branch="$1"
    local wt_path
    wt_path=$(git worktree list --porcelain 2>/dev/null | awk -v b="refs/heads/$branch" '
        /^worktree / { path = $2 }
        /^branch /   { if ($2 == b) { print path; exit } }
    ')
    if [[ -z "$wt_path" ]]; then
        echo "gw_rm: no worktree found for branch '$branch'" >&2
        return 1
    fi
    git worktree remove "$wt_path" || return $?
    git checkout "$branch"
}

# --- completions ---

# gw_rm: complete with branches that currently have worktrees
_gw_rm() {
    local -a wt_branches
    wt_branches=(${(f)"$(git worktree list --porcelain 2>/dev/null \
        | awk '/^branch / { sub(/^refs\/heads\//, "", $2); print $2 }')"})
    _describe 'worktree branch' wt_branches
}
compdef _gw_rm gw_rm

# gw_add: arg 1 = free-form name, arg 2 = local branch
_gw_add() {
    print "CURRENT=$CURRENT words=(${(q)words[@]})" >> /tmp/gw_add.log
    if (( CURRENT == 2 )); then
        _message 'worktree name'
    elif (( CURRENT == 3 )); then
        local -a branches
        branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)"})
        _describe 'branch' branches
    fi
}
compdef _gw_add gw_add
