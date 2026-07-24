#!/bin/sh
# Launch the eww Instrument HUD (Wayland layer-shell, background layer).
# Runs the daemon in the FOREGROUND via exec so the autostart entry's main
# process stays alive (otherwise the session may reap the backgrounded daemon).
export PATH="$HOME/.local/bin:$PATH"
sleep 4
# open the window shortly after the daemon is ready
( sleep 2; eww open instrument >/dev/null 2>&1 ) &
exec eww daemon --no-daemonize
