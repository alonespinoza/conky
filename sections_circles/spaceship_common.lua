-- Common Cairo drawing functions for Conky Spaceship Semi-Circles
-- This file contains all the Cairo drawing functions for futuristic semi-circular progress bars

-- Try to load the Cairo X11 module explicitly if not already loaded
if not cairo_xlib_surface_create then
    local cairo_xlib_lib = package.loadlib("/usr/local/lib/conky/libcairo_xlib.so", "luaopen_cairo_xlib")
    if cairo_xlib_lib then
        local cairo_xlib_loaded = cairo_xlib_lib()
    end
end

-- Try to load the basic Cairo module explicitly if not already loaded
if not cairo_create then
    local cairo_lib = package.loadlib("/usr/local/lib/conky/libcairo.so", "luaopen_cairo")
    if cairo_lib then
        local cairo_loaded = cairo_lib()
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

    -- Draw futuristic semi-circular progress bars
    draw_spaceship_cpu_semicircle(cpu, temp)
    draw_spaceship_memory_semicircle(mem)
    draw_spaceship_swap_semicircle(swap)
    draw_spaceship_disk_semicircle(disk)

    -- Draw spaceship header
    draw_spaceship_header(hostname, kernel, uptime)
end

-- Draw futuristic CPU usage semi-circle with temperature
function draw_spaceship_cpu_semicircle(percentage, temperature)
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

    -- Draw background semi-circle with gradient effect (gray/light blue theme)
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.8) -- Medium gray center
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.4) -- Darker gray edge
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2) -- Semi-circle from -90° to +90°
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gray/light blue gradient
    local angle = (percentage / 100) * math.pi                                   -- Only half circle (0 to π)
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.6, 0.8, 1.0)   -- Light blue center
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0.5, 0.3, 0.5, 0.7, 0.9) -- Medium light blue
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.4, 0.6, 0.8)   -- Darker light blue edge
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner semi-circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.1, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, -math.pi / 2, math.pi / 2)
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
    cairo_set_source_rgba(cr, 0.0, 0.8, 1.0, 1.0) -- Cyan temperature
    local temp_text = string.format("%.0f°C", temperature)
    cairo_text_extents(cr, temp_text, extents)
    local temp_x = center_x - (extents.width / 2)
    local temp_y = center_y + 25
    cairo_move_to(cr, temp_x, temp_y)
    cairo_show_text(cr, temp_text)

    -- Draw label at the bottom of the semi-circle
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue label
    local label_text = "CPU"
    cairo_text_extents(cr, label_text, extents)
    local label_x = center_x - (extents.width / 2) - 20
    local label_y = center_y + radius + 8
    cairo_move_to(cr, label_x, label_y)
    cairo_show_text(cr, label_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw futuristic memory usage semi-circle
function draw_spaceship_memory_semicircle(percentage)
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

    -- Draw background semi-circle with gradient effect (gray/light blue theme)
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.8) -- Medium gray center
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.4) -- Darker gray edge
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2) -- Semi-circle from -90° to +90°
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gray/light blue gradient
    local angle = (percentage / 100) * math.pi                                   -- Only half circle (0 to π)
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.6, 0.8, 1.0)   -- Light blue center
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0.5, 0.3, 0.5, 0.7, 0.9) -- Medium light blue
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.4, 0.6, 0.8)   -- Darker light blue edge
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner semi-circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.1, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, -math.pi / 2, math.pi / 2)
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
    cairo_set_source_rgba(cr, 0.0, 1.0, 0.8, 1.0) -- Green memory details
    local mem_used = conky_parse("${mem}")
    local mem_total = conky_parse("${memmax}")
    local mem_text = string.format("%s / %s", mem_used, mem_total)
    cairo_text_extents(cr, mem_text, extents)
    local mem_x = center_x - (extents.width / 2)
    local mem_y = center_y + 25
    cairo_move_to(cr, mem_x, mem_y)
    cairo_show_text(cr, mem_text)

    -- Draw label at the bottom of the semi-circle
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue label
    local label_text = "MEM"
    cairo_text_extents(cr, label_text, extents)
    local label_x = center_x - (extents.width / 2) - 20
    local label_y = center_y + radius + 8
    cairo_move_to(cr, label_x, label_y)
    cairo_show_text(cr, label_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw futuristic swap usage semi-circle
function draw_spaceship_swap_semicircle(percentage)
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

    -- Draw background semi-circle with gradient effect (gray/light blue theme)
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.8) -- Medium gray center
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.4) -- Darker gray edge
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2) -- Semi-circle from -90° to +90°
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gray/light blue gradient
    local angle = (percentage / 100) * math.pi                                   -- Only half circle (0 to π)
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.6, 0.8, 1.0)   -- Light blue center
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0.5, 0.3, 0.5, 0.7, 0.9) -- Medium light blue
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.4, 0.6, 0.8)   -- Darker light blue edge
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner semi-circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.1, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, -math.pi / 2, math.pi / 2)
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
    cairo_set_source_rgba(cr, 1.0, 0.6, 0.0, 1.0) -- Orange swap details
    local swap_used = conky_parse("${swap}")
    local swap_total = conky_parse("${swapmax}")
    local swap_text = string.format("%s / %s", swap_used, swap_total)
    cairo_text_extents(cr, swap_text, extents)
    local swap_x = center_x - (extents.width / 2)
    local swap_y = center_y + 25
    cairo_move_to(cr, swap_x, swap_y)
    cairo_show_text(cr, swap_text)

    -- Draw label at the bottom of the semi-circle
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue label
    local label_text = "SWAP"
    cairo_text_extents(cr, label_text, extents)
    local label_x = center_x - (extents.width / 2) - 20
    local label_y = center_y + radius + 8
    cairo_move_to(cr, label_x, label_y)
    cairo_show_text(cr, label_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw futuristic disk usage semi-circle
function draw_spaceship_disk_semicircle(percentage)
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

    -- Draw background semi-circle with gradient effect (gray/light blue theme)
    local pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(pattern, 0, 0.3, 0.3, 0.4, 0.8) -- Medium gray center
    cairo_pattern_add_color_stop_rgba(pattern, 1, 0.2, 0.2, 0.3, 0.4) -- Darker gray edge
    cairo_set_source(cr, pattern)
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2) -- Semi-circle from -90° to +90°
    cairo_stroke(cr)
    cairo_pattern_destroy(pattern)

    -- Draw progress arc with gray/light blue gradient
    local angle = (percentage / 100) * math.pi                                   -- Only half circle (0 to π)
    local progress_pattern = cairo_pattern_create_radial(center_x, center_y, 0, center_x, center_y, radius)
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0, 0.4, 0.6, 0.8, 1.0)   -- Light blue center
    cairo_pattern_add_color_stop_rgba(progress_pattern, 0.5, 0.3, 0.5, 0.7, 0.9) -- Medium light blue
    cairo_pattern_add_color_stop_rgba(progress_pattern, 1, 0.2, 0.4, 0.6, 0.8)   -- Darker light blue edge
    cairo_set_source(cr, progress_pattern)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)
    cairo_pattern_destroy(progress_pattern)

    -- Draw inner semi-circle for text background
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.1, 0.9)
    cairo_arc(cr, center_x, center_y, radius - line_width - 5, -math.pi / 2, math.pi / 2)
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
    cairo_set_source_rgba(cr, 1.0, 0.0, 0.8, 1.0) -- Red disk details
    local disk_used = conky_parse("${fs_used /}")
    local disk_total = conky_parse("${fs_size /}")
    local disk_text = string.format("%s / %s", disk_used, disk_total)
    cairo_text_extents(cr, disk_text, extents)
    local disk_x = center_x - (extents.width / 2)
    local disk_y = center_y + 25
    cairo_move_to(cr, disk_x, disk_y)
    cairo_show_text(cr, disk_text)

    -- Draw label at the bottom of the semi-circle
    cairo_set_font_size(cr, 12)
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue label
    local label_text = "DISK"
    cairo_text_extents(cr, label_text, extents)
    local label_x = center_x - (extents.width / 2) - 20
    local label_y = center_y + radius + 8
    cairo_move_to(cr, label_x, label_y)
    cairo_show_text(cr, label_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

-- Draw spaceship header with hostname, kernel, and uptime
function draw_spaceship_header(hostname, kernel, uptime)
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



    -- Draw hostname
    cairo_set_font_size(cr, 14)
    cairo_set_source_rgba(cr, 0.8, 0.8, 0.8, 1.0) -- Light gray
    local hostname_text = "Host: " .. hostname
    cairo_text_extents(cr, hostname_text, extents)
    local hostname_x = 350
    local hostname_y = 50
    cairo_move_to(cr, hostname_x, hostname_y)
    cairo_show_text(cr, hostname_text)

    -- Draw kernel version
    local kernel_text = "Kernel: " .. kernel
    cairo_text_extents(cr, kernel_text, extents)
    local kernel_x = 350
    local kernel_y = 70
    cairo_move_to(cr, kernel_x, kernel_y)
    cairo_show_text(cr, kernel_text)

    -- Draw uptime
    local uptime_text = "Uptime: " .. uptime
    cairo_text_extents(cr, uptime_text, extents)
    local uptime_x = 350
    local uptime_y = 90
    cairo_move_to(cr, uptime_x, uptime_y)
    cairo_show_text(cr, uptime_text)

    -- Draw current time
    local current_time = conky_parse("${time %H:%M:%S}")
    local time_text = "Time: " .. current_time
    cairo_text_extents(cr, time_text, extents)
    local time_x = 350
    local time_y = 110
    cairo_move_to(cr, time_x, time_y)
    cairo_show_text(cr, time_text)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
