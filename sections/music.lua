-- ~/.conky/sections/music.lua
-- Music widget with Nord color scheme and text-based formatting

-- Helper function to read command output
local function read_cmd(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return "" end
    local out = p:read("*l") or ""
    p:close()
    return out
end

-- Get music information using playerctl
local function get_music_info()
    local title = read_cmd("playerctl metadata title") or "No track"
    local artist = read_cmd("playerctl metadata artist") or "No artist"
    local position = read_cmd("playerctl position") or "0"
    local length = read_cmd("playerctl metadata mpris:length") or "0"

    -- Convert time values to seconds
    local pos_sec = tonumber(position) or 0
    local len_sec = tonumber(length) or 0

    -- mpris:length is in microseconds, position is already in seconds
    if len_sec > 1e6 then
        len_sec = len_sec / 1e6 -- Convert microseconds to seconds
    end

    -- Calculate progress percentage
    local progress = 0
    if len_sec > 0 then
        progress = math.max(0, math.min(1, pos_sec / len_sec))
    end



    -- Format time strings
    local function format_time(seconds)
        local m = math.floor(seconds / 60)
        local s = math.floor(seconds % 60)
        return string.format("%d:%02d", m, s)
    end

    local pos_time = format_time(pos_sec)
    local len_time = format_time(len_sec)

    -- Truncate long titles and artist names
    if string.len(title) > 30 then
        title = string.sub(title, 1, 27) .. "..."
    end
    if string.len(artist) > 30 then
        artist = string.sub(artist, 1, 27) .. "..."
    end

    return title, artist, progress, pos_time, len_time
end

-- Create custom progress bar
local function render_bar(percentage, width)
    if percentage < 0 then percentage = 0 end
    if percentage > 1 then percentage = 1 end

    local filled = math.floor(percentage * width + 0.5)
    local empty = width - filled

    if filled < 0 then filled = 0 end
    if empty < 0 then empty = 0 end

    return string.rep("▰", filled) .. string.rep("▱", empty)
end

-- Smart music display with selective updates
local last_title = ""
local last_artist = ""

function conky_music_display()
    -- Get music information
    local title, artist, progress, pos_time, len_time = get_music_info()

    -- Only update title/artist if they changed (reduces flickering)
    if title ~= last_title or artist ~= last_artist then
        last_title = title
        last_artist = artist
    end

    -- Create progress bar
    local progress_bar = render_bar(progress, 25)

    return string.format([[
${voffset 20}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}NOW PLAYING ♪${font}${color}
${voffset 15}${offset 20}${font Droid Sans:size=14:bold}${color #88C0D0}%s${color}${font}
${voffset 12}${offset 20}${font Droid Sans:size=12}${color #D8DEE9}%s${color}${font}
${voffset 15}${offset 20}${font Droid Sans:size=10}${color #5E81AC}%s${color}${font}
${voffset 12}${offset 20}${font Droid Sans:size=11}${color #81A1C1}%s / %s${color}${font}
${voffset 25}${offset 20}${font Droid Sans:size=9}${color #5E81AC}${color}${font}
]], title, artist, progress_bar, pos_time, len_time)
end
