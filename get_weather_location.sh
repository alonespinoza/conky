#!/bin/bash
# Get weather for user-specified location or allow manual location setting
# Using OpenWeatherMap API

API_KEY="e46d6b1c945f2e9983f0735f8928ea2f"
WEATHER_FILE="/tmp/conky_weather.txt"
LOCATION_CONFIG="$HOME/.conky/weather_location.conf"

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$LOCATION_CONFIG")"

# Function to get location from config file
get_location_from_config() {
    if [[ -f "$LOCATION_CONFIG" ]]; then
        source "$LOCATION_CONFIG"
        if [[ -n "$WEATHER_LAT" && -n "$WEATHER_LON" && -n "$WEATHER_NAME" ]]; then
            echo "Using saved location: $WEATHER_NAME"
            return 0
        fi
    fi
    return 1
}

# Function to save location to config
save_location() {
    local lat="$1"
    local lon="$2"
    local name="$3"
    
    cat > "$LOCATION_CONFIG" << EOF
# Weather location configuration
WEATHER_LAT="$lat"
WEATHER_LON="$lon"
WEATHER_NAME="$name"
EOF
    
    echo "Location saved to: $LOCATION_CONFIG"
}

# Function to search for city coordinates
search_city() {
    local city="$1"
    echo "Searching for coordinates of: $city"
    
    # Use OpenWeatherMap Geocoding API to find city coordinates
    local search_result=$(curl -s "http://api.openweathermap.org/geo/1.0/direct?q=${city}&limit=1&appid=${API_KEY}")
    
    local lat=$(echo "$search_result" | jq -r '.[0].lat // "null"')
    local lon=$(echo "$search_result" | jq -r '.[0].lon // "null"')
    local found_name=$(echo "$search_result" | jq -r '.[0].name // "null"')
    local country=$(echo "$search_result" | jq -r '.[0].country // "null"')
    
    if [[ "$lat" != "null" && "$lon" != "null" ]]; then
        local full_name="${found_name}, ${country}"
        echo "Found: $full_name at coordinates $lat, $lon"
        save_location "$lat" "$lon" "$full_name"
        return 0
    else
        echo "City not found. Please check the spelling or try a different city."
        return 1
    fi
}

# Function to set location manually
set_location_manual() {
    echo "Enter your location details:"
    echo "1. City name (e.g., 'San Jose, Costa Rica')"
    echo "2. Or specific coordinates (e.g., '9.9985,-84.1165')"
    echo "3. Or use current IP location (may not be accurate)"
    echo ""
    read -p "Enter your choice (1/2/3): " choice
    
    case $choice in
        1)
            read -p "Enter city name: " city
            search_city "$city"
            ;;
        2)
            read -p "Enter coordinates (lat,lon): " coords
            read -p "Enter location name: " name
            local lat=$(echo "$coords" | cut -d',' -f1 | tr -d ' ')
            local lon=$(echo "$coords" | cut -d',' -f2 | tr -d ' ')
            save_location "$lat" "$lon" "$name"
            ;;
        3)
            echo "Using IP-based location (may not be accurate)..."
            # Fall back to IP detection
            local ip_data=$(curl -s "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon")
            local status=$(echo "$ip_data" | jq -r '.status // "fail"')
            
            if [[ "$status" == "success" ]]; then
                local lat=$(echo "$ip_data" | jq -r '.lat // "0"')
                local lon=$(echo "$ip_data" | jq -r '.lon // "0"')
                local city=$(echo "$ip_data" | jq -r '.city // "Unknown"')
                local region=$(echo "$ip_data" | jq -r '.regionName // ""')
                local country=$(echo "$ip_data" | jq -r '.country // "Unknown"')
                
                if [[ -n "$region" && "$region" != "null" ]]; then
                    local name="${city}, ${region}, ${country}"
                else
                    local name="${city}, ${country}"
                fi
                
                save_location "$lat" "$lon" "$name"
                echo "IP location detected: $name"
            else
                echo "Failed to detect IP location. Using default coordinates."
                save_location "9.9985" "-84.1165" "Heredia, Costa Rica"
            fi
            ;;
        *)
            echo "Invalid choice. Using default location."
            save_location "9.9985" "-84.1165" "Heredia, Costa Rica"
            ;;
    esac
}

# Main execution
echo "=== Conky Weather Location Setup ==="

# Try to get location from config first
if get_location_from_config; then
    echo "Using saved location: $WEATHER_NAME"
else
    echo "No saved location found. Setting up location..."
    set_location_manual
fi

# Reload config after potential changes
if [[ -f "$LOCATION_CONFIG" ]]; then
    source "$LOCATION_CONFIG"
fi

# Fetch weather data
echo "Fetching weather data for $WEATHER_NAME..."
WEATHER_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${WEATHER_LAT}&lon=${WEATHER_LON}&appid=${API_KEY}&units=metric&lang=en")

# Extract weather information
CONDITION=$(echo "$WEATHER_DATA" | jq -r '.weather[0].main // "Unknown"')
TEMP=$(echo "$WEATHER_DATA" | jq -r '.main.temp // "Unknown"')
HUMIDITY=$(echo "$WEATHER_DATA" | jq -r '.main.humidity // "Unknown"')

# Map weather condition to icon
get_weather_icon() {
    local condition="$1"
    case "$condition" in
        "Clear") echo "sunny" ;;
        "Clouds") echo "cloudy" ;;
        "Rain") echo "rain" ;;
        "Drizzle") echo "rain" ;;
        "Thunderstorm") echo "thunderstorm" ;;
        "Snow") echo "snow" ;;
        "Mist"|"Fog"|"Haze") echo "fog" ;;
        *) echo "cloudy" ;;
    esac
}

ICON=$(get_weather_icon "$CONDITION")

# Format temperature
if [[ "$TEMP" != "Unknown" ]]; then
    TEMP_ROUNDED=$(printf "%.0f" "$TEMP")
    TEMP_DISPLAY="${TEMP_ROUNDED}°C"
else
    TEMP_DISPLAY="Unknown"
fi

# Write to weather file
echo "${WEATHER_NAME}|${TEMP_DISPLAY} ${CONDITION}|${ICON}.png" > "$WEATHER_FILE"

echo ""
echo "=== Weather Updated ==="
echo "Location: $WEATHER_NAME"
echo "Coordinates: $WEATHER_LAT, $WEATHER_LON"
echo "Condition: ${TEMP_DISPLAY} ${CONDITION}"
echo "Icon: ${ICON}.png"
echo "Humidity: ${HUMIDITY}%"
echo ""
echo "To change location, run: $0"
echo "Location config saved to: $LOCATION_CONFIG"
