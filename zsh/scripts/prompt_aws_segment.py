#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""Emit AWS profile display name and console URL.

Output: <display>\t<url>
- Empty output if AWS_PROFILE is unset.
- Display is truncated first3…last3 if longer than 6 chars.
- URL routing is keyword-based on the profile name.
"""

from __future__ import annotations

import os
import sys


# Profile keyword → console URL.
# Order matters; first substring match wins.
ROUTES: list[tuple[str, str]] = [
    (
        "porter",
        "https://porter-run.awsapps.com/start/#/console?account_id=072956081382&referrer=accessPortal",
    ),
]
DEFAULT_URL = "https://console.aws.amazon.com/"


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

    print(f"{truncate(profile)}\t{url_for(profile)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
