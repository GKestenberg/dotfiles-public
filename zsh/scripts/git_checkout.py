# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Fuzzy-pick a git branch with fzf and check it out."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, **kwargs)


def in_git_repo() -> bool:
    return run(["git", "rev-parse", "--git-dir"], capture_output=True).returncode == 0


def list_branches(include_remotes: bool) -> list[str]:
    refs = ["refs/heads/"]
    if include_remotes:
        refs.append("refs/remotes/")
    result = run(
        [
            "git",
            "for-each-ref",
            "--sort=-committerdate",
            "--format=%(refname:short)",
            *refs,
        ],
        capture_output=True,
        check=True,
    )
    seen: set[str] = set()
    branches: list[str] = []
    for line in result.stdout.splitlines():
        if not line or line == "origin/HEAD" or line in seen:
            continue
        seen.add(line)
        branches.append(line)
    return branches


def fzf_pick(items: list[str]) -> str | None:
    proc = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--height=40%",
            "--reverse",
            "--prompt=checkout> ",
            "--preview=git log --oneline --decorate --color=always -n 20 {}",
            "--preview-window=right:60%:wrap",
        ],
        input="\n".join(items),
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        return None
    return proc.stdout.strip() or None


def checkout(branch: str) -> int:
    local_exists = (
        run(
            ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
            capture_output=True,
        ).returncode
        == 0
    )
    if local_exists:
        return run(["git", "checkout", branch]).returncode

    # Remote-style "origin/foo" — create local tracking branch.
    if "/" in branch:
        local_name = branch.split("/", 1)[1]
        return run(["git", "checkout", "-B", local_name, "--track", branch]).returncode

    return run(["git", "checkout", branch]).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-a", "--all", action="store_true", help="include remote branches"
    )
    args = parser.parse_args()

    if not shutil.which("fzf"):
        print("g_c: fzf not found in PATH", file=sys.stderr)
        return 1
    if not in_git_repo():
        print("g_c: not in a git repository", file=sys.stderr)
        return 1

    branches = list_branches(args.all)
    if not branches:
        print("g_c: no branches found", file=sys.stderr)
        return 1

    picked = fzf_pick(branches)
    if picked is None:
        return 130

    return checkout(picked)


if __name__ == "__main__":
    sys.exit(main())
