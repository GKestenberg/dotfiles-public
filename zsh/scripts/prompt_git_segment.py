#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# ///
"""Emit current git branch and a clickable URL.

Output: <prefix>\t<text>\t<url>
- <prefix> is plain (unlinked) text; <text> gets hyperlinked to <url>.
- main/master  → cached `gh repo view --web` URL (the repo home)
- other        → cached `gh pr view` URL (the PR for the branch)
- If the upstream branch name differs from the local one, prefix is
  "<local>:" and the linked text is the remote branch.
- Empty output if not in a git repo.
- URL field empty if cache miss; refreshes in the background.

Cache lives under $XDG_CACHE_HOME/prompt/git_segment.
"""

from __future__ import annotations

import hashlib
import os
import shlex
import subprocess
import time
from pathlib import Path


CACHE_TTL_SECONDS = 300
DEFAULT_BRANCHES = {"main", "master"}


def cache_dir() -> Path:
    base = os.environ.get("XDG_CACHE_HOME") or str(Path.home() / ".cache")
    d = Path(base) / "prompt" / "git_segment"
    d.mkdir(parents=True, exist_ok=True)
    return d


def run(cmd: list[str], timeout: float = 1.0) -> str | None:
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, check=True
        )
        return result.stdout.strip() or None
    except (subprocess.SubprocessError, FileNotFoundError):
        return None


def maybe_refresh_cache(cache_path: Path, fetch_cmd: str) -> None:
    """Spawn a detached refresh if cache is stale or missing.

    fetch_cmd is the shell pipeline that emits the URL on stdout.
    """
    if cache_path.exists():
        age = time.time() - cache_path.stat().st_mtime
        if age < CACHE_TTL_SECONDS:
            return

    devnull = subprocess.DEVNULL
    tmp = cache_path.with_suffix(".tmp")
    subprocess.Popen(
        [
            "zsh", "-f", "-c",
            f'{fetch_cmd} > {tmp!s} 2>/dev/null && mv {tmp!s} {cache_path!s}',
        ],
        stdin=devnull, stdout=devnull, stderr=devnull,
        start_new_session=True,
    )


def main() -> int:
    branch = run(["git", "symbolic-ref", "--short", "HEAD"])
    if not branch:
        return 0  # not a repo or detached HEAD

    repo = run(["git", "config", "--get", "remote.origin.url"]) or ""

    # Upstream branch name (without the remote prefix), if one is set.
    upstream = run(
        ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"]
    )
    remote_branch = upstream.split("/", 1)[1] if upstream and "/" in upstream else None

    prefix, text = "", branch
    if branch in DEFAULT_BRANCHES:
        # Repo home page; cache key is per-repo only (branch-independent)
        key = hashlib.sha1(f"repo\n{repo}".encode()).hexdigest()[:16]
        # `gh repo view --json url -q .url` gives the canonical https URL
        # without --web (which would open the browser instead of printing).
        fetch_cmd = "gh repo view --json url -q .url"
    else:
        # PR for this branch's upstream (falls back to the local name)
        pr_branch = remote_branch or branch
        key = hashlib.sha1(f"pr\n{repo}\n{pr_branch}".encode()).hexdigest()[:16]
        fetch_cmd = f"gh pr view {shlex.quote(pr_branch)} --json url -q .url"
        if remote_branch and remote_branch != branch:
            prefix, text = f"{branch}:", remote_branch

    cache_path = cache_dir() / key
    maybe_refresh_cache(cache_path, fetch_cmd)

    url = ""
    if cache_path.exists():
        url = cache_path.read_text().strip()

    print(f"{prefix}\t{text}\t{url}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
