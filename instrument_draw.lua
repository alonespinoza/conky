-- Instrument HUD — Cairo drawing module
-- Frameless, corner-pinned system HUD drawn entirely in Cairo.

-- This conky build bundles the Cairo Lua bindings in libcairo.so but does not
-- auto-load them; pull them in so cairo_* / cairo_xlib_* become available.
if not cairo_xlib_surface_create then
  local f = package.loadlib("/usr/lib/conky/libcairo.so", "luaopen_cairo")
  if f then f() end
end

-- Reuse the repo's existing weather fetcher: it fetches on a 15-min throttle
-- and writes /tmp/conky_weather.txt as "location|TEMP°C Condition|icon.png".
pcall(dofile, (os.getenv("HOME") or "") .. "/.conky/sections_bars/weather.lua")

-- rolling history for network sparklines (persists across draw calls)
up_hist = up_hist or {}
dn_hist = dn_hist or {}
local HIST = 48

local C = {
  fg    = {0.914, 0.945, 0.965},
  muted = {0.560, 0.615, 0.670},
  aqua  = {0.373, 0.827, 0.769},
  steel = {0.616, 0.706, 0.753},
  amber = {0.909, 0.698, 0.227},
  track = {1, 1, 1, 0.10},
  shadow= {0, 0, 0},
  panel = {0.043, 0.059, 0.078, 0.74},
}
local FONT = "Fira Sans"
local MONO = "Fira Mono"
local ROUND = (CAIRO_LINE_CAP_ROUND ~= nil) and CAIRO_LINE_CAP_ROUND or 1
local BUTT  = (CAIRO_LINE_CAP_BUTT ~= nil) and CAIRO_LINE_CAP_BUTT or 0

local function num(v, d) return tonumber(v) or d or 0 end
local function pget(s) return conky_parse(s) end
local function set(cr, c, a) cairo_set_source_rgba(cr, c[1], c[2], c[3], a or c[4] or 1) end

-- filled rounded rectangle (background panel, no border)
local function rrect(cr, x, y, w, h, r)
  cairo_new_sub_path(cr)
  cairo_arc(cr, x+w-r, y+r,   r, -math.pi/2, 0)
  cairo_arc(cr, x+w-r, y+h-r, r, 0,          math.pi/2)
  cairo_arc(cr, x+r,   y+h-r, r, math.pi/2,  math.pi)
  cairo_arc(cr, x+r,   y+r,   r, math.pi,    3*math.pi/2)
  cairo_close_path(cr)
end

-- text with a soft drop-shadow so it stays legible on any wallpaper (no frame)
local function text(cr, s, x, y, size, col, align, font, bold)
  cairo_select_font_face(cr, font or FONT, 0, bold and 1 or 0)
  cairo_set_font_size(cr, size)
  local e = cairo_text_extents_t:create()
  cairo_text_extents(cr, s, e)
  local tx = x
  if align == "center" then tx = x - e.width/2 - e.x_bearing
  elseif align == "right" then tx = x - e.width - e.x_bearing end
  set(cr, C.shadow, 0.55)
  cairo_move_to(cr, tx+1, y+1); cairo_show_text(cr, s)
  set(cr, col)
  cairo_move_to(cr, tx, y); cairo_show_text(cr, s)
  return e.width
end

local function ring(cr, cx, cy, r, lw, pct, col)
  pct = math.max(0, math.min(100, pct))
  cairo_set_line_width(cr, lw)
  cairo_set_line_cap(cr, BUTT)
  set(cr, C.track)
  cairo_arc(cr, cx, cy, r, 0, 2*math.pi); cairo_stroke(cr)
  if pct > 0 then
    set(cr, col)
    cairo_set_line_cap(cr, ROUND)
    local a0 = -math.pi/2
    cairo_arc(cr, cx, cy, r, a0, a0 + (pct/100)*2*math.pi); cairo_stroke(cr)
    cairo_set_line_cap(cr, BUTT)
  end
end

local function spark(cr, x, y, w, h, hist, col)
  local n = #hist
  if n < 2 then return end
  local mx = 1
  for i = 1, n do if hist[i] > mx then mx = hist[i] end end
  cairo_set_line_width(cr, 1.8)
  cairo_set_line_cap(cr, ROUND)
  set(cr, col)
  for i = 1, n do
    local px = x + w * (i-1) / (HIST-1)
    local py = y + h - (hist[i]/mx) * h
    if i == 1 then cairo_move_to(cr, px, py) else cairo_line_to(cr, px, py) end
  end
  cairo_stroke(cr)
  local ex = x + w * (n-1) / (HIST-1)
  local ey = y + h - (hist[n]/mx) * h
  cairo_arc(cr, ex, ey, 2.4, 0, 2*math.pi); cairo_fill(cr)
  cairo_set_line_cap(cr, BUTT)
