# Release Notes

## v2.0.1 — Battery icon fill fix — 2026-07-24

### Fixed
- **Battery icon now fills completely at 100%.** The fill width was computed as
  `pct * 0.16` (max 16px), but the icon body's content area is 22px wide in GTK
  (padding and border sit *outside* `min-width`, not inside it), so a
  fully-charged battery only filled ~73% of the icon. The multiplier is now
  `0.22`, so 100% maps to the full 22px. (`eww/eww.yuck`)

---

## v2.0.0 — Instrument HUD (eww) — 2026-07-24

The desktop HUD moves from Conky to **eww** (Wayland layer-shell), and the whole
setup becomes reproducible from a single script.

### Added
- **`eww/` — the live HUD, now version-controlled.** `eww.yuck` (layout),
  `eww.scss` (styling), `launch.sh` (daemon launcher), and `scripts/` (per-widget
  JSON providers: `temp`, `uptime`, `audio`, `battery`, `disks`, `net`,
  `weather`, `music`, `wxparse.py`). Previously these lived only in
  `~/.config/eww/` and were not backed up anywhere.
- **`install.sh`** — one-shot installer that checks dependencies, copies the eww
  config into `~/.config/eww/`, installs the **login autostart** entry, and
  starts the HUD. Flags: `--check-deps`, `--no-start`, `--with-conky`, `--help`.
- **`autostart/eww-instrument.desktop`** — the GNOME autostart entry, so the HUD
  launches at login.
- **`.gitignore`** — keeps runtime logs, editor backups, scratch files, and AI
  tooling state (`.omc/`, `.claude/`) out of the repo.

### Changed
- **`start_conky.sh`** now stops stray Conky processes and cleanly (re)starts the
  eww HUD instead of the old Conky version selector.
- **README** rewritten around the eww HUD, with dependency table (per distro),
  file map, widget overview, and weather-location config. Conky is documented as
  the legacy variant.

### Removed / cleaned
- Deleted runtime and scratch artifacts that had been committed or left lying
  around: `conky_output.log` (3.8 MB), `conky_cal.log`, `conky_circles.log`,
  `main_bars.lua.backup`, `wx_now_1.png`, `simple_cairo_test.lua`,
  `cairo_rectangle.lua`.

### Notes
- The Conky Lua widgets (`main*.lua`, `sections*/`, `instrument*.lua`) remain in
  the repo for reference but are no longer what runs on the desktop.
- Data scripts export `LC_NUMERIC=C` so decimals stay JSON-valid under locales
  like `es_CR` (a `,` decimal would blank the affected widget).

---

## v1.x — Conky (legacy)

- Dual Conky version system (bars + development slate).
- Weather widget with IP geolocation and multiple provider fallbacks.
- MPRIS music widget that auto-hides when nothing is playing.
- Nord-inspired palette, progress-bar system widgets.
