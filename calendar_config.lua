-- Calendar Configuration for Conky
-- This file provides a centered, well-formatted calendar display

conky.config = {
    -- Calendar window settings
    background = false,
    update_interval = 30,
    total_run_times = 0,

    -- Window positioning (centered)
    alignment = 'top_middle',
    gap_x = 0,
    gap_y = 20,

    -- Window appearance
    own_window = true,
    own_window_type = 'normal',
    own_window_transparent = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    own_window_argb_value = 0,

    -- Text settings
    use_xft = true,
    font = 'DejaVu Sans:size=10',
    xftalpha = 0.8,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,
    border_inner_margin = 0,
    border_outer_margin = 0,

    -- Size settings
    minimum_width = 600,
    minimum_height = 120,
    maximum_width = 600,

    -- Additional settings
    double_buffer = true,
    no_buffers = true,
    override_utf8_locale = true,
    uppercase = false,
    text_buffer_size = 2048,
    imlib_cache_size = 0
}

-- Calendar display text
conky.text = [[
${voffset 5}${font DejaVu Sans:size=12}${alignc}${time %B %Y}${font}
${voffset 5}${font DejaVu Sans:size=10}${alignc}Su  Mo  Tu  We  Th  Fr  Sa${font}
${voffset 5}${font DejaVu Sans:size=10}${alignc}${execpi 36000 /home/alonso/.conky/calendar/horical_fixed.sh}${font}
${voffset 5}${hr 1}
${voffset 5}${font DejaVu Sans:size=14}${alignc}${time %A, %B %d}${font}
${voffset 5}${font DejaVu Sans:size=12}${alignc}${time %H:%M:%S}${font}
]]
