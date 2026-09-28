# password-store (not active)

Makes the `pass` Touch ID dialog say where it was run from:

    Unlock password-store for ~/projects

How: `pass` (wrapper) sets `PINENTRY_USER_DATA`, gpg forwards it to the pinentry,
and `build.sh` builds a pinentry-touchid that shows it.

Enable:

    mv links.prop.disabled links.prop && ../scripts/bootstrap.sh   # symlinks pass + gpg-agent.conf
    ./build.sh && gpgconf --kill gpg-agent
    # first unlock: choose "Always Allow" in the Keychain dialog

Open issue (2026-09-28): under gpg-agent the built binary returned an empty
passphrase ("No passphrase given"), although driven directly it returned the
PIN after Touch ID. Not root-caused yet.
