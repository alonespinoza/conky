-- ~/.conky/main.lua
-- New Conky configuration (to be built)
-- This is the new version that will be different from conky_bars

-- Get home directory
local home = os.getenv('HOME') or '/home/alonso'

-- Basic Conky configuration
conky.config = {
    -- Window settings
    own_window = true,
    own_window_type = 'normal',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 192, -- 25% transparency
    
    -- Position and size
    alignment = 'top_right',
    gap_x = 50,
    gap_y = 50,
    minimum_width = 300,
    minimum_height = 400,
    
    -- Appearance
    background = false,
    border_width = 0,
    draw_borders = false,
    draw_graph_borders = false,
    draw_outline = false,
    draw_shades = false,
    
    -- Fonts
    use_xft = true,
    font = 'Droid Sans:size=10',
    
    -- Colors
    default_color = '#D8DEE9',
    color1 = '#88C0D0',
    color2 = '#8FBCBB',
    color3 = '#81A1C1',
    color4 = '#5E81AC',
    
    -- Update settings
    update_interval = 1,
    double_buffer = true,
    no_buffers = true,
    text_buffer_size = 2048,
    
    -- Lua settings
    lua_load = {
        home .. '/.conky/sections/common.lua',
        home .. '/.conky/sections/system.lua',
        home .. '/.conky/sections/weather.lua',
        home .. '/.conky/sections/music.lua'
    }
}

-- Main display text
conky.text = [[
${lua_parse system_display}
${lua_parse weather_display}
${lua_parse music_display}
]]
