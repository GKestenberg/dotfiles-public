#!/usr/bin/env bash
branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/starship-pr"
mkdir -p "$cache_dir"
repo=$(git config --get remote.origin.url 2>/dev/null)
key=$(printf '%s\n%s' "$repo" "$branch" | shasum | cut -c1-16)
cache="$cache_dir/$key"

# kick off background refresh if cache is missing or > 5 min old
if [ ! -f "$cache" ] || [ $(( $(date +%s) - $(stat -f %m "$cache" 2>/dev/null || stat -c %Y "$cache") )) -gt 300 ]; then
  ( gh pr view --json url -q .url 2>/dev/null > "$cache.tmp" && mv "$cache.tmp" "$cache" ) </dev/null >/dev/null 2>&1 &
  disown 2>/dev/null
fi

url=$(cat "$cache" 2>/dev/null)
if [ -n "$url" ]; then
  printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$url" "$branch"
else
  printf '%s' "$branch"
fi
