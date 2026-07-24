-- Simple Cairo drawing functions for Conky Semi-Circles
-- This is a simplified, stable version without complex gradients

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
    local uptime = conky_parse("${uptime}")
    local hostname = conky_parse("${nodename}")
    local kernel = conky_parse("${kernel}")

    -- Draw simple semi-circular progress bars
    draw_simple_cpu_semicircle(cpu)
    draw_simple_memory_semicircle(mem)
    draw_simple_swap_semicircle(swap)
    draw_simple_disk_semicircle(disk)

    -- Draw simple header
    draw_simple_header(hostname, kernel, uptime)
end

-- Draw simple CPU usage semi-circle
function draw_simple_cpu_semicircle(percentage)
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

    -- Draw background semi-circle
    cairo_set_source_rgba(cr, 0.3, 0.3, 0.4, 0.4) -- Medium gray with transparency
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2)
    cairo_stroke(cr)

    -- Draw progress arc
    local angle = (percentage / 100) * math.pi
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 0.7) -- Light blue with transparency
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)

    -- Draw percentage text
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0) -- White text

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, label_text)

    -- Draw label
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

-- Draw simple memory usage semi-circle
function draw_simple_memory_semicircle(percentage)
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

    -- Draw background semi-circle
    cairo_set_source_rgba(cr, 0.3, 0.3, 0.4, 0.8) -- Medium gray
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2)
    cairo_stroke(cr)

    -- Draw progress arc
    local angle = (percentage / 100) * math.pi
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)

    -- Draw percentage text
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0) -- White text

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Draw label
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

-- Draw simple swap usage semi-circle
function draw_simple_swap_semicircle(percentage)
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

    -- Draw background semi-circle
    cairo_set_source_rgba(cr, 0.3, 0.3, 0.4, 0.8) -- Medium gray
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2)
    cairo_stroke(cr)

    -- Draw progress arc
    local angle = (percentage / 100) * math.pi
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)

    -- Draw percentage text
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0) -- White text

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Draw label
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

-- Draw simple disk usage semi-circle
function draw_simple_disk_semicircle(percentage)
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

    -- Draw background semi-circle
    cairo_set_source_rgba(cr, 0.3, 0.3, 0.4, 0.8) -- Medium gray
    cairo_set_line_width(cr, line_width)
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, math.pi / 2)
    cairo_stroke(cr)

    -- Draw progress arc
    local angle = (percentage / 100) * math.pi
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.8, 1.0) -- Light blue
    cairo_arc(cr, center_x, center_y, radius, -math.pi / 2, -math.pi / 2 + angle)
    cairo_stroke(cr)

    -- Draw percentage text
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 20)
    cairo_set_font_size(cr, 20)
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0) -- White text

    local text = string.format("%.0f%%", percentage)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    local text_x = center_x - (extents.width / 2)
    local text_y = center_y + (extents.height / 2)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, text)

    -- Draw label
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

-- Draw simple header
function draw_simple_header(hostname, kernel, uptime)
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    if not cs then return end

    local cr = cairo_create(cs)
    if not cr then
        cairo_surface_destroy(cs)
        return
    end

    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_source_rgba(cr, 0.8, 0.8, 0.8, 1.0) -- Light gray

    -- Draw hostname
    cairo_set_font_size(cr, 14)
    local hostname_text = "Host: " .. hostname
    local extents = cairo_text_extents_t:create()
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
