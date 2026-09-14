# When you create a local branch tracking a remote (e.g. `git checkout -b
# feature origin/main`), automatically configure it so `git pull` rebases
# instead of merging. Applies to every new branch going forward — no need to
# remember `--rebase` or set it per-branch. Existing branches are unaffected;
# pair with `pull.rebase true` if you want them to behave the same.
git config --global branch.autoSetupRebase always

# First push of a new branch normally fails with "no upstream branch" until
# you do `git push -u origin <branch>`. With this on, plain `git push`
# automatically sets `origin/<same-name>` as upstream and pushes. Pure
# quality-of-life — kills a useless friction point.
git config --global push.autoSetupRemote true

# Controls what `git push` (no args) pushes: only the current branch, and
# only if its upstream has the same name. Refuses on name mismatch, which
# usually indicates a mistake. This has been git's default since 2.0, so
# setting it is belt-and-suspenders, but harmless.
git config --global push.default simple

# By default `git push` does NOT push tags — you'd have to `git push --tags`
# separately. With this on, push automatically includes any annotated tags
# that point to commits being pushed. Lightweight tags still excluded
# (intentional — those are usually local bookmarks). Useful if you tag
# releases and want them to ship alongside the commits they tag.
git config --global push.followTags true

# Safety net for `--force-with-lease`. Plain `--force-with-lease` checks
# "is the remote at the SHA I think it is?" — but if you ran `git fetch`
# recently, your local view got updated and the check passes even though
# you personally never integrated those new commits. You can still clobber
# work. This adds a second check: the remote tip must be reachable from your
# branch's reflog, meaning you actually saw and rebased onto those commits.
# Closes the gap and makes force-with-lease as safe as you originally thought.
git config --global push.useForceIfIncludes true

# In the interactive rebase editor (`git rebase -i`), shows commands as
# single letters (p, s, f, e, r, d) instead of full words (pick, squash,
# fixup, edit, reword, drop). Purely cosmetic — same behavior, less
# scrolling on big rebases.
git config --global rebase.abbreviateCommands true

# Makes `git rebase -i` automatically detect commits whose messages start
# with `fixup!` or `squash!` (created via `git commit --fixup <sha>`) and
# reorder them adjacent to their target with the right action pre-set.
# Without this you'd need `git rebase -i --autosquash` every time. With it,
# the "make fixup commits as you go, clean up at the end" workflow becomes
# frictionless.
git config --global rebase.autoSquash true

# If you start a rebase with uncommitted working tree changes, git normally
# refuses ("cannot rebase: you have unstaged changes"). With this on, git
# auto-stashes before the rebase and pops the stash after. Saves the manual
# stash/pop dance. The pop can occasionally conflict if the rebase touched
# files you had uncommitted edits to, but that's an honest conflict you'd
# hit either way.
git config --global rebase.autoStash true

# Enables "reuse recorded resolution" — git remembers how you resolved each
# specific conflict (by hashing the conflict hunks). Next time the exact same
# conflict shows up — same rebase repeated as main moves, cherry-picking across
# branches, etc. — git replays your previous resolution automatically instead
# of making you redo it. Especially useful when rebasing a long-lived branch
# multiple times and hitting the same conflict on every rebase.
git config --global rerere.enabled true

# Without this, rerere replays the resolution into your working tree but
# leaves the file marked as still-conflicted — you have to `git add` it
# yourself to confirm. With autoUpdate on, git stages the resolved file
# automatically. Pair this with rerere.enabled and conflicts you've solved
# before just... vanish on the next rebase. No prompt, no manual add.
git config --global rerere.autoUpdate true
