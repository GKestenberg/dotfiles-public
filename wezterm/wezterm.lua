local wezterm = require("wezterm")

-- ADJUSTABLES
local BG_COLOR = 0.5
local BG_OPACITY_BOTTOM = 0.75

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12

config.window_decorations = "RESIZE"

-- Setup background color
local appearance = wezterm.gui.get_appearance()
local is_dark_mode = appearance:find("Dark")
local bg_color = is_dark_mode and { 41, 44, 51 } or { 255, 255, 255 }
local _bg_color_with_opacity = string.format("rgba(%d,%d,%d,%.2f)", bg_color[1], bg_color[2], bg_color[3], BG_COLOR)
local _bg_bottom = string.format("rgba(%d,%d,%d,%.2f)", bg_color[1], bg_color[2], bg_color[3], BG_OPACITY_BOTTOM)

-- disable auto-scroll on selection
config.selection_word_boundary = " \t\n{}[]()\"'`"

config.window_background_gradient = {
	orientation = "Vertical",
	colors = {
		_bg_color_with_opacity,
		_bg_color_with_opacity,
		_bg_color_with_opacity,
		_bg_color_with_opacity,
		_bg_color_with_opacity,
		_bg_bottom,
		_bg_bottom,
	},
}
config.window_background_opacity = 0.999

config.color_scheme = is_dark_mode and "Catppuccin Mocha" or "Catppuccin Latte"

config.use_fancy_tab_bar = false
config.tab_max_width = 22
config.tab_bar_at_bottom = true
config.colors = {
	tab_bar = {
		background = "#0b0022",

		active_tab = {
			bg_color = "#2b2042",
			fg_color = "#c0c0c0",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#1b1032",
			fg_color = "#808080",
		},
		inactive_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
			italic = true,
		},

		new_tab = {
			bg_color = "#1b1032",
			fg_color = "#808080",
		},
		new_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
			italic = true,
		},
	},
}
config.window_padding = {
	bottom = 0,
}

--- Creates a tab title
---
--- @param tab_info {tab_title: string, active_pane: {current_working_dir: string}}
--- @return unknown
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	local current_dir = tab_info.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	if current_dir == HOME_DIR then
		return " HOME "
	end
	local current_dir_name = string.gsub(tostring(current_dir), "(.*[/\\])(.*)", "%2")
	local formatted_dir_name = string.format("%-5s", current_dir_name)
	local MAX_WIDTH = 20
	return " " .. string.sub(formatted_dir_name, 1, MAX_WIDTH) .. " "
end

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	if tab.is_active then
		return {
			{ Background = { Color = "blue" } },
			{ Text = title },
		}
	end
	return title
end)

return config