end

local function meter(cr, x, y, w, pct, col)
  pct = math.max(0, math.min(100, pct))
  cairo_set_line_width(cr, 5)
  cairo_set_line_cap(cr, ROUND)
  set(cr, C.track)
  cairo_move_to(cr, x, y); cairo_line_to(cr, x+w, y); cairo_stroke(cr)
  if pct > 0 then
    set(cr, col or C.aqua)
    cairo_move_to(cr, x, y); cairo_line_to(cr, x + w*pct/100, y); cairo_stroke(cr)
  end
  cairo_set_line_cap(cr, BUTT)
end

-- linear interpolation helpers (for the waveform gradient)
local function lerp(a, b, t) return a + (b - a) * t end
local function lerp_col(c1, c2, t)
  return { lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t), lerp(c1[3], c2[3], t) }
end

-- deterministic pseudo-waveform amplitude for bar i, in [0.28, 1.0].
-- three detuned sines summed so it reads like an organic soundwave but stays
-- stable frame to frame (no jitter at conky's 1 Hz redraw).
local function wave_amp(i)
  local t = i * 0.45
  local combined = (0.30 * math.sin(t)
    + 0.20 * math.sin(t * 0.5 + 1.3)
    + 0.14 * math.sin(t * 1.7 + 0.6)) / 0.64      -- normalize into [-1, 1]
  return 0.28 + 0.36 * (1 + combined)             -- -> [0.28, 1.0]
end

-- waveform seek bar: vertical bars, played portion lit with a colA->colB
-- gradient, unplayed portion in the dim track colour, plus a glowing playhead.
local function wavebar(cr, x, y, w, h, pct, colA, colB)
  pct = math.max(0, math.min(100, pct)) / 100
  local bw, gap = 2.5, 2.5
  local step = bw + gap
  local n = math.floor(w / step)
  if n < 1 then return end
  local play_x = x + w * pct
  local cym = y + h / 2
  cairo_set_line_cap(cr, ROUND)
  cairo_set_line_width(cr, bw)
  for i = 0, n - 1 do
    local bx = x + i * step + bw / 2
    local bh = h * wave_amp(i)
    if play_x - bx > 0.01 then                    -- bar is behind the playhead
      local t = (bx - x) / math.max(1, play_x - x)
      set(cr, lerp_col(colA, colB, t), 0.95)
    else
      set(cr, C.track)
    end
    cairo_move_to(cr, bx, cym - bh / 2)
    cairo_line_to(cr, bx, cym + bh / 2)
    cairo_stroke(cr)
  end
  cairo_set_line_cap(cr, BUTT)
  -- glowing playhead: soft halo -> bright white core
  set(cr, colB, 0.18); cairo_arc(cr, play_x, cym, 6.5, 0, 2 * math.pi); cairo_fill(cr)
  set(cr, colB, 0.38); cairo_arc(cr, play_x, cym, 4.0, 0, 2 * math.pi); cairo_fill(cr)
  set(cr, C.fg, 1.0);  cairo_arc(cr, play_x, cym, 2.1, 0, 2 * math.pi); cairo_fill(cr)
end

local function fmt_speed(kib)
  if kib >= 1024 then return string.format("%.1f", kib/1024), "MB/s"
  else return string.format("%.0f", kib), "KB/s" end
end

-- robust active-interface detection (follows the default route; cached 20s)
local net_iface, net_iface_t = nil, -100
local function active_iface()
  local now = os.time()
  if net_iface and (now - net_iface_t) < 20 then return net_iface end
  -- ${gw_iface} is unreliable here (returns "multiple"/"(null)" with 2 default
  -- routes), so read the default route directly, taking the lowest-metric iface.
  local gi = ""
  local p = io.popen("ip route show default 2>/dev/null | awk '/^default/{print $5; exit}'")
  if p then gi = (p:read("*l") or ""):gsub("%s+", ""); p:close() end
  if gi ~= "" then net_iface = gi; net_iface_t = now end
  return net_iface or ""
end

local function load_weather()
  if conky_weather_display then pcall(conky_weather_display) end
  local f = io.open("/tmp/conky_weather.txt", "r")
  if not f then return end
  local line = f:read("*l") or ""; f:close()
  local loc, cond = line:match("^(.-)|(.-)|")
  if not cond then return end
  local t = cond:match("(%-?%d+)%s*°")
  local word = cond:match("°%s*C?%s*(.+)$")
  if t then WEATHER_TEMP = t .. "°" end
  if word and word ~= "" then
    local city = (loc or ""):match("^([^,]+)")
    WEATHER_DESC = word:upper() .. (city and (" · " .. city:upper()) or "")
  end
end

local function fmt_time(us)
  local s = math.floor((tonumber(us) or 0) / 1000000)
  return string.format("%d:%02d", math.floor(s/60), s % 60)
end

-- now-playing via playerctl (MPRIS: Spotify, browsers, etc.)
-- When conky is launched from XDG autostart at login, DBUS_SESSION_BUS_ADDRESS
-- is often missing from its environment, so playerctl can't reach the MPRIS bus
-- and always reports "Nothing playing". Set it explicitly from XDG_RUNTIME_DIR
-- (falling back to /run/user/<uid>) so the query works regardless of launch env.
local function dbus_prefix()
  if os.getenv("DBUS_SESSION_BUS_ADDRESS") then return "" end
  local run = os.getenv("XDG_RUNTIME_DIR")
  if not run or run == "" then
    local uid = io.popen("id -u 2>/dev/null")
    local u = uid and uid:read("*l") or nil
    if uid then uid:close() end
    if u and u ~= "" then run = "/run/user/" .. u end
  end
  if not run or run == "" then return "" end
  return "DBUS_SESSION_BUS_ADDRESS=unix:path=" .. run .. "/bus "
end

local function read_music()
  local p = io.popen(dbus_prefix() .. "playerctl metadata --format "
    .. "'{{status}}|{{artist}}|{{title}}|{{position}}|{{mpris:length}}' 2>/dev/null")
  if not p then return nil end
  local line = p:read("*l"); p:close()
  if not line or line == "" then return nil end
  local st, ar, ti, pos, len = line:match("^(.-)|(.-)|(.-)|(.-)|(.-)$")
  return { status = st, artist = ar, title = ti,
           pos = tonumber(pos) or 0, len = tonumber(len) or 0 }
end

local function ellipsize(cr, s, maxw, size, font)
  cairo_select_font_face(cr, font or FONT, 0, 0)
  cairo_set_font_size(cr, size)
  local e = cairo_text_extents_t:create()
  cairo_text_extents(cr, s, e)
  if e.width <= maxw then return s end
  while #s > 1 do
    s = s:sub(1, #s - 1)
    cairo_text_extents(cr, s .. "..", e)
    if e.width <= maxw then return s .. ".." end
  end
  return s
end

function conky_hud()
  if conky_window == nil then return end
  load_weather()
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
    conky_window.visual, conky_window.width, conky_window.height)
  if not cs then return end
  local cr = cairo_create(cs)
  if not cr then cairo_surface_destroy(cs); return end

  local W = conky_window.width
  local H = conky_window.height
  local pad = 22

  -- background panel (frameless: fill only, no border stroke)
  rrect(cr, 0, 0, W, H, 18)
  set(cr, C.panel); cairo_fill(cr)

  -- data
  local cpu  = num(pget("${cpu cpu0}"))
  local mem  = num(pget("${memperc}"))
  local temp = num(pget("${acpitemp}"))
  local iface = active_iface()
  local up, dn = 0, 0
  if iface ~= "" then
    up = num(pget("${upspeedf "   .. iface .. "}"))
    dn = num(pget("${downspeedf " .. iface .. "}"))
  end
  table.insert(up_hist, up); if #up_hist > HIST then table.remove(up_hist, 1) end
  table.insert(dn_hist, dn); if #dn_hist > HIST then table.remove(dn_hist, 1) end
  local root = num(pget("${fs_used_perc /}"))
  local hom  = num(pget("${fs_used_perc /home}"))
  local batt = num(pget("${battery_percent}"))
  local uptime = (pget("${uptime_short}") or ""):gsub("%s+$", "")

  -- ---- header: clock + weather ----
  local cw = text(cr, pget("${time %H:%M}"), pad, 60, 40, C.fg, "left", MONO)
  text(cr, pget("${time %S}"), pad + cw + 8, 60, 16, C.aqua, "left", MONO)
  text(cr, WEATHER_TEMP or "--°", W-pad, 50, 24, C.fg, "right", FONT, true)
  text(cr, (pget("${time %a %d %b}") or ""):upper(), pad, 84, 11, C.muted, "left", FONT)
  text(cr, WEATHER_DESC or "", W-pad, 84, 11, C.muted, "right", FONT)

  -- ---- rings ----
  local cy, r, lw = 158, 36, 7
  local cxs = { pad+52, W/2, W-pad-52 }
  ring(cr, cxs[1], cy, r, lw, cpu,  C.aqua)
  ring(cr, cxs[2], cy, r, lw, mem,  C.steel)
  ring(cr, cxs[3], cy, r, lw, temp, C.amber)
  text(cr, string.format("%.0f", cpu).."%",  cxs[1], cy+7, 19, C.fg, "center", MONO)
  text(cr, string.format("%.0f", mem).."%",  cxs[2], cy+7, 19, C.fg, "center", MONO)
  text(cr, string.format("%.0f", temp).."°", cxs[3], cy+7, 19, C.fg, "center", MONO)
  text(cr, "CPU",  cxs[1], cy+r+22, 10, C.muted, "center", FONT)
  text(cr, "RAM",  cxs[2], cy+r+22, 10, C.muted, "center", FONT)
  text(cr, "TEMP", cxs[3], cy+r+22, 10, C.muted, "center", FONT)

  -- ---- network ----
  text(cr, "NET", pad, 246, 10, C.muted, "left", FONT)
  text(cr, iface ~= "" and iface or "—", W-pad, 246, 10, C.muted, "right", MONO)
  local uv, uu = fmt_speed(up)
  local dv, du = fmt_speed(dn)
  local sx = pad+24
  local sw = (W-pad-98) - sx
  text(cr, "↑", pad, 274, 13, C.aqua, "left", FONT)
  spark(cr, sx, 260, sw, 18, up_hist, C.aqua)
  text(cr, uv, W-pad-32, 274, 13, C.fg, "right", MONO)
  text(cr, uu, W-pad, 274, 9.5, C.muted, "right", FONT)
  text(cr, "↓", pad, 300, 13, C.steel, "left", FONT)
  spark(cr, sx, 286, sw, 18, dn_hist, C.steel)
  text(cr, dv, W-pad-32, 300, 13, C.fg, "right", MONO)
  text(cr, du, W-pad, 300, 9.5, C.muted, "right", FONT)

  -- ---- disks ----
  local mx0 = pad+22
  local mw  = (W-pad-52) - mx0
  text(cr, "/", pad, 338, 12, C.muted, "left", MONO)
  meter(cr, mx0, 334, mw, root)
  text(cr, string.format("%.0f%%", root), W-pad, 338, 12, C.fg, "right", MONO)
  text(cr, "~", pad, 366, 12, C.muted, "left", MONO)
  meter(cr, mx0, 362, mw, hom)
  text(cr, string.format("%.0f%%", hom), W-pad, 366, 12, C.fg, "right", MONO)

  -- ---- footer ----
  text(cr, "up " .. uptime, pad, 400, 12, C.muted, "left", FONT)
  text(cr, string.format("%.0f%%", batt), W-pad, 400, 12, C.amber, "right", MONO)

  -- ---- music (playerctl / MPRIS) ----
  local m = read_music()
  text(cr, "NOW PLAYING", pad, 434, 9.5, C.muted, "left", FONT)
  if m and m.title and m.title ~= "" then
    -- play/pause indicator drawn in Cairo (font-safe, no tofu glyphs)
    local iy = 430
    if m.status == "Playing" then
      set(cr, C.aqua)
      cairo_move_to(cr, W-pad-8, iy-5); cairo_line_to(cr, W-pad-8, iy+5)
      cairo_line_to(cr, W-pad, iy); cairo_close_path(cr); cairo_fill(cr)
    else
      set(cr, C.muted)
      cairo_rectangle(cr, W-pad-8, iy-5, 3, 10)
      cairo_rectangle(cr, W-pad-3, iy-5, 3, 10); cairo_fill(cr)
    end
    text(cr, ellipsize(cr, m.title, W-2*pad, 13.5, FONT), pad, 456, 13.5, C.fg, "left", FONT)
    if m.artist and m.artist ~= "" then
      text(cr, ellipsize(cr, m.artist, W-2*pad-72, 10, FONT), pad, 474, 10, C.muted, "left", FONT)
    end
    if m.len and m.len > 0 then
      text(cr, fmt_time(m.pos) .. " / " .. fmt_time(m.len), W-pad, 474, 9.5, C.muted, "right", MONO)
      wavebar(cr, pad, 483, W-2*pad, 16, m.pos / m.len * 100, C.steel, C.aqua)
    end
  else
    text(cr, "Nothing playing", pad, 456, 11, C.muted, "left", FONT)
  end

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
