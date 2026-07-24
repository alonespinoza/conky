-- ~/.conky/sections/system.lua
-- Basic system widget for the new version

-- Helper function to read command output
local function read_cmd(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return "" end
    local out = p:read("*l") or ""
    p:close()
    return out
end

-- System display function
function conky_system_display()
    -- Get system information
    local hostname = read_cmd("hostname") or "Unknown"
    local kernel = read_cmd("uname -r") or "Unknown"
    local uptime = read_cmd("uptime -p") or "Unknown"

    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}SYSTEM${font}${color}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}Hostname:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}Kernel:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 15}${offset 20}${font Droid Sans:size=11}${color #3B4252}Uptime:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 25}${offset 20}${font Droid Sans:size=9}${color #5E81AC}${color}${font}
]], hostname, kernel, uptime)
end
