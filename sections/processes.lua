-- ~/.conky/sections/processes.lua
-- Processes information functions with beautiful formatting

-- Helper function to get process information
local function get_top_processes()
    local cpu_name = conky_parse("${top name 1}") or "N/A"
    local cpu_usage = tonumber(conky_parse("${top cpu 1}")) or 0
    local mem_name = conky_parse("${top_mem name 1}") or "N/A"
    local mem_usage = tonumber(conky_parse("${top_mem mem 1}")) or 0

    -- Truncate long process names
    if string.len(cpu_name) > 20 then
        cpu_name = string.sub(cpu_name, 1, 17) .. "..."
    end
    if string.len(mem_name) > 20 then
        mem_name = string.sub(mem_name, 1, 17) .. "..."
    end

    return cpu_name, cpu_usage, mem_name, mem_usage
end

-- Custom progress bar rendering (same as system and filesystem widgets)
local function render_bar(pct, width)
    if pct < 0 then pct = 0 end
    if pct > 1 then pct = 1 end

    -- For very small percentages, show at least one filled block
    local filled = math.floor(pct * width + 0.5)
    if pct > 0 and filled == 0 then
        filled = 1
    end

    local empty = width - filled
    if empty < 0 then empty = 0 end
    if filled < 0 then filled = 0 end

    return string.rep("▰", filled) .. string.rep("▱", empty)
end

-- Beautiful processes display with Nord color scheme
function conky_processes_display()
    -- Get process information
    local cpu_name, cpu_usage, mem_name, mem_usage = get_top_processes()

    -- Create custom progress bars
    local cpu_bar = render_bar(cpu_usage / 100, 8)
    local mem_bar = render_bar(mem_usage / 100, 8)

    return string.format([[
${voffset 8}${offset -10}${font Droid Sans:size=16:bold}${color #2E3440}PROCESSES${font}${color}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Top CPU:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%.1f%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #81A1C1}%s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Top RAM:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%.1f%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #81A1C1}%s${color}${font}
]], cpu_usage, cpu_bar, cpu_name, mem_usage, mem_bar, mem_name)
end
