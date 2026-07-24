-- Common Cairo drawing functions for Conky Circles
-- This file contains all the Cairo drawing functions for modern circular progress bars

-- Try to load the Cairo X11 module explicitly if not already loaded
if not cairo_xlib_surface_create then
    local cairo_xlib_lib = package.loadlib("/usr/local/lib/conky/libcairo_xlib.so", "luaopen_cairo_xlib")
    if cairo_xlib_lib then
        local cairo_xlib_loaded = cairo_xlib_lib()
        if not cairo_xlib_loaded then
            print("Failed to initialize Cairo X11 module")
        end
    else
        print("Failed to load Cairo X11 module")
    end
end

-- Try to load the basic Cairo module explicitly if not already loaded
if not cairo_create then
    local cairo_lib = package.loadlib("/usr/local/lib/conky/libcairo.so", "luaopen_cairo")
    if cairo_lib then
        local cairo_loaded = cairo_lib()
        if not cairo_loaded then
            print("Failed to initialize basic Cairo module")
        end
    else
        print("Failed to load basic Cairo module")
    end
end

-- Main Cairo drawing function
function conky_cairo_pre()
    if conky_window == nil then return end

    -- Get system information
    local cpu = tonumber(conky_parse("${cpu}")) or 0
    local mem = tonumber(conky_parse("${memperc}")) or 0
    local swap = tonumber(conky_parse("${swapperc}")) or 0
    local disk = tonumber(conky_parse("${fs_used_perc /}")) or 0
    local temp = tonumber(conky_parse("${acpitemp}")) or 0
    local uptime = conky_parse("${uptime}")
    local hostname = conky_parse("${nodename}")
    local kernel = conky_parse("${kernel}")

    -- Draw modern circular progress bars
    draw_modern_cpu_ring(cpu, temp)
    draw_modern_memory_ring(mem)
    draw_modern_swap_ring(swap)
    draw_modern_disk_ring(disk)

    -- Draw system header
    draw_system_header(hostname, kernel, uptime)
end

