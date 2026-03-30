# Sketchybar Config

## Logs & Errors

Sketchybar runs as a Homebrew service (`homebrew.mxcl.sketchybar`) and writes logs to:

| File | Contents |
|------|----------|
| `/opt/homebrew/var/log/sketchybar/sketchybar.out.log` | Lua runtime errors, build output, plugin stdout |
| `/opt/homebrew/var/log/sketchybar/sketchybar.err.log` | Process-level errors (killed helpers, yabai scripting-addition issues) |

### Useful commands

```bash
# Tail live logs
tail -f /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Check for Lua errors
grep '\[!\] Lua' /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Restart sketchybar
brew services restart sketchybar
```

### Known recurring errors

- `spaces.lua:138: attempt to index a nil value (field '?')` — triggers on space focus events when a space has no associated window data
- `volume.lua:95: attempt to index a nil value (field 'popup')` — popup menu reference is nil during volume change events
