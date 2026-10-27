#!/usr/bin/env bash
#
# save_tools merges what's installed locally into Brewfile and npmfile.
# Nothing is ever removed: entries already tracked stay as they are, local-only
# entries get added (Brewfile: after the last entry of the same type).

cd "$(dirname "$0")"
set -euo pipefail

# Brewfile entries are keyed on type + name (`brew "libpq"`), so a tracked
# entry with options like `link: true` isn't duplicated by the plain dump.
# npm globals are left out (npmfile tracks them), as are description comments.
brew bundle dump --file=- | grep -v -e '^npm ' -e '^#' | awk '
    function key(line) { k = $1 " " $2; sub(/,$/, "", k); return k }
    NR == FNR { local_lines[++n] = $0; local_keys[n] = key($0); next }
    { lines[++m] = $0; types[m] = $1; seen[key($0)] = 1; last[$1] = m }
    END {
        for (i = 1; i <= n; i++) {
            if (local_keys[i] in seen) continue
            seen[local_keys[i]] = 1
            split(local_lines[i], f, " ")
            added[f[1]] = added[f[1]] local_lines[i] "\n"
            if (!(f[1] in last)) { order[++o] = f[1]; last[f[1]] = -1 }
        }
        for (i = 1; i <= m; i++) {
            print lines[i]
            if (last[types[i]] == i && types[i] in added) printf "%s", added[types[i]]
        }
        for (i = 1; i <= o; i++) printf "%s", added[order[i]]
    }
' - Brewfile > Brewfile.tmp
mv -f Brewfile.tmp Brewfile

# npm and corepack ship with node, so they're not worth tracking
{
    cat npmfile
    npm ls -g --depth=0 --json | jq -r '.dependencies // {} | keys[]' | grep -vx -e npm -e corepack
} | awk '!seen[$0]++' > npmfile.tmp
mv -f npmfile.tmp npmfile

git --no-pager diff --stat -- Brewfile npmfile
