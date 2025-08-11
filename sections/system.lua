-- ~/.conky/sections/system.lua
-- System information functions with Cairo-based display

-- Import Cairo library
local cairo = require("cairo")

-- Custom progress bar rendering (same as music widget)
local function render_bar(pct, width)
    if pct < 0 then pct = 0 end
    if pct > 1 then pct = 1 end
    local filled = math.floor(pct * width + 0.5)
    local empty = width - filled
    return string.rep("▰", filled) .. string.rep("▱", empty)
end

-- Helper functions
function conky_kernel()
    return conky_parse("${kernel}")
end

function conky_cpu_usage()
    return conky_parse("${cpu}")
end

function conky_mem_perc()
    return conky_parse("${memperc}")
end

function conky_swap_perc()
    return conky_parse("${swapperc}")
end

function conky_uptime()
    return conky_parse("${uptime}")
end

-- Cairo-based system display
function conky_draw_system()
    -- Simple debug - write to a file to see if function is called
    local debug_file = io.open("/tmp/cairo_test.txt", "w")
    if debug_file then
        debug_file:write("conky_draw_system called\n")
        debug_file:write("cairo_create available: " .. tostring(cairo_create) .. "\n")
        debug_file:write("conky_window: " .. tostring(conky_window) .. "\n")
        debug_file:close()
    end

    -- Check if Cairo is available
    if not cairo_create then
        return
    end

    if not conky_window then
        return
    end

    -- Debug: Check what's in conky_window (carefully)
    local debug_file = io.open("/tmp/cairo_test.txt", "a")
    if debug_file then
        debug_file:write("conky_window type: " .. type(conky_window) .. "\n")
        debug_file:write("conky_window address: " .. tostring(conky_window) .. "\n")
        debug_file:close()
    end

    local cr = cairo_create(conky_window)
    if not cr then
        return
    end

    -- Write to debug file that we got a Cairo context
    debug_file = io.open("/tmp/cairo_test.txt", "a")
    if debug_file then
        debug_file:write("Got Cairo context: " .. tostring(cr) .. "\n")
        debug_file:close()
    end

    -- Test: Draw a simple bright green rectangle first to see if drawing works
    if cairo_draw_rect then
        cairo_draw_rect(cr, 5, 5, 100, 100, { 0.0, 1.0, 0.0, 1.0 }, nil, nil) -- Bright green
    else
        -- Fallback to direct Cairo calls
        cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 1.0) -- Bright green
        cairo_rectangle(cr, 5, 5, 100, 100)
        cairo_fill(cr)
    end

    -- Write to debug file that we drew the test rectangle
    local debug_file = io.open("/tmp/cairo_test.txt", "a")
    if debug_file then
        debug_file:write("Drew test green rectangle using " .. (cairo_draw_rect and "helper" or "direct cairo") .. "\n")
        debug_file:close()
    end

    -- Get system information
    local kernel = conky_kernel() or "N/A"
    local cpu_usage = tonumber(conky_cpu_usage()) or 0
    local mem_perc = tonumber(conky_mem_perc()) or 0
    local swap_perc = tonumber(conky_swap_perc()) or 0
    local uptime = conky_uptime() or "N/A"
    local battery = tonumber(conky_parse("${battery_percent}")) or 0

    -- Get detailed memory and swap information
    local mem_used = conky_parse("${mem}") or "N/A"
    local mem_total = conky_parse("${memmax}") or "N/A"
    local swap_used = conky_parse("${swap}") or "N/A"
    local swap_total = conky_parse("${swapmax}") or "N/A"

    -- Create custom progress bars
    local cpu_bar = render_bar(cpu_usage / 100, 8)
    local mem_bar = render_bar(mem_perc / 100, 8)
    local swap_bar = render_bar(swap_perc / 100, 8)
    local battery_bar = render_bar(battery / 100, 8)

    -- Draw a bright, visible background rectangle first
    if cairo_draw_rect then
        cairo_draw_rect(cr, 10, 10, 400, 250, { 1.0, 0.0, 0.0, 0.8 }, nil, nil) -- Bright red background
    else
        -- Fallback to direct Cairo calls
        cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.8) -- Bright red background
        cairo_rectangle(cr, 10, 10, 400, 250)
        cairo_fill(cr)
    end

    -- Draw a thick border around the widget
    if cairo_draw_rect then
        cairo_draw_rect(cr, 10, 10, 400, 250, nil, { 0.0, 0.0, 1.0, 1.0 }, 5) -- Bright blue border
    else
        -- Fallback to direct Cairo calls
        cairo_set_source_rgba(cr, 0.0, 0.0, 1.0, 1.0) -- Bright blue border
        cairo_set_line_width(cr, 5)
        cairo_rectangle(cr, 10, 10, 400, 250)
        cairo_stroke(cr)
    end

    -- Draw background rectangle
    cairo_set_source_rgba(cr, 0.95, 0.95, 0.95, 0.9)
    cairo_rectangle(cr, 20, 20, 380, 230)
    cairo_fill(cr)
    cairo_set_source_rgba(cr, 0.2, 0.2, 0.2, 1.0)
    cairo_set_line_width(cr, 2)
    cairo_rectangle(cr, 20, 20, 380, 230)
    cairo_stroke(cr)

    -- Draw header
    cairo_select_font_face(cr, "Droid Sans", 0, 1)
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 0.2, 0.2, 0.2, 1.0)
    cairo_move_to(cr, 30, 50)
    cairo_show_text(cr, "SYSTEM")

    local y_pos = 80
    local line_height = 30

    -- Draw Kernel
    cairo_select_font_face(cr, "Droid Sans", 0, 0)
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.2, 0.2, 0.2, 1.0)
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "Kernel")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, kernel)

    y_pos = y_pos + line_height

    -- Draw CPU
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "CPU")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, string.format("%d%%", cpu_usage))
    cairo_move_to(cr, 200, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, cpu_bar)
    cairo_set_font_size(cr, 14)

    y_pos = y_pos + line_height

    -- Draw RAM
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "RAM")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, string.format("%d%%", mem_perc))
    cairo_move_to(cr, 200, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, mem_bar)
    cairo_set_font_size(cr, 14)
    cairo_move_to(cr, 320, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, string.format("%s/%s", mem_used, mem_total))
    cairo_set_font_size(cr, 14)

    y_pos = y_pos + line_height

    -- Draw SWAP
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "SWAP")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, string.format("%d%%", swap_perc))
    cairo_move_to(cr, 200, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, swap_bar)
    cairo_set_font_size(cr, 14)
    cairo_move_to(cr, 320, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, string.format("%s/%s", swap_used, swap_total))
    cairo_set_font_size(cr, 14)

    y_pos = y_pos + line_height

    -- Draw Uptime
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "Uptime")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, uptime)

    y_pos = y_pos + line_height

    -- Draw Battery
    cairo_move_to(cr, 30, y_pos)
    cairo_show_text(cr, "Battery")
    cairo_move_to(cr, 120, y_pos)
    cairo_show_text(cr, string.format("%d%%", battery))
    cairo_move_to(cr, 200, y_pos)
    cairo_set_font_size(cr, 12)
    cairo_show_text(cr, battery_bar)

    cairo_destroy(cr)
