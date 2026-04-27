#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""Emit AWS profile display name and console URL.

Output: <display>\t<url>
- Empty output if AWS_PROFILE is unset.
- Display is truncated first3…last3 if longer than 6 chars.
- URL routing is keyword-based on the profile name.

Cached at $XDG_CACHE_HOME/prompt/aws_segment, keyed by AWS_PROFILE.
Cache is essentially permanent — invalidated only when AWS_PROFILE changes.
"""

from __future__ import annotations

import os
from pathlib import Path


# Profile keyword → console URL. First substring match wins.
ROUTES: list[tuple[str, str]] = [
    (
        "porter",
        "https://porter-run.awsapps.com/start/#/console?account_id=072956081382&referrer=accessPortal",
    ),
]
DEFAULT_URL = "https://console.aws.amazon.com/"


def cache_path() -> Path:
    base = os.environ.get("XDG_CACHE_HOME") or str(Path.home() / ".cache")
    d = Path(base) / "prompt"
    d.mkdir(parents=True, exist_ok=True)
    return d / "aws_segment"


def truncate(name: str) -> str:
    if len(name) > 6:
        return f"{name[:3]}…{name[-3:]}"
    return name


def url_for(profile: str) -> str:
    lower = profile.lower()
    for keyword, url in ROUTES:
        if keyword in lower:
            return url
    return DEFAULT_URL


def main() -> int:
    profile = os.environ.get("AWS_PROFILE", "")
    if not profile:
        return 0

    cache = cache_path()

    # Cache format: <profile>\n<output_line>
    # Profile on first line acts as the cache key — if AWS_PROFILE
    # differs from the cached one, the cache is stale.
    if cache.exists():
        try:
            cached_profile, cached_line = cache.read_text().split("\n", 1)
            if cached_profile == profile:
                print(cached_line, end="")
                return 0
        except ValueError:
            pass  # malformed cache, regenerate

    line = f"{truncate(profile)}\t{url_for(profile)}\n"
    cache.write_text(f"{profile}\n{line}")
    print(line, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
