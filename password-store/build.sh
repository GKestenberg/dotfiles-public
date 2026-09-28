#!/usr/bin/env bash
# Builds pinentry-touchid with one change: the Touch ID dialog text comes from
# $PINENTRY_USER_DATA when set. Output: bin/Gilad Password Store (the file name
# is what macOS shows as the app in the dialog). Does not touch gpg-agent.
set -eu
cd "$(dirname "$0")"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

git clone -q https://github.com/jorgelbg/pinentry-touchid.git "$tmp"
git -C "$tmp" checkout -q 1170eb6bc7b23313aee622887b47b77be6e5fb5f

sed -i '' 's/authFn(fmt.Sprintf("access the PIN for %s", keychainLabel))/authFn(reason(fmt.Sprintf("access the PIN for %s", keychainLabel)))/' "$tmp/main.go"
grep -q 'authFn(reason(' "$tmp/main.go"
cat > "$tmp/reason.go" <<'EOF'
package main

import "os"

// reason is the Touch ID dialog text: PINENTRY_USER_DATA if set, else the stock text.
func reason(fallback string) string {
	if v := os.Getenv("PINENTRY_USER_DATA"); v != "" {
		return v
	}
	return fallback
}
EOF

mkdir -p bin
(cd "$tmp" && go build -o "$OLDPWD/bin/Gilad Password Store" .)
echo "built bin/Gilad Password Store"
