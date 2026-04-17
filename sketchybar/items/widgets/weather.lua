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

local function get_weather_icon(desc)
	for pattern, icon in pairs(weather_icons) do
		if desc:find(pattern) then
			return icon
		end
	end
	return "🌡️"
end

local cached_loc = nil
local UA = "sketchybar-weather"

local function fetch_observation(stations_url)
	sbar.exec("curl -s -m 10 -H 'User-Agent: " .. UA .. "' '" .. stations_url .. "'", function(result)
		if type(result) ~= "table" then return end
		local features = result.features
		if not features or not features[1] then return end
		local station_id = features[1].properties and features[1].properties.stationIdentifier
		if not station_id then return end

		sbar.exec(
			"curl -s -m 10 -H 'User-Agent: " .. UA .. "' 'https://api.weather.gov/stations/" .. station_id .. "/observations/latest'",
			function(obs)
				if type(obs) ~= "table" then return end
				local props = obs.properties
				if not props then return end
				local temp_c = props.temperature and props.temperature.value
				local desc = props.textDescription
				if temp_c then
					local temp_f = math.floor(temp_c * 9 / 5 + 32 + 0.5)
					local icon = desc and get_weather_icon(desc) or "🌡️"
					weather:set({ icon = { string = icon }, label = tostring(temp_f) .. "°F" })
				end
			end
		)
	end)
end

local function fetch_precip(grid_url)
	sbar.exec("curl -s -m 10 -H 'User-Agent: " .. UA .. "' '" .. grid_url .. "'", function(result)
		if type(result) ~= "table" then return end
		local props = result.properties
		if not props then return end
		local pop = props.probabilityOfPrecipitation
		if not pop or not pop.values then return end
		local data = {}
		for i = 1, math.min(24, #pop.values) do
			local v = pop.values[i]
			table.insert(data, tonumber(v and v.value or 0) or 0)
		end
		if #data > 0 then
			weather:set({ graph = { color = colors.blue } })
			for j = #data, 1, -1 do
				weather:push({ data[j] / 100 })
			end
		end
	end)
end

local function fetch_grid(lat, lon)
	sbar.exec(
		"curl -s -m 10 -H 'User-Agent: " .. UA .. "' 'https://api.weather.gov/points/" .. lat .. "," .. lon .. "'",
		function(result)
			if type(result) ~= "table" then return end
			local props = result.properties
			if not props then return end
			if props.observationStations then fetch_observation(props.observationStations) end
			if props.forecastGridData then fetch_precip(props.forecastGridData) end
		end
	)
end

local function update()
	if cached_loc then
		fetch_grid(cached_loc.lat, cached_loc.lon)
		return
	end
	sbar.exec("curl -s -m 5 'https://ipinfo.io/json'", function(result)
		if type(result) ~= "table" then return end
		local loc = result.loc
		if not loc then return end
		local lat, lon = loc:match("([^,]+),([^,]+)")
		if not lat or not lon then return end
		cached_loc = { lat = lat, lon = lon }
		fetch_grid(lat, lon)
	end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, update)
weather:subscribe("mouse.clicked", function()
	sbar.exec("open 'https://weather.com'")
end)

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, { background = { color = colors.bg } })
sbar.add("item", "widgets.weather.padding", { position = "right", width = settings.group_paddings })

update()
