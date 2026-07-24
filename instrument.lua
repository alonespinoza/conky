-- Instrument HUD — conky config (Option A)
-- Corner-pinned translucent system HUD, drawn entirely in Cairo.

local home = os.getenv("HOME")

conky.config = {
    background = false,
    update_interval = 1,
    total_run_times = 0,

    -- position: top-right corner overlay
    alignment = 'top_left',
    gap_x = 28,
    gap_y = 48,
    minimum_width = 380,
    maximum_width = 380,
    minimum_height = 505,

    -- transparent window; the panel is painted by Cairo
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_class = 'Conky',
    own_window_title = 'conky-instrument',

    double_buffer = true,
    no_buffers = true,
    imlib_cache_size = 0,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,

    -- Cairo draw hook (conky prepends "conky_" -> conky_hud)
    lua_load = home .. '/.conky/instrument_draw.lua',
    lua_draw_hook_pre = 'hud',
}

conky.text = [[]]
