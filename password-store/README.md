# password-store

Touch ID prompts for `pass` that show the file being decrypted and any metadata.

```
pass github                          ->  Unlock password-store for ~/.password-store/github.gpg
pass github --name CRM               ->  Unlock password-store for ~/.password-store/github.gpg (name: CRM)
pass github --meta env=prod --name X ->  Unlock password-store for ~/.password-store/github.gpg (env: prod, name: X)
```

## Pieces

| file | linked to | role |
|------|-----------|------|
| `pass` | `~/.local/bin/pass` | wrapper: strips `--name X` / `--meta k=v`, sets `PINENTRY_USER_DATA`, execs the Homebrew `pass` |
| `gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | points `pinentry-program` at the patched binary |
| `pinentry/build.sh` | – | clones upstream pinentry-touchid at a pinned commit, applies the patch, builds `bin/Gilad Password Store` |
| `pinentry/touchid-reason.patch` | – | makes the Touch ID reason come from `PINENTRY_USER_DATA` |
| `bin/` | – | build output, gitignored |

The channel is gpg's own: the `gpg` client forwards `PINENTRY_USER_DATA` to
`gpg-agent`, which puts it in the pinentry's environment. `pass` itself is
unmodified. The dialog's app name is the executable's file name, hence the
binary is literally called `Gilad Password Store`.

## Setup

```sh
brew install go pass jorgelbg/tap/pinentry-touchid   # in Brewfile already
./scripts/bootstrap.sh                                # symlinks (from repo root)
./password-store/pinentry/build.sh                    # builds + restarts gpg-agent
```

First unlock after a rebuild: Keychain asks once to let the new binary read
the stored GPG PIN (login password, then "Always Allow").

## Notes

- Within `default-cache-ttl` (60s) gpg-agent does not call pinentry at all,
  so a second `pass` call shortly after the first shows no prompt.
- `--name` and `--meta` are the only flags the wrapper eats. `-n` is left
  alone because `pass generate -n` means "no symbols".
- If a caller sets `PINENTRY_USER_DATA` itself and passes no metadata, the
  wrapper keeps the caller's text.
- The path honours `PASSWORD_STORE_DIR` and shows `$HOME` as `~`.
