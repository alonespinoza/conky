-- ~/.conky/sections/common.lua
-- Common functions for the new Conky version

-- Helper function to read command output
local function read_cmd(cmd)
    local p = io.popen(cmd .. " 2>/dev/null")
    if not p then return "" end
    local out = p:read("*l") or ""
    p:close()
    return out
end

-- Helper function to format time
local function format_time(seconds)
    if not seconds or seconds == 0 then return "0:00" end
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

-- Helper function to truncate text
local function truncate(text, max_length)
    if not text then return "" end
    if string.len(text) <= max_length then return text end
    return string.sub(text, 1, max_length - 3) .. "..."
end

-- Export functions for other modules
_G.read_cmd = read_cmd
_G.format_time = format_time
_G.truncate = truncate
