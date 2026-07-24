-- ~/.conky/sections_circles/weather.lua
-- Basic weather widget placeholder

-- Weather display function
function conky_weather_display()
    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}WEATHER${font}${color}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}Status:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}Ready for circles${color}${font}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}Location:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}To be configured${color}${font}
${voffset 25}${offset 20}${font Droid Sans:size=9}${color #5E81AC}${color}${font}
]])
end
