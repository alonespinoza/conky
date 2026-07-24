-- ~/.conky/sections_circles/system.lua
-- System widget with simple display

-- Helper function to read command output
local function read_cmd(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return "" end
    local out = p:read("*l") or ""
    p:close()
    return out
end

-- Function to get CPU usage
local function get_cpu_usage()
    local cpu_info = read_cmd("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1")
    return tonumber(cpu_info) or 0
end

-- Function to get memory usage
local function get_memory_usage()
    local mem_info = read_cmd("free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'")
    return tonumber(mem_info) or 0
end

-- System display function
function conky_system_display()
    -- Get system information
    local hostname = read_cmd("hostname") or "Unknown"
    local kernel = read_cmd("uname -r") or "Unknown"
    local uptime = read_cmd("uptime -p") or "Unknown"

    -- Get usage percentages
    local cpu_usage = get_cpu_usage()
    local mem_usage = get_memory_usage()

    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}SYSTEM${font}${color}

# System Info
${voffset 10}${offset 20}${font Droid Sans:size=11}${color #3B4252}Hostname:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 2}${offset 20}${font Droid Sans:size=11}${color #3B4252}Kernel:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 2}${offset 20}${font Droid Sans:size=11}${color #3B4252}Uptime:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}

# CPU Progress
${voffset 15}${offset 20}${font Droid Sans:size=14:bold}${color #2E3440}CPU${font}${color}
${voffset 10}${offset 20}${font Droid Sans:size=12}${color #88C0D0}%s%%${color}${font}

# Memory Progress
${voffset 15}${offset 20}${font Droid Sans:size=14:bold}${color #2E3440}RAM${font}${color}
${voffset 10}${offset 20}${font Droid Sans:size=12}${color #88C0D0}%.0f%%${color}${font}

${voffset 25}${offset 20}${font Droid Sans:size=9}${color #5E81AC}${color}${font}
]], hostname, kernel, uptime, cpu_usage, mem_usage)
end
