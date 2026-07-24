-- ~/.conky/sections/temperature.lua
-- Temperature monitoring functions and Cairo-based display

-- Define Cairo constants if they don't exist
CAIRO_FONT_SLANT_NORMAL = CAIRO_FONT_SLANT_NORMAL or 0
CAIRO_FONT_WEIGHT_BOLD = CAIRO_FONT_WEIGHT_BOLD or 1
CAIRO_FONT_WEIGHT_NORMAL = CAIRO_FONT_WEIGHT_NORMAL or 0

-- Helper functions
function conky_temperature_cpu()
    local file = io.open("/sys/class/thermal/thermal_zone0/temp", "r")
    if file then
        local temp = file:read("*n")
        file:close()
        if temp then
            return string.format("%.1f°C", temp / 1000)
        end
    end
    return "N/A"
end

function conky_temperature_hdd()
    local file = io.open("/sys/class/thermal/thermal_zone1/temp", "r")
    if file then
        local temp = file:read("*n")
        file:close()
        if temp then
            return string.format("%.1f°C", temp / 1000)
        end
    end
    return "N/A"
end

-- Text-based temperature display for lua_parse (working version)
function conky_temperature_display()
    local cpu_temp = conky_temperature_cpu()
    local hdd_temp = conky_temperature_hdd()

    local result = string.format(
        "${voffset 380}${goto 20}${font Droid Sans:style=Bold:size=18}${color0}┌─────────────────────────────────────────────────────────────────┐${font}${color}\n" ..
        "${goto 20}${font Droid Sans:style=Bold:size=18}${color0}│                      TEMPERATURE                        │${font}${color}\n" ..
        "${goto 20}${font Droid Sans:style=Bold:size=18}${color0}├─────────────────────────────────────────────────────────────────┤${font}${color}\n" ..
        "${goto 20}${font Droid Sans:style=Bold:size=18}${color0}│${font}${color} ${font Droid Sans:style=Bold:size=14}${color0}CPU:${font}${color} ${goto 120}${font Droid Sans:style=Bold:size=12}%s${font}${color} ${goto 400}${font Droid Sans:style=Bold:size=18}${color0}│${font}${color}\n" ..
        "${goto 20}${font Droid Sans:style=Bold:size=18}${color0}│${font}${color} ${font Droid Sans:style=Bold:size=14}${color0}HDD:${font}${color} ${goto 120}${font Droid Sans:style=Bold:size=12}%s${font}${color} ${goto 400}${font Droid Sans:style=Bold:size=18}${color0}│${font}${color}\n" ..
        "${goto 20}${font Droid Sans:style=Bold:size=18}${color0}└─────────────────────────────────────────────────────────────────┘${font}${color}",
        cpu_temp, hdd_temp)

    return result
end
