-- ~/.conky/main_bars.lua
-- Main Conky configuration file

-- Get home directory
local home = os.getenv('HOME') or '/home/alonso'

-- Main Conky configuration
conky.config = {
    -- Basic settings
    update_interval = 1,
    total_run_times = 0,

    -- Window settings
    own_window = true,
    own_window_type = 'normal',
    own_window_hints = 'undecorated,below,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    own_window_argb_value = 192,

    -- Position and size
    alignment = 'top_left',
    gap_x = 0,
    gap_y = 0,

    -- Appearance
    background = false,
    border_width = 0,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,

    -- Anti-flicker settings
    double_buffer = true,
    no_buffers = true,
    text_buffer_size = 2048,

    -- Fonts and colors
    use_xft = true,
    font = 'Droid Sans:size=10',

    -- Lua settings - load all sections in one statement
    lua_load = home .. '/.conky/sections_bars/common_draw.lua ' ..
        home .. '/.conky/sections_bars/temperature.lua ' ..
        home .. '/.conky/sections_bars/network.lua ' ..
        home .. '/.conky/sections_bars/filesystem.lua ' ..
        home .. '/.conky/sections_bars/system.lua ' ..
        home .. '/.conky/sections_bars/weather.lua ' ..
        home .. '/.conky/sections_bars/music.lua ' ..
        home .. '/.conky/sections_bars/processes.lua',
}

-- Main text display with different update intervals
conky.text = [[
        ${lua_parse system_display}
        ${lua_parse filesystem_display}
        # ${lua_parse temperature_display}
        ${lua_parse processes_display}
        ${lua_parse network_display}
        ${lua_parse weather_display}
        ${lua_parse music_display}
        # ${lua_parse date_time_display}
]]
