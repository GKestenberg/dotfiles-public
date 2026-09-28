# password-store

**Status: NOT ACTIVE.** `links.prop` is renamed `links.prop.disabled` so
bootstrap skips it, and the installer does not run the build. The live setup
is the stock Homebrew `pinentry-touchid` and the Homebrew `pass`.

Known issue (2026-09-28): under gpg-agent the patched binary returned an empty
passphrase (`gpg: decryption failed: No passphrase given`), while driving the
same binary directly over Assuan (SETDESC/SETKEYINFO/GETPIN) worked and
returned the PIN after Touch ID. Not yet root-caused; next step is enabling
`log-file` + `debug-pinentry` in gpg-agent.conf to see what gpg-agent sends
and receives.

To enable: rename `links.prop.disabled` back to `links.prop`, run
`scripts/bootstrap.sh`, then `pinentry/build.sh`.

Touch ID prompts for `pass` that show the directory `pass` was run from.

```
(cd ~/projects && pass github)  ->  Unlock password-store for ~/projects
```

Everything else is plain `pass`: one approved prompt unlocks the key for
gpg-agent's cache TTL (`default-cache-ttl` / `max-cache-ttl` in
`gpg-agent.conf`, currently 60s).

## Pieces

| file | linked to | role |
|------|-----------|------|
| `pass` | `~/.local/bin/pass` | wrapper: sets `PINENTRY_USER_DATA` to the cwd, execs the Homebrew `pass` |
| `gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | TTLs, and `pinentry-program` pointing at the patched binary |
| `pinentry/build.sh` | – | clones upstream pinentry-touchid at a pinned commit, applies the patch, builds `bin/Gilad Password Store` |
| `pinentry/touchid-reason.patch` | – | makes the Touch ID reason come from `PINENTRY_USER_DATA` |
| `bin/` | – | build output, gitignored |

gpg forwards `PINENTRY_USER_DATA` from the calling process to `gpg-agent`,
which puts it in the pinentry's environment. `pass` itself is unmodified. The
dialog's app name is the executable's file name, hence `Gilad Password Store`.

## Setup

```sh
brew install go pass jorgelbg/tap/pinentry-touchid   # in Brewfile already
./scripts/bootstrap.sh                                # symlinks (from repo root)
./password-store/pinentry/build.sh                    # builds + restarts gpg-agent
```

First unlock after a rebuild: Keychain asks once to let the new binary read
the stored GPG PIN (login password, then "Always Allow").

## Notes

- Anything that calls `pass` without `~/.local/bin` first in PATH bypasses
  the wrapper and gets the stock text ("access the PIN for ...").
- macOS shows one Touch ID dialog at a time; a new request cancels the one on
  screen, and the cancelled `pass` fails with "No passphrase given".
