-- ~/.conky/sections/weather.lua
-- Weather information functions with automatic location updates

-- Configuration
local LOCATION_UPDATE_INTERVAL = 30 * 60 -- 30 minutes in seconds
local WEATHER_UPDATE_INTERVAL = 15 * 60  -- 15 minutes in seconds
local WEATHER_FILE = "/tmp/conky_weather.txt"
local LOCATION_CONFIG = os.getenv("HOME") .. "/.conky/weather_location.conf"

-- Global variables for tracking update times
local last_location_update = 0
local last_weather_update = 0
local current_location = "N/A"
local current_condition = "N/A"
local current_icon = "N/A"

-- Helper function to read command output
local function read_cmd(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return "" end
    local out = p:read("*l") or ""
    p:close()
    return out
end

-- Function to detect location using multiple services
local function detect_location()
    local current_time = os.time()

    -- Only update location every 30 minutes
    if current_time - last_location_update < LOCATION_UPDATE_INTERVAL then
        return current_location ~= "N/A"
    end

    print("Updating location...")

    -- Try multiple IP geolocation services
    local lat, lon, name = nil, nil, nil

    -- Service 1: ip-api.com
    local ip_data1 = read_cmd("curl -s 'http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon'")
    if ip_data1 and ip_data1 ~= "" then
        local status = string.match(ip_data1, '"status":"([^"]+)"')
        if status == "success" then
            lat = string.match(ip_data1, '"lat":([%d%.]+)')
            lon = string.match(ip_data1, '"lon":([%-%d%.]+)')
            local city = string.match(ip_data1, '"city":"([^"]+)"')
            local region = string.match(ip_data1, '"regionName":"([^"]+)"')
            local country = string.match(ip_data1, '"country":"([^"]+)"')

            if lat and lon and city then
                name = city
                if region and region ~= "" then
                    name = name .. ", " .. region
                end
                name = name .. ", " .. country
            end
        end
    end

    -- If first service failed, try ipapi.co
    if not lat or not lon then
        local ip_data2 = read_cmd("curl -s 'https://ipapi.co/json/'")
        if ip_data2 and ip_data2 ~= "" then
            lat = string.match(ip_data2, '"latitude":([%d%.]+)')
            lon = string.match(ip_data2, '"longitude":([%-%d%.]+)')
            local city = string.match(ip_data2, '"city":"([^"]+)"')
            local country = string.match(ip_data2, '"country_name":"([^"]+)"')

            if lat and lon and city then
                name = city .. ", " .. country
            end
        end
    end

    -- If we got coordinates, save them
    if lat and lon and name then
        -- Save to config file
        local config_dir = os.getenv("HOME") .. "/.conky"
        os.execute("mkdir -p '" .. config_dir .. "'")

        local config_content = string.format([[
# Weather location configuration
WEATHER_LAT="%s"
WEATHER_LON="%s"
WEATHER_NAME="%s"
]], lat, lon, name)

        local f = io.open(LOCATION_CONFIG, "w")
        if f then
            f:write(config_content)
            f:close()
        end

        current_location = name
        last_location_update = current_time
        print("Location updated: " .. name)
        return true
    end

    return false
end

-- Function to get weather data
local function get_weather_data()
    local current_time = os.time()

    -- Only update weather every 15 minutes
    if current_time - last_weather_update < WEATHER_UPDATE_INTERVAL then
        return current_condition ~= "N/A"
    end

    print("Updating weather...")

    -- Try to get location from config first
    local lat, lon = nil, nil
    local f = io.open(LOCATION_CONFIG, "r")
    if f then
        local content = f:read("*a")
        f:close()

        lat = string.match(content, 'WEATHER_LAT="([^"]+)"')
        lon = string.match(content, 'WEATHER_LON="([^"]+)"')
    end

    -- If no config, try to detect location
    if not lat or not lon then
        if not detect_location() then
            return false
        end

        -- Reload config after detection
        f = io.open(LOCATION_CONFIG, "r")
        if f then
            local content = f:read("*a")
            f:close()
            lat = string.match(content, 'WEATHER_LAT="([^"]+)"')
            lon = string.match(content, 'WEATHER_LON="([^"]+)"')
        end
    end

    if not lat or not lon then
        return false
    end

    -- Fetch weather data
    local api_key = "e46d6b1c945f2e9983f0735f8928ea2f"
    local weather_url = string.format(
        "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s&units=metric&lang=en", lat, lon, api_key)
    local weather_data = read_cmd("curl -s '" .. weather_url .. "'")

    if weather_data and weather_data ~= "" then
        -- Extract weather information
        local condition = string.match(weather_data, '"main":"([^"]+)"')
        local temp = string.match(weather_data, '"temp":([%-%d%.]+)')
        local humidity = string.match(weather_data, '"humidity":([%d]+)')

        if condition and temp then
            -- Map weather condition to icon
            local icon = "cloudy"
            if condition == "Clear" then
                icon = "sunny"
            elseif condition == "Rain" or condition == "Drizzle" then
                icon = "rain"
            elseif condition == "Thunderstorm" then
                icon = "thunderstorm"
            elseif condition == "Snow" then
                icon = "snow"
            elseif condition == "Mist" or condition == "Fog" or condition == "Haze" then
                icon = "fog"
            end

            -- Format temperature
            local temp_rounded = math.floor(tonumber(temp) + 0.5)
            local temp_display = temp_rounded .. "°C"

            -- Update current values
            current_condition = temp_display .. " " .. condition
            current_icon = icon .. ".png"
            last_weather_update = current_time

            -- Write to weather file for compatibility
            local weather_content = string.format("%s|%s|%s", current_location, current_condition, current_icon)
            local f = io.open(WEATHER_FILE, "w")
            if f then
                f:write(weather_content)
                f:close()
            end

            print("Weather updated: " .. current_condition)
            return true
        end
    end

    return false
end

-- Main weather display function
function conky_weather_display()
    -- Try to update location and weather
    detect_location()
    get_weather_data()

    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}WEATHER${font}${color}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}%s${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}${color}${font}${image ~/.conky/weather/icons/%s -p 175,635 -s 24x24}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}%s${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 25}${offset 20}${font Droid Sans:size=9}${color #5E81AC}${color}${font}
]], current_condition, current_icon, current_location)
end
