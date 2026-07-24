-- Calendar Configuration for Conky
-- Dynamic calendar display with proper weekday alignment

conky.config = {
    -- Calendar window settings
    background = false,
    update_interval = 30,
    total_run_times = 0,

    -- Window positioning (centered)
    alignment = 'top_middle',
    gap_x = 0,
    gap_y = 80,

    -- Window appearance
    own_window = true,
    own_window_type = 'normal',
    own_window_transparent = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    own_window_argb_value = 0,

    -- Text settings
    use_xft = true,
    font = 'Liberation Sans:size=9:style=Bold',
    xftalpha = 0.8,

    -- Size settings
    minimum_width = 800,
    minimum_height = 200,

    -- Lua script loading
    lua_load = 'calendar/calendar_dynamic.lua',

    -- Additional settings
    double_buffer = true,
    no_buffers = true,
    override_utf8_locale = true,
    uppercase = false,
    text_buffer_size = 2048,
    imlib_cache_size = 0
}

-- Calendar display text - dynamic Lua-based formatting
conky.text = [[
${color #72A4DB}${font DejaVu Sans:bold:size=18}${time %A}${font}
${color #72A4DB}${font DejaVu Sans:bold:size=24}${time %b}${font}
${color #72A4DB}${font DejaVu Sans:bold:size=16}${time %Y}${color}
${voffset -64}${goto 140}${font DejaVu Sans:bold:size=40}${time %d}${color}

${voffset -120}${goto 200}${font mono:Bold:size=10}${lua conky_weekday_headers}
${voffset -100}${goto 200}${font mono:bold:size=10}${lua conky_calendar_numbers}
]]
