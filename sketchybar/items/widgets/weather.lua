local colors = require("colors")
local settings = require("settings")

local weather = sbar.add("graph", "widgets.weather", 42, {
	position = "right",
	graph = { color = colors.blue },
	background = { height = 22, color = { alpha = 0 }, border_color = { alpha = 0 }, drawing = true },
	icon = { string = "☀️", y_offset = 2 },
	label = {
		string = "??°",
		font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = 9.0 },
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	padding_right = settings.paddings + 6,
	update_freq = 600,
})

local weather_icons = {
	["Sunny"] = "☀️", ["Clear"] = "🌙", ["Mostly Sunny"] = "🌤️", ["Mostly Clear"] = "🌤️",
	["Partly Sunny"] = "⛅", ["Partly Cloudy"] = "⛅", ["Mostly Cloudy"] = "🌥️",
	["Cloudy"] = "☁️", ["Overcast"] = "☁️",
	["Rain"] = "🌧️", ["Light Rain"] = "🌦️", ["Heavy Rain"] = "🌧️", ["Showers"] = "🌧️",
	["Chance Rain"] = "🌦️", ["Slight Chance Rain"] = "🌦️",
	["Chance Showers"] = "🌦️", ["Slight Chance Showers"] = "🌦️",
	["Thunderstorm"] = "⛈️", ["Snow"] = "🌨️", ["Sleet"] = "🌨️", ["Fog"] = "🌫️",
	["Haze"] = "🌫️", ["Windy"] = "💨", ["Breezy"] = "💨",
}

local function get_weather_icon(short_forecast)
	for pattern, icon in pairs(weather_icons) do
		if short_forecast:find(pattern) then
			return icon
		end
	end
	return "🌡️"
end

local cached_loc = nil

local function update()
	-- Get location from ipinfo.io (with cache)
	local lat, lon
	if cached_loc then
		lat, lon = cached_loc.lat, cached_loc.lon
	else
		local loc_handle = io.popen("curl -s -m 5 'https://ipinfo.io/json'")
		if not loc_handle then return end
		local loc_json = loc_handle:read("*a")
		loc_handle:close()
		local loc = loc_json:match('"loc":%s*"([^"]+)"')
		if not loc then return end
		lat, lon = loc:match("([^,]+),([^,]+)")
		if not lat or not lon then return end
		cached_loc = { lat = lat, lon = lon }
	end

	-- Get NWS grid point
	local grid_handle = io.popen(
		"curl -s -m 10 -H 'User-Agent: sketchybar-weather' 'https://api.weather.gov/points/" .. lat .. "," .. lon .. "'"
	)
	if not grid_handle then return end
	local grid_json = grid_handle:read("*a")
	grid_handle:close()
	local forecast_url = grid_json:match('"forecast":%s*"([^"]+)"')
	local hourly_url = grid_json:match('"forecastHourly":%s*"([^"]+)"')
	if not forecast_url then return end

	-- Current conditions from NWS forecast
	local fc_handle = io.popen(
		"curl -s -m 10 -H 'User-Agent: sketchybar-weather' '" .. forecast_url .. "'"
	)
	if fc_handle then
		local fc_json = fc_handle:read("*a")
		fc_handle:close()
		local temp = fc_json:match('"temperature":%s*(%d+)')
		local unit = fc_json:match('"temperatureUnit":%s*"([^"]+)"')
		local short = fc_json:match('"shortForecast":%s*"([^"]+)"')
		if temp and unit then
			local icon = short and get_weather_icon(short) or "🌡️"
			local temp_str = temp .. "°" .. (unit == "F" and "F" or "C")
			weather:set({ icon = { string = icon }, label = temp_str })
		end
	end

	-- Hourly precipitation from NWS
	if not hourly_url then return end
	local handle = io.popen("curl -s -m 10 -H 'User-Agent: sketchybar-weather' '" .. hourly_url .. "'")
	if handle then
		local json = handle:read("*a")
		handle:close()
		local data = {}
		for block in json:gmatch('"probabilityOfPrecipitation":%s*(%b{})') do
			local val = block:match('"value":%s*(%d+)')
			if #data < 24 then
				table.insert(data, tonumber(val) or 0)
			end
		end
		if #data > 0 then
			weather:set({ graph = { color = colors.blue } })
			for j = #data, 1, -1 do
				weather:push({ data[j] / 100 })
			end
		end
	end
end

weather:subscribe({ "routine", "forced", "system_woke" }, update)
weather:subscribe("mouse.clicked", function()
	sbar.exec("open 'https://weather.com'")
end)

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, { background = { color = colors.bg } })
sbar.add("item", "widgets.weather.padding", { position = "right", width = settings.group_paddings })

update()