end

-- Text-based system display for testing (now disabled since we're using Cairo)
function conky_system_display()
    -- Get system information
    local kernel = conky_kernel() or "N/A"
    local cpu_usage = tonumber(conky_cpu_usage()) or 0
    local mem_perc = tonumber(conky_mem_perc()) or 0
    local swap_perc = tonumber(conky_swap_perc()) or 0
    local uptime = conky_uptime() or "N/A"
    local battery = tonumber(conky_parse("${battery_percent}")) or 0

    -- Get detailed memory and swap information
    local mem_used = conky_parse("${mem}") or "N/A"
    local mem_total = conky_parse("${memmax}") or "N/A"
    local swap_used = conky_parse("${swap}") or "N/A"
    local swap_total = conky_parse("${swapmax}") or "N/A"

    -- Create custom progress bars
    local cpu_bar = render_bar(cpu_usage / 100, 8)
    local mem_bar = render_bar(mem_perc / 100, 8)
    local swap_bar = render_bar(swap_perc / 100, 8)
    local battery_bar = render_bar(battery / 100, 8)

    return string.format([[
${voffset 10}${offset 20}${font Droid Sans:size=16:bold}${color #2E3440}SYSTEM${font}${color}
${voffset 8}${offset 20}${font Droid Sans:size=11}${color #3B4252}Kernel:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%s${color}${font}
${voffset 3}${offset 20}${font Droid Sans:size=11}${color #3B4252}CPU:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}
${voffset 3}${offset 20}${font Droid Sans:size=11}${color #3B4252}RAM:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #81A1C1}%s/%s${color}${font}
${voffset 3}${offset 20}${font Droid Sans:size=11}${color #3B4252}SWAP:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}${goto 320}${font Droid Sans:size=9}${color #81A1C1}%s/%s${color}${font}
${voffset 3}${offset 20}${font Droid Sans:size=11}${color #3B4252}Uptime:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%s${color}${font}
${voffset 3}${offset 20}${font Droid Sans:size=11}${color #3B4252}Battery:${color}${goto 150}${font Droid Sans:size=11}${color #4C566A}%d%%${color}${font}${goto 220}${font Droid Sans:size=9}${color #5E81AC}%s${color}${font}
]], kernel, cpu_usage, cpu_bar, mem_perc, mem_bar, mem_used, mem_total,
        swap_perc, swap_bar, swap_used, swap_total, uptime, battery, battery_bar)
end
