local obj = {}

-- Metadata
obj.name = "HighlightFocusedWindow"
obj.version = "1.0"
obj.author = "Jonatan Bakucz"
obj.homepage = "https://github.com/johnnybakucz/highlight_focused_window.spoon"

-- Configuration
local borderColor = { red = 0, green = 1, blue = 1, alpha = 0.7 }
local borderWidth = 10
local borderRounding = 20

-- Global variable to store the border
local focusBorder = nil

-- Function to delete the border
local function deleteBorder()
	if focusBorder then
		focusBorder:delete()
		focusBorder = nil
	end
end

-- Function to draw the border
local function drawBorder()
	local win = hs.window.focusedWindow()

	deleteBorder()

	if not win then
		return
	end

	local frame = win:frame()

	-- Adjust frame for border width and padding
	local adjustedFrame = {
		x = frame.x - borderWidth / 2,
		y = frame.y - borderWidth / 2,
		w = frame.w + borderWidth,
		h = frame.h + borderWidth,
	}

	if focusBorder then
		focusBorder:setFrame(adjustedFrame)
	else
		focusBorder = hs.drawing.rectangle(adjustedFrame)
		focusBorder:setRoundedRectRadii(borderRounding, borderRounding)
		focusBorder:setStrokeColor(borderColor)
		focusBorder:setFill(false)
		focusBorder:setStrokeWidth(borderWidth)
		focusBorder:show()
	end
end

-- Event listener for window focus changes
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowFocused, drawBorder)
windowFilter:subscribe(hs.window.filter.windowUnfocused, deleteBorder)
windowFilter:subscribe(hs.window.filter.windowDestroyed, deleteBorder)
windowFilter:subscribe(hs.window.filter.windowMoved, drawBorder)
windowFilter:subscribe(hs.window.filter.windowMinimized, deleteBorder)
windowFilter:subscribe(hs.window.filter.windowHidden, deleteBorder)
windowFilter:subscribe(hs.window.filter.windowUnminimized, drawBorder)
windowFilter:subscribe(hs.window.filter.windowUnhidden, drawBorder)

hs.timer.doEvery(0.1, function()
	if hs.window.focusedWindow() then
		drawBorder()
	end
end)

return obj
