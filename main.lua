-- ~/.conky/main.lua
-- Modified to load main_bars.lua by default
-- This provides a working Conky configuration out of the box

-- Get home directory
local home = os.getenv('HOME') or '/home/alonso'

-- Load the Instrument HUD (Option A) by default
dofile(home .. '/.conky/instrument.lua')
