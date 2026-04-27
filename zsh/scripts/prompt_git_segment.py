#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""Emit current git branch and (cached) PR URL.

Output: <branch>\t<url>
- Empty output if not in a git repo.
- URL field empty if no PR found yet.

Cache is per-repo+branch under $XDG_CACHE_HOME/zsh-prompt-pr/.
Refreshes in the background when stale (>5 min).
"""

from __future__ import annotations

import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path


CACHE_TTL_SECONDS = 300


def cache_dir() -> Path:
    base = os.environ.get("XDG_CACHE_HOME") or str(Path.home() / ".cache")
    d = Path(base) / "zsh-prompt-pr"
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


def maybe_refresh_cache(cache_path: Path) -> None:
    """Spawn a detached `gh pr view` if cache is stale or missing.

    Detaches via double-fork-equivalent: start_new_session + closing fds.
    The parent returns immediately; the grandchild writes to cache.tmp
    and renames atomically.
    """
    if cache_path.exists():
        age = time.time() - cache_path.stat().st_mtime
        if age < CACHE_TTL_SECONDS:
            return

    devnull = subprocess.DEVNULL
    tmp = cache_path.with_suffix(".tmp")
    # Background: gh pr view → tmp → atomic rename
    subprocess.Popen(
        [
            "sh", "-c",
            f'gh pr view --json url -q .url 2>/dev/null > {tmp!s} && mv {tmp!s} {cache_path!s}',
        ],
        stdin=devnull, stdout=devnull, stderr=devnull,
        start_new_session=True,
    )


def main() -> int:
    branch = run(["git", "symbolic-ref", "--short", "HEAD"])
    if not branch:
        return 0  # not a repo or detached HEAD; emit nothing

    repo = run(["git", "config", "--get", "remote.origin.url"]) or ""
    key = hashlib.sha1(f"{repo}\n{branch}".encode()).hexdigest()[:16]
    cache_path = cache_dir() / key

    maybe_refresh_cache(cache_path)

    url = ""
    if cache_path.exists():
        url = cache_path.read_text().strip()

    print(f"{branch}\t{url}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
