# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Restart sketchybar (picks up all changes)
brew services restart sketchybar

# Reload config without full restart
sketchybar --reload

# Tail live logs
tail -f /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Check for Lua errors
grep '\[!\] Lua' /opt/homebrew/var/log/sketchybar/sketchybar.out.log

# Query a specific item
sketchybar --query <item_name>

# Rebuild helper binaries only
cd helpers && make
```

## Logs

- **Output log**: `/opt/homebrew/var/log/sketchybar/sketchybar.out.log` (Lua errors, build output)
- **Error log**: `/opt/homebrew/var/log/sketchybar/sketchybar.err.log` (process-level errors)

## Architecture

### Config Load Order

1. `sketchybar.sh` — Lua entry point (symlinked as `~/.config/sketchybar/sketchybarrc`)
2. `helpers/init.lua` — adds SbarLua `.so` to `package.cpath`, runs `make` to compile C helpers
3. `init.lua` — wraps everything in `sbar.begin_config()` / `sbar.end_config()` (batches all item creation into one message to sketchybar), then starts `sbar.event_loop()`
4. Modules loaded in order: `bar` → `default` → `items`

### Symlink Setup

This directory IS `~/.config/sketchybar` (symlinked via stow/links.prop). The `sketchybarrc` symlink points back to `sketchybar.sh`. `$CONFIG_DIR` env var (set by sketchybar service) = `~/.config/sketchybar`.

### Items System

`items/init.lua` loads items in order: apple, menus, spaces, front_app, calendar, widgets, media.

Widgets (`items/widgets/`) load: battery, volume, wifi, cpu, weather.

### Helper Binaries (C)

Located in `helpers/event_providers/`. Built via Makefile during config load.

- **cpu_load** — emits `cpu_update` events with user_load, sys_load, total_load (0-100)
- **network_load** — emits `network_update` with upload/download speeds for interface en0
- **menus** — Carbon/SkyLight binary that reads macOS app menus (`-l` list, `-s N` select)

Each provider runs as a persistent background process spawned via `sbar.exec()`.

### Config Modules

- `colors.lua` — hex color palette with `with_alpha()` function
- `settings.lua` — central settings (paddings, icon set choice, font selection)
- `default.lua` — universal item defaults (fonts, sizes, popup styling)
- `icons.lua` — SF Symbols (primary) and NerdFont (alt) icon mappings
- `helpers/app_icons.lua` — app name → sketchybar-app-font icon mapping

## Key Patterns

- **Brackets** require padding items (empty items with only `width`) before and after due to spacing artifacts
- **Popups** are positioned via `position = "popup.<parent_item_name>"`
- **Graph items** use `item:push({value})` to append to value history
- `sbar.exec(cmd, callback)` runs shell commands async — callback receives stdout as string
- `sbar.animate(type, duration, callback)` for smooth transitions
- `sbar.delay(seconds, callback)` for timed actions
- **os.date() caches timezone** at process start — use `sbar.exec("date ...")` for DST-aware time

## Known Errors

- `spaces.lua:138` — nil space data on focus events when space has no window data
- `volume.lua:95` — popup reference nil during volume change events