-- Draw modern CPU usage semi-circle with temperature (spaceship style)
function draw_modern_cpu_ring(percentage, temperature)
    local center_x = 100
    local center_y = 120
    local radius = 70
    local line_width = 10

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    -- Draw background circle with gradient effect
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.6) -- Gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.3) -- Darker gray-blue with more transparency
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, 0, 2 * math.pi)
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gradient
    local angle = (percentage / 100) * 2 * math.pi
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.5, 0.8, 0.9) -- Light gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.3, 0.6, 0.7) -- Darker gray-blue with transparency
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.05, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Draw percentage text with enhanced formatting
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)

    -- Create gradient text effect
    local text_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, 30)
    cairo_pattern_add_color_stop_rgba(text_pattern, 0, 1.0, 1.0, 1.0, 1.0) -- Bright white center
    cairo_pattern_add_color_stop_rgba(text_pattern, 1, 0.8, 0.9, 1.0, 0.9) -- Light blue edge
    cairo_set_source(cr, text_pattern)

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Clean up pattern
    cairo_pattern_destroy(text_pattern)

    -- Draw temperature below percentage
    cairo_set_font_size(cr, 12)
    local temp_text = string.format("%.0f°C", temperature)
    cairo_text_extents(cr, temp_text, extents)
    local temp_x = center_x - (extents.width / 2)
    local temp_y = center_y + 25
    cairo_move_to(cr, temp_x, temp_y)
    cairo_show_text(cr, temp_text)

    -- Draw header text above circle
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.4, 0.5, 0.8, 1.0) -- Gray-blue header
    local header_text = "CPU"
    cairo_text_extents(cr, header_text, extents)
    local header_x = center_x - (extents.width / 2)
    local header_y = center_y - radius - 15
    cairo_move_to(cr, header_x, header_y)
    cairo_show_text(cr, header_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw modern memory usage ring
function draw_modern_memory_ring(percentage)
    local center_x = 300
    local center_y = 120
    local radius = 70
    local line_width = 10

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    -- Draw background circle with gradient effect
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.6) -- Gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.3) -- Darker gray-blue with more transparency
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, 0, 2 * math.pi)
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gradient
    local angle = (percentage / 100) * 2 * math.pi
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.5, 0.8, 0.9) -- Light gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.3, 0.6, 0.7) -- Darker gray-blue with transparency
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.05, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Draw percentage text with enhanced formatting
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)

    -- Create gradient text effect
    local text_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, 30)
    cairo_pattern_add_color_stop_rgba(text_pattern, 0, 1.0, 1.0, 1.0, 1.0) -- Bright white center
    cairo_pattern_add_color_stop_rgba(text_pattern, 1, 0.8, 0.9, 1.0, 0.9) -- Light blue edge
    cairo_set_source(cr, text_pattern)

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Clean up pattern
    cairo_pattern_destroy(text_pattern)

    -- Draw memory details below percentage
    cairo_set_font_size(cr, 12)
    local mem_used = conky_parse("${mem}")
    local mem_total = conky_parse("${memmax}")
    local mem_text = string.format("%s / %s", mem_used, mem_total)
    cairo_text_extents(cr, mem_text, extents)
    local mem_x = center_x - (extents.width / 2)
    local mem_y = center_y + 25
    cairo_move_to(cr, mem_x, mem_y)
    cairo_show_text(cr, mem_text)

    -- Draw header text above circle
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.4, 0.5, 0.8, 1.0) -- Gray-blue header
    local header_text = "MEMORY"
    cairo_text_extents(cr, header_text, extents)
    local header_x = center_x - (extents.width / 2)
    local header_y = center_y - radius - 15
    cairo_move_to(cr, header_x, header_y)
    cairo_show_text(cr, header_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw modern swap usage ring
function draw_modern_swap_ring(percentage)
    local center_x = 100
    local center_y = 280
    local radius = 70
    local line_width = 10

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    -- Draw background circle with gradient effect
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.6) -- Gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.3) -- Darker gray-blue with more transparency
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, 0, 2 * math.pi)
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gradient
    local angle = (percentage / 100) * 2 * math.pi
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.5, 0.8, 0.9) -- Light gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.3, 0.6, 0.7) -- Darker gray-blue with transparency
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.05, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Draw percentage text with enhanced formatting
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)

    -- Create gradient text effect
    local text_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, 30)
    cairo_pattern_add_color_stop_rgba(text_pattern, 0, 1.0, 1.0, 1.0, 1.0) -- Bright white center
    cairo_pattern_add_color_stop_rgba(text_pattern, 1, 0.8, 0.9, 1.0, 0.9) -- Light blue edge
    cairo_set_source(cr, text_pattern)

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Clean up pattern
    cairo_pattern_destroy(text_pattern)

    -- Draw swap details below percentage
    cairo_set_font_size(cr, 12)
    local swap_used = conky_parse("${swap}")
    local swap_total = conky_parse("${swapmax}")
    local swap_text = string.format("%s / %s", swap_used, swap_total)
    cairo_text_extents(cr, swap_text, extents)
    local swap_x = center_x - (extents.width / 2)
    local swap_y = center_y + 25
    cairo_move_to(cr, swap_x, swap_y)
    cairo_show_text(cr, swap_text)

    -- Draw header text above circle
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.4, 0.5, 0.8, 1.0) -- Gray-blue header
    local header_text = "SWAP"
    cairo_text_extents(cr, header_text, extents)
    local header_x = center_x - (extents.width / 2)
    local header_y = center_y - radius - 15
    cairo_move_to(cr, header_x, header_y)
    cairo_show_text(cr, header_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw modern disk usage ring
function draw_modern_disk_ring(percentage)
    local center_x = 300
    local center_y = 280
    local radius = 70
    local line_width = 10

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    -- Draw background circle with gradient effect
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.6) -- Gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.3) -- Darker gray-blue with more transparency
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, 0, 2 * math.pi)
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gradient
    local angle = (percentage / 100) * 2 * math.pi
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.5, 0.8, 0.9) -- Light gray-blue with transparency
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.3, 0.6, 0.7) -- Darker gray-blue with transparency
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.05, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Draw percentage text with enhanced formatting
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)

    -- Create gradient text effect
    local text_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, 30)
    cairo_pattern_add_color_stop_rgba(text_pattern, 0, 1.0, 1.0, 1.0, 1.0) -- Bright white center
    cairo_pattern_add_color_stop_rgba(text_pattern, 1, 0.8, 0.9, 1.0, 0.9) -- Light blue edge
    cairo_set_source(cr, text_pattern)

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Clean up pattern
    cairo_pattern_destroy(text_pattern)

    -- Draw disk details below percentage
    cairo_set_font_size(cr, 12)
    local disk_used = conky_parse("${fs_used /}")
    local disk_total = conky_parse("${fs_size /}")
    local disk_text = string.format("%s / %s", disk_used, disk_total)
    cairo_text_extents(cr, disk_text, extents)
    local disk_x = center_x - (extents.width / 2)
    local disk_y = center_y + 25
    cairo_move_to(cr, disk_x, disk_y)
    cairo_show_text(cr, disk_text)

    -- Draw header text above circle
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.4, 0.5, 0.8, 1.0) -- Gray-blue header
    local header_text = "DISK"
    cairo_text_extents(cr, header_text, extents)
    local header_x = center_x - (extents.width / 2)
    local header_y = center_y - radius - 15
    cairo_move_to(cr, header_x, header_y)
    cairo_show_text(cr, header_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw system header with hostname, kernel, and uptime
function draw_system_header(hostname, kernel, uptime)
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    -- Set text properties
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0)
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)

    -- Draw main title
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 0.4, 0.5, 0.8, 1.0) -- Gray-blue
    local title = "SYSTEM MONITOR"
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, title, extents)
    local title_x = 200 - (extents.width / 2)
    local title_y = 30
    cairo_move_to(cr, title_x, title_y)
    cairo_show_text(cr, title)

    -- Draw hostname
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.8, 0.8, 0.8, 1.0) -- Light gray
    local hostname_text = "Host: " .. hostname
    cairo_text_extents(cr, hostname_text, extents)
    local hostname_x = 20
    local hostname_y = 50
    cairo_move_to(cr, hostname_x, hostname_y)
    cairo_show_text(cr, hostname_text)

    -- Draw kernel version
    local kernel_text = "Kernel: " .. kernel
    cairo_text_extents(cr, kernel_text, extents)
    local kernel_x = 20
    local kernel_y = 70
    cairo_move_to(cr, kernel_x, kernel_y)
    cairo_show_text(cr, kernel_text)

    -- Draw uptime
    local uptime_text = "Uptime: " .. uptime
    cairo_text_extents(cr, uptime_text, extents)
    local uptime_x = 20
    local uptime_y = 90
    cairo_move_to(cr, uptime_x, uptime_y)
    cairo_show_text(cr, uptime_text)

    -- Draw current time
    local current_time = conky_parse("${time %H:%M:%S}")
    local time_text = "Time: " .. current_time
    cairo_text_extents(cr, time_text, extents)
    local time_x = 20
    local time_y = 110
    cairo_move_to(cr, time_x, time_y)
    cairo_show_text(cr, time_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
