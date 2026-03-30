hs.loadSpoon("HighlightFocusedWindow")

----------------------
-- Helper functions --
----------------------

local yabai_route = "/opt/homebrew/bin/yabai"

local yabai = function(args)
	local output, status = hs.execute(yabai_route .. " " .. table.concat(args, " "))
	return status
end

local move = function(direction)
	local success = yabai({ "-m", "window", "--move", direction })
	if not success then
		yabai({ "-m", "display", "--focus", direction })
	end
end

local swap = function(direction)
	local success = yabai({ "-m", "window", "--swap", direction })
	if not success then
		yabai({ "-m", "window", "--display", direction })
		yabai({ "-m", "display", "--focus", direction })
	end
end

------------------
-- Key bindings --
------------------

-- Reload Hammerspoon
hs.hotkey.bind({ "ctrl", "option" }, "r", function()
	hs.alert.show("Hammerspoon reloaded", 1) -- show for 1s
	hs.timer.doAfter(0.3, hs.reload)
end)

-- Window focus (vim-style)
hs.hotkey.bind({ "ctrl", "option" }, "h", function()
	move("west")
end)

hs.hotkey.bind({ "ctrl", "option" }, "j", function()
	move("south")
end)

hs.hotkey.bind({ "ctrl", "option" }, "k", function()
	move("north")
end)

hs.hotkey.bind({ "ctrl", "option" }, "l", function()
	move("east")
end)

-- Toggle float / center
hs.hotkey.bind({ "ctrl", "option" }, "f", function()
	yabai({ "-m", "window", "--toggle", "float" })
	yabai({ "-m", "window", "--grid", "4:4:1:1:2:2" })
end)

-- Move window to another display + focus
hs.hotkey.bind({ "ctrl", "option" }, "u", function()
	swap("west")
end)

hs.hotkey.bind({ "ctrl", "option" }, "i", function()
	swap("south")
end)

hs.hotkey.bind({ "ctrl", "option" }, "o", function()
	swap("north")
end)

hs.hotkey.bind({ "ctrl", "option" }, "p", function()
	swap("east")
end)

-- Launch Terminal
hs.hotkey.bind({ "ctrl", "alt" }, "t", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({ "ctrl", "option" }, "z", function()
	hs.application.launchOrFocus("Zen")
end)
