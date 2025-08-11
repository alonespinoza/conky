-- ~/.conky/sections/common_draw.lua
-- Common Cairo helpers for Conky

-- Check if required Cairo API is available
local function have_cairo()
    return cairo_new_sub_path and cairo_arc and cairo_close_path and cairo_set_source_rgba
        and cairo_fill and cairo_fill_preserve and cairo_set_line_width and cairo_stroke
end

-- Build a rounded-rectangle path on the given Cairo context
function cairo_path_rounded_rect(cr, x, y, w, h, r)
    if not (cr and have_cairo()) then return end
    r = math.max(0, math.min(r or 0, math.floor(math.min(w, h) / 2)))
    cairo_new_sub_path(cr)
    cairo_arc(cr, x + w - r, y + r, r, -math.pi / 2, 0)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi / 2)
    cairo_arc(cr, x + r, y + h - r, r, math.pi / 2, math.pi)
    cairo_arc(cr, x + r, y + r, r, math.pi, 3 * math.pi / 2)
    cairo_close_path(cr)
end

-- Draw a rounded-rectangle with fill and optional stroke
-- fill: {r,g,b,a}  stroke: {r,g,b,a} or nil  stroke_width: number or nil
function cairo_draw_rounded_rect(cr, x, y, w, h, r, fill, stroke, stroke_width)
    if not (cr and have_cairo()) then return end
    cairo_path_rounded_rect(cr, x, y, w, h, r)
    local fr, fg, fb, fa = (fill and fill[1] or 0), (fill and fill[2] or 0), (fill and fill[3] or 0),
        (fill and fill[4] or 1)
    cairo_set_source_rgba(cr, fr, fg, fb, fa)
    if stroke then
        cairo_fill_preserve(cr)
        local sr, sg, sb, sa = stroke[1] or 1, stroke[2] or 1, stroke[3] or 1, stroke[4] or 1
        cairo_set_source_rgba(cr, sr, sg, sb, sa)
        cairo_set_line_width(cr, stroke_width or 1)
        cairo_stroke(cr)
    else
        cairo_fill(cr)
    end
end

-- Draw a simple rectangle with fill and optional stroke
function cairo_draw_rect(cr, x, y, w, h, fill, stroke, stroke_width)
    if not cr then return end
    cairo_rectangle(cr, x, y, w, h)
    if fill then
        local fr, fg, fb, fa = fill[1] or 0, fill[2] or 0, fill[3] or 0, fill[4] or 1
        cairo_set_source_rgba(cr, fr, fg, fb, fa)
        cairo_fill(cr)
    end
    if stroke then
        local sr, sg, sb, sa = stroke[1] or 1, stroke[2] or 1, stroke[3] or 1, stroke[4] or 1
        cairo_set_source_rgba(cr, sr, sg, sb, sa)
        cairo_set_line_width(cr, stroke_width or 1)
        cairo_stroke(cr)
    end
end

-- Draw text with specified font and color
function cairo_draw_text(cr, x, y, text, font_face, font_size, color, weight)
    if not cr then return end
    cairo_select_font_face(cr, font_face or "Droid Sans", 0, weight or 0)
    cairo_set_font_size(cr, font_size or 12)
    if color then
        local r, g, b, a = color[1] or 0, color[2] or 0, color[3] or 0, color[4] or 1
        cairo_set_source_rgba(cr, r, g, b, a)
    end
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, text)
end

-- Render a simple background line
function conky_render_background()
    -- Create a simple background line that covers the widget width
    return string.rep("█", 60)
end

-- Render a spacer for widget separation
function conky_render_spacer()
    -- Create a spacer line for better widget separation
    return string.rep(" ", 60)
end
