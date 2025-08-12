#!/bin/bash
# Manual weather update script for Conky
# This script can be run manually to force a weather update

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Manual weather update for Conky..."
echo "Note: Weather widget now updates automatically every 15-30 minutes"
echo ""

# Run the weather script
"$SCRIPT_DIR/get_weather_accurate.sh"

echo ""
echo "Weather updated at $(date)"
echo "The widget will continue to update automatically."
