#!/usr/bin/env python3
# Parse Open-Meteo JSON (stdin) -> compact HUD JSON with current conditions
# plus a 3-day forecast. WMO weather_code -> label + monochrome glyph
# (rendered with Noto Sans Symbols2 in the HUD). ensure_ascii=False keeps the
# real glyph; output goes to a cache file read by the yuck (non-ASCII OK there).
import sys, json, datetime

name = sys.argv[1] if len(sys.argv) > 1 else ""

def glyph(c):
    if c in (0, 1): return ("CLEAR", "☀")           # sun
    if c == 2: return ("PARTLY CLOUDY", "☁")        # cloud
    if c == 3: return ("OVERCAST", "☁")
    if c in (45, 48): return ("FOG", "☁")
    if c in (51, 53, 55, 56, 57): return ("DRIZZLE", "☔")   # umbrella w/ rain
    if c in (61, 63, 65, 66, 67, 80, 81, 82): return ("RAIN", "☔")
    if c in (71, 73, 75, 77, 85, 86): return ("SNOW", "❄")  # snowflake
    if c in (95, 96, 99): return ("STORM", "⚡")            # bolt
    return ("", "☁")

data = json.load(sys.stdin)
cur = data.get("current", {})
temp = cur.get("temperature_2m", 0.0)
cond, ic = glyph(cur.get("weather_code", 0))
city = name.split(",")[0].upper()

d = data.get("daily", {})
times, codes = d.get("time", []), d.get("weather_code", [])
his, los = d.get("temperature_2m_max", []), d.get("temperature_2m_min", [])
days = []
for i in range(min(3, len(times))):
    dt = datetime.date.fromisoformat(times[i])
    lbl = "TODAY" if i == 0 else dt.strftime("%a").upper()
    _, dic = glyph(codes[i] if i < len(codes) else 0)
    days.append({
        "d": lbl, "ic": dic,
        "hi": "%.0f" % (his[i] if i < len(his) else 0),
        "lo": "%.0f" % (los[i] if i < len(los) else 0),
    })

out = {
    "temp": "%.0f°" % temp,
    "icon": ic,
    "desc": "%s · %s" % (cond, city),
    "days": days,
}
print(json.dumps(out, ensure_ascii=False))
