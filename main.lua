-- ~/.conky/main.lua
-- Modified to load main_bars.lua by default
-- This provides a working Conky configuration out of the box

-- Get home directory
local home = os.getenv('HOME') or '/home/alonso'

-- Load the working Conky Bars configuration by default
dofile(home .. '/.conky/main_bars.lua')
