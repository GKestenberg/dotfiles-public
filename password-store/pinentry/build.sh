#!/usr/bin/env bash
#
# Builds a patched pinentry-touchid and names the binary "Gilad Password Store".
# macOS shows the executable name as the app in the Touch ID dialog, and the
# patch makes the dialog's reason text come from $PINENTRY_USER_DATA (which gpg
# forwards from the calling process, see ../pass).
#
# Output: ../bin/Gilad Password Store   (gitignored; re-run this to rebuild)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd -P)
out_dir="$here/../bin"
name="Gilad Password Store"

upstream="https://github.com/jorgelbg/pinentry-touchid.git"
commit="1170eb6bc7b23313aee622887b47b77be6e5fb5f" # main as of 2026-09-28 (v0.0.3+)

command -v go >/dev/null || { echo "go not found (brew install go)" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "cloning pinentry-touchid@${commit:0:7}"
git clone -q "$upstream" "$work/src"
git -C "$work/src" checkout -q "$commit"
git -C "$work/src" apply "$here/touchid-reason.patch"

mkdir -p "$out_dir"
(cd "$work/src" && go build -o "$out_dir/$name" .)
echo "built: $out_dir/$name"

if command -v gpgconf >/dev/null; then
  gpgconf --kill gpg-agent && echo "gpg-agent restarted"
fi
