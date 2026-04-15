# Sketchybar Configuration

## Logs

- **Error log**: `/opt/homebrew/var/log/sketchybar/sketchybar.err.log`
- **Output log**: `/opt/homebrew/var/log/sketchybar/sketchybar.out.log`

## Structure

- `sketchybar.sh` — entry point (symlinked to `~/.config/sketchybar/sketchybarrc`)
- `helpers/init.lua` — sets up `package.cpath` for `sketchybar.so` and builds helper binaries
- `init.lua` — main config: loads bar, default, and items modules
- `items/` — individual bar items (spaces, apps, widgets)
- `helpers/event_providers/` — C binaries that emit events (cpu_load, network_load)

## Service

Managed via `brew services`. PID lock at `/tmp/sketchybar_$USER.lock`.
