-- ~/.conky/sections/filesystem.lua
-- Filesystem information functions with beautiful formatting

-- Helper function to get filesystem information
local function fs(line)
    return conky_parse(line)
end

-- Get filesystem usage percentages
function conky_fs_root_perc()
    return tonumber(fs("${fs_used_perc /}")) or 0
end

function conky_fs_home_perc()
    return tonumber(fs("${fs_used_perc /home}")) or 0
end

-- Get filesystem usage details
function conky_fs_root_usage()
    return fs("${fs_used /}") or "N/A"
end

function conky_fs_root_size()
    return fs("${fs_size /}") or "N/A"
end

function conky_fs_home_usage()
    return fs("${fs_used /home}") or "N/A"
end

function conky_fs_home_size()
    return fs("${fs_size /home}") or "N/A"
end

-- Custom progress bar rendering (same as system widget)
local function render_bar(pct, width)
    if pct < 0 then pct = 0 end
    if pct > 1 then pct = 1 end
    local filled = math.floor(pct * width + 0.5)
    local empty = width - filled
    return string.rep("▰", filled) .. string.rep("▱", empty)
end

-- Beautiful filesystem display with Nord color scheme
function conky_filesystem_display()
    -- Get filesystem information
    local root_perc = conky_fs_root_perc()
    local home_perc = conky_fs_home_perc()
    local root_used = conky_fs_root_usage()
    local root_size = conky_fs_root_size()
    local home_used = conky_fs_home_usage()
    local home_size = conky_fs_home_size()

    -- Create custom progress bars
    local root_bar = render_bar(root_perc / 100, 8)
    local home_bar = render_bar(home_perc / 100, 8)

    return string.format([[
${voffset 8}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}FILESYSTEM${font}${color}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Root (/):${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #8FBCBB}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #D8DEE9}%s / %s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Home:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #8FBCBB}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #D8DEE9}%s / %s${color}${font}
]], root_perc, root_bar, root_used, root_size, home_perc, home_bar, home_used, home_size)
end
