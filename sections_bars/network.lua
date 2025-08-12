-- ~/.conky/sections/network.lua
-- Network information functions with beautiful formatting

-- Network interface configuration
local iface_wired = os.getenv("CONKY_IF_WIRED") or "enxf8e43b958d47"
local iface_wireless = os.getenv("CONKY_IF_WIFI") or "wlo1"

-- Helper function to get network information
local function get_network_info()
    local up_speed = conky_parse("${upspeed " .. iface_wired .. "}") or "0B/s"
    local down_speed = conky_parse("${downspeed " .. iface_wired .. "}") or "0B/s"
    local total_up = conky_parse("${totalup " .. iface_wired .. "}") or "0B"
    local total_down = conky_parse("${totaldown " .. iface_wired .. "}") or "0B"
    local wifi_addr = conky_parse("${addr " .. iface_wireless .. "}") or "N/A"
    local eth_addr = conky_parse("${addr " .. iface_wired .. "}") or "N/A"
    local public_ip = conky_parse("${execi 300 curl -s ifconfig.me}") or "N/A"

    return up_speed, down_speed, total_up, total_down, wifi_addr, eth_addr, public_ip
end

-- Custom progress bar rendering (same as other widgets)
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

-- Beautiful network display with Nord color scheme
function conky_network_display()
    -- Get network information
    local up_speed, down_speed, total_up, total_down, wifi_addr, eth_addr, public_ip = get_network_info()

    return string.format([[
${voffset 8}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}NETWORK${font}${color}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Upload:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}${goto 220}${font Droid Sans:size=9}${color #D8DEE9}%s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Download:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}${goto 220}${font Droid Sans:size=9}${color #D8DEE9}%s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Wireless:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Ethernet:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Public IP:${color}${goto 150}${font Droid Sans:size=11}${color #88C0D0}%s${color}${font}
]], up_speed, total_up, down_speed, total_down, wifi_addr, eth_addr, public_ip)
end
