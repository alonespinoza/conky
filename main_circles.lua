-- Main Conky configuration for Circles version
-- This version uses Cairo for circular progress bars and graphics

-- Get home directory
local home = os.getenv("HOME")

conky.config = {
    -- Basic window settings
    background = false,
    update_interval = 1,

    -- Window positioning
    alignment = 'top_right',
    gap_x = 50,
    gap_y = 20,
    minimum_width = 450,
    minimum_height = 600,

    -- Window appearance
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,

    -- Text settings
    draw_shades = false,
    draw_outline = false,

    -- Cairo drawing
    lua_load = home .. '/.conky/sections_circles/simple_common.lua',
    lua_draw_hook_pre = 'conky_cairo_pre',

    -- Additional settings for better Cairo support
    double_buffer = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_class = 'Conky',
    own_window_title = 'Conky Circles'
}

-- Main display text - minimal since we're using Cairo for graphics
conky.text = [[]]
