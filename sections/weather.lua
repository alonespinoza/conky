-- ~/.conky/sections/weather.lua
-- Weather information functions with beautiful formatting

-- Helper function to get weather information
local function get_weather_info()
    local f = io.open("/tmp/conky_weather.txt", "r")
    if not f then
        return "N/A", "N/A", "N/A"
    end

    local line = f:read("*l")
    f:close()

    if not line then
        return "N/A", "N/A", "N/A"
    end

    -- Parse weather data (format: location|condition|icon)
    local location, condition, icon = string.match(line, "([^|]+)|([^|]+)|([^|]+)")

    return location or "N/A", condition or "N/A", icon or "N/A"
end

-- Beautiful weather display with Nord color scheme
function conky_weather_display()
    -- Get weather information
    local location, condition, icon = get_weather_info()

    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}WEATHER${font}${color}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}%s${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}${color}${font}${image ./weather/icons/%s -p 175,635 -s 24x24}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}%s${color}${goto 150}
]], condition, icon, location)
end
