# Instrument — desktop HUD

A minimal, transparent desktop HUD that floats over the wallpaper: clock,
weather, network spectrum, system rings, disks, battery, audio, and now-playing
music.

> **The live HUD is [eww](https://github.com/elkowar/eww)** (ElKowar's Wacky
> Widgets, a Wayland layer-shell widget), configured under `eww/` in this repo
> and installed to `~/.config/eww/`.
>
> The **Conky** Lua files (`main*.lua`, `sections*/`, `instrument*.lua`, …) are
> the earlier variant, kept for reference. They are not what runs on the desktop.

## Quick start

```bash
git clone git@github.com:alonespinoza/conky.git ~/.conky
cd ~/.conky
./install.sh
```

`install.sh` will:

1. Check dependencies and tell you what's missing (per distro).
2. Copy the eww config into `~/.config/eww/`.
3. Install the **login autostart** entry (`~/.config/autostart/eww-instrument.desktop`).
4. Start the HUD immediately.

Useful flags:

| Flag | Effect |
|------|--------|
| `./install.sh --check-deps` | Only report missing dependencies, install nothing. |
| `./install.sh --no-start`   | Install + enable autostart, but don't launch now. |
| `./install.sh --with-conky` | Also enable the legacy Conky autostart entry. |
| `./install.sh --help`       | Show usage. |

Start / restart the HUD manually at any time:

```bash
./start_conky.sh     # stops stray conky, restarts eww cleanly
eww logs             # view HUD logs if something looks wrong
```

## Dependencies

| Tool | Powers | Debian/Ubuntu | Arch |
|------|--------|---------------|------|
| `eww` | the HUD itself | build from source | `eww` |
| `curl` | weather + album art | `curl` | `curl` |
| `python3` | weather JSON parser | `python3` | `python` |
| `playerctl` | music (MPRIS) widget | `playerctl` | `playerctl` |
| `wpctl` | volume / mic (PipeWire) | `wireplumber` | `wireplumber` |
| `upower` | battery widget | `upower` | `upower` |
| `ip` | network widget | `iproute2` | `iproute2` |

Fonts: **Fira Sans**, **Fira Mono**, and **Noto Sans Symbols2** (weather glyphs).

## File structure

```
~/.conky/
├── install.sh                # installer + login autostart setup
├── start_conky.sh            # stop conky, (re)start the eww HUD
├── weather_location.conf     # lat/lon/name used by the weather widget
│
├── eww/                      # ── the live HUD (→ ~/.config/eww/) ──
│   ├── eww.yuck              # widget tree / layout
│   ├── eww.scss              # styling (transparent cards, Nord-ish palette)
│   ├── launch.sh             # daemon launcher (Wayland layer-shell)
│   └── scripts/              # data providers, each emits JSON
│       ├── temp   uptime   audio   battery
│       ├── disks  net      weather music
│       └── wxparse.py       # Open-Meteo JSON → HUD JSON
│
├── autostart/
│   └── eww-instrument.desktop   # login autostart (→ ~/.config/autostart/)
│
└── (legacy Conky) main*.lua, .conkyrc, sections/, sections_bars/,
    sections_circles/, instrument*.lua, images/, weather/, get_weather_*.sh
```

## The widgets

- **Clock + weather** — big hero value with a muted meta line; 3-day forecast
  strip (Open-Meteo, no API key, cached 15 min).
- **Network spectrum** — mirrored up/down bar spectrum on a log scale (idle ~2px,
  ~1 MB/s ~15px, ≥25 MB/s full).
- **System rings** — circular-progress gauges.
- **Disks / battery / audio** — usage, charge state + time, PipeWire volume/mic.
- **Music** — MPRIS now-playing with local album-art resolution; hides when idle.

### Weather location

Edit `weather_location.conf` (kept at `~/.conky/weather_location.conf`):

```ini
WEATHER_LAT="9.974361"
WEATHER_LON="-84.1395831"
WEATHER_NAME="Barreal, Heredia, Costa Rica"
```

## Notes on locale

Several data scripts export `LC_NUMERIC=C` so `awk`/`printf`/`python` emit `.`
decimal separators. Under locales like `es_CR` a `,` would produce invalid JSON
and the affected widget would silently blank out.

## License

MIT.
