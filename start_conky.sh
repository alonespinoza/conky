#!/bin/bash
# Desktop HUD startup script
# NOTE: The live desktop HUD is eww (ElKowar's Wacky Widgets), not conky.
# The old ~/.conky/*.lua conky widgets are an unused legacy variant.
# This mirrors the login autostart chain (~/.config/autostart/eww-instrument.desktop).

# Stop any leftover conky processes from the old setup
pkill conky 2>/dev/null

# Restart eww cleanly so this script is safe to re-run
eww kill 2>/dev/null

# Launch the eww HUD detached so it survives the launching shell exiting
setsid ~/.config/eww/launch.sh >/dev/null 2>&1 < /dev/null &

echo "eww HUD (Instrument) started."
