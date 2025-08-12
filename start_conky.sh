#!/bin/bash
# Conky Startup Script - Choose between different versions

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to show menu
show_menu() {
    echo "=== Conky Version Selector ==="
    echo ""
    echo "Choose which Conky version to start:"
    echo "1. Conky Bars (Original version with widgets)"
    echo "2. New Version (Clean slate - to be built)"
    echo "3. Stop all Conky instances"
    echo "4. Exit"
    echo ""
}

# Function to start conky_bars
start_conky_bars() {
    echo "Starting Conky Bars version..."
    
    # Ensure weather data exists before starting
    if [ ! -f "/tmp/conky_weather.txt" ]; then
        echo "Initializing weather data..."
        "$SCRIPT_DIR/update_weather.sh"
    fi
    
    # Start Conky with bars configuration
    conky -c "$SCRIPT_DIR/main_bars.lua"
    echo "Conky Bars started!"
}

# Function to start new version
start_new_version() {
    echo "Starting New Conky version..."
    
    # Start Conky with new configuration
    conky -c "$SCRIPT_DIR/main.lua"
    echo "New Conky version started!"
}

# Function to stop all Conky instances
stop_conky() {
    echo "Stopping all Conky instances..."
    pkill conky
    echo "All Conky instances stopped!"
}

# Function to check if Conky is running
check_conky_status() {
    if pgrep conky > /dev/null; then
        echo "Conky is currently running."
        ps aux | grep conky | grep -v grep
    else
        echo "No Conky instances are currently running."
    fi
}

# Main script logic
while true; do
    show_menu
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            stop_conky
            sleep 1
            start_conky_bars
            ;;
        2)
            stop_conky
            sleep 1
            start_new_version
            ;;
        3)
            stop_conky
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1-4."
            ;;
    esac
    
    echo ""
    echo "Current Conky status:"
    check_conky_status
    echo ""
    
    read -p "Press Enter to continue..."
    clear
done
