#!/bin/bash
# Conky startup script with weather initialization

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure weather data exists before starting Conky
if [ ! -f "/tmp/conky_weather.txt" ]; then
    echo "Initializing weather data..."
    "$SCRIPT_DIR/update_weather.sh"
fi

# Start Conky
echo "Starting Conky..."
conky -c "$SCRIPT_DIR/main.lua"
