#!/usr/bin/env bash
# ============================================================================
# install.sh — install the Instrument desktop HUD and its login autostart.
#
# The live desktop HUD is eww (ElKowar's Wacky Widgets), a Wayland layer-shell
# widget. This script installs the eww config into ~/.config/eww, wires up the
# GNOME autostart entry so it launches at login, and (optionally) starts it now.
#
# The legacy Conky Lua widgets in this repo are kept for reference; pass
# --with-conky to also enable the Conky autostart entry.
#
# Usage:
#   ./install.sh                # install eww HUD + login autostart, start now
#   ./install.sh --no-start     # install only, don't launch now
#   ./install.sh --with-conky   # also enable the legacy Conky autostart
#   ./install.sh --check-deps   # only report missing dependencies
#   ./install.sh --help
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EWW_DST="$HOME/.config/eww"
AUTOSTART_DST="$HOME/.config/autostart"

START_NOW=1
WITH_CONKY=0
CHECK_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --no-start)   START_NOW=0 ;;
    --with-conky) WITH_CONKY=1 ;;
    --check-deps) CHECK_ONLY=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//; s/^#//' | head -22
      exit 0 ;;
    *) echo "Unknown option: $arg (see --help)" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
# Maps a command -> a hint of what it powers and a Debian/Arch package name.
check_deps() {
  local missing=0
  # cmd:purpose:apt-pkg:pacman-pkg
  local deps=(
    "eww:the HUD itself:(build from source, see github.com/elkowar/eww):eww"
    "curl:weather + album-art fetch:curl:curl"
    "python3:weather JSON parser:python3:python"
    "playerctl:music (MPRIS) widget:playerctl:playerctl"
    "wpctl:volume/mic (PipeWire):wireplumber:wireplumber"
    "upower:battery widget:upower:upower"
    "ip:network widget:iproute2:iproute2"
  )
  say "Checking dependencies…"
  for d in "${deps[@]}"; do
    IFS=':' read -r cmd purpose apt pac <<< "$d"
    if command -v "$cmd" >/dev/null 2>&1; then
      ok "$cmd — $purpose"
    else
      warn "MISSING: $cmd — needed for $purpose"
      echo "        Debian/Ubuntu: sudo apt install $apt"
      echo "        Arch:          sudo pacman -S $pac"
      missing=1
    fi
  done
  # Fonts used by the HUD (not fatal, but the HUD looks wrong without them).
  # Snapshot fc-list once; grepping the pipe directly trips SIGPIPE under pipefail.
  if command -v fc-list >/dev/null 2>&1; then
    local fonts; fonts="$(fc-list)"
    grep -qi "Fira" <<< "$fonts" || warn "Font 'Fira Sans/Mono' not found (fonts-firacode / ttf-fira-*)."
    grep -qi "Noto Sans Symbols" <<< "$fonts" || warn "Font 'Noto Sans Symbols2' not found (fonts-noto / noto-fonts) — weather glyphs will be blank."
  fi
  return $missing
}

if [ "$CHECK_ONLY" -eq 1 ]; then
  check_deps || true
  exit 0
fi

check_deps || warn "Some dependencies are missing — install them for a fully working HUD."

# ---------------------------------------------------------------------------
# Install eww config
# ---------------------------------------------------------------------------
say "Installing eww config to $EWW_DST"
mkdir -p "$EWW_DST/scripts"
cp "$REPO_DIR/eww/eww.yuck"   "$EWW_DST/eww.yuck"
cp "$REPO_DIR/eww/eww.scss"   "$EWW_DST/eww.scss"
cp "$REPO_DIR/eww/launch.sh"  "$EWW_DST/launch.sh"
cp "$REPO_DIR"/eww/scripts/*  "$EWW_DST/scripts/"
chmod +x "$EWW_DST/launch.sh" "$EWW_DST"/scripts/*
ok "eww config installed"

# The weather widget reads the saved location from ~/.conky/weather_location.conf.
if [ ! -f "$HOME/.conky/weather_location.conf" ]; then
  warn "No ~/.conky/weather_location.conf found — weather will be blank."
  echo "        Edit weather_location.conf in this repo and keep it at ~/.conky/."
fi

# ---------------------------------------------------------------------------
# Login autostart
# ---------------------------------------------------------------------------
say "Installing login autostart entry"
mkdir -p "$AUTOSTART_DST"
cp "$REPO_DIR/autostart/eww-instrument.desktop" "$AUTOSTART_DST/eww-instrument.desktop"
ok "eww HUD will now launch at login"

if [ "$WITH_CONKY" -eq 1 ]; then
  say "Enabling legacy Conky autostart (--with-conky)"
  cat > "$AUTOSTART_DST/conky.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=sh -c 'sleep 6; exec /usr/bin/conky'
Hidden=false
NoDisplay=false
Name=conky
Comment=Conky (legacy Instrument widgets)
X-GNOME-Autostart-enabled=true
EOF
  ok "Conky autostart enabled"
fi

# ---------------------------------------------------------------------------
# Start now
# ---------------------------------------------------------------------------
if [ "$START_NOW" -eq 1 ]; then
  if command -v eww >/dev/null 2>&1; then
    say "Starting the HUD now"
    "$REPO_DIR/start_conky.sh" || warn "Could not start the HUD — check 'eww logs'."
  else
    warn "eww is not installed; skipping start. Install eww, then run ./start_conky.sh"
  fi
fi

echo
ok "Done. The Instrument HUD is installed and will start at login."
echo "   Start/restart manually:  ~/.conky/start_conky.sh"
echo "   View HUD logs:           eww logs"
