#!/bin/bash
# Get weather using multiple location services for better accuracy
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

# Function to try multiple IP geolocation services
try_ip_geolocation() {
    echo "Trying multiple IP geolocation services for better accuracy..."
    
    # Service 1: ip-api.com
    echo "  - Trying ip-api.com..."
    local ip_data1=$(curl -s "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon")
    local status1=$(echo "$ip_data1" | jq -r '.status // "fail"')
    
    if [[ "$status1" == "success" ]]; then
        local lat1=$(echo "$ip_data1" | jq -r '.lat // "0"')
        local lon1=$(echo "$ip_data1" | jq -r '.lon // "0"')
        local city1=$(echo "$ip_data1" | jq -r '.city // "Unknown"')
        local region1=$(echo "$ip_data1" | jq -r '.regionName // ""')
        local country1=$(echo "$ip_data1" | jq -r '.country // "Unknown"')
        
        echo "    Found: $city1, $region1, $country1 at $lat1, $lon1"
    fi
    
    # Service 2: ipapi.co
    echo "  - Trying ipapi.co..."
    local ip_data2=$(curl -s "https://ipapi.co/json/")
    local lat2=$(echo "$ip_data2" | jq -r '.latitude // "0"')
    local lon2=$(echo "$ip_data2" | jq -r '.longitude // "0"')
    local city2=$(echo "$ip_data2" | jq -r '.city // "Unknown"')
    local region2=$(echo "$ip_data2" | jq -r '.region // ""')
    local country2=$(echo "$ip_data2" | jq -r '.country_name // "Unknown"')
    
    if [[ "$lat2" != "0" && "$lon2" != "0" ]]; then
        echo "    Found: $city2, $region2, $country2 at $lat2, $lon2"
    fi
    
    # Service 3: ipinfo.io
    echo "  - Trying ipinfo.io..."
    local ip_data3=$(curl -s "https://ipinfo.io/json")
    local lat3=$(echo "$ip_data3" | jq -r '.loc // "0,0"')
    local city3=$(echo "$ip_data3" | jq -r '.city // "Unknown"')
    local region3=$(echo "$ip_data3" | jq -r '.region // ""')
    local country3=$(echo "$ip_data3" | jq -r '.country // "Unknown"')
    
    if [[ "$lat3" != "0,0" ]]; then
        local lat3_val=$(echo "$lat3" | cut -d',' -f1)
        local lon3_val=$(echo "$lat3" | cut -d',' -f2)
        echo "    Found: $city3, $region3, $country3 at $lat3_val, $lon3_val"
    fi
    
    # Compare results and use the most consistent one
    echo ""
    echo "Comparing results from multiple services..."
    
    # For now, use the first successful result (ip-api.com)
    if [[ "$status1" == "success" ]]; then
        local name="${city1}, ${region1}, ${country1}"
        save_location "$lat1" "$lon1" "$name"
        echo "Using ip-api.com result: $name"
        return 0
    elif [[ "$lat2" != "0" && "$lon2" != "0" ]]; then
        local name="${city2}, ${region2}, ${country2}"
        save_location "$lat2" "$lon2" "$name"
        echo "Using ipapi.co result: $name"
        return 0
    elif [[ "$lat3" != "0,0" ]]; then
        local lat3_val=$(echo "$lat3" | cut -d',' -f1)
        local lon3_val=$(echo "$lat3" | cut -d',' -f2)
        local name="${city3}, ${region3}, ${country3}"
        save_location "$lat3_val" "$lon3_val" "$name"
        echo "Using ipinfo.io result: $name"
        return 0
    fi
    
    return 1
}

# Function to get location from browser geolocation (requires user input)
get_browser_location() {
    echo ""
    echo "For the most accurate location, you can:"
    echo "1. Open your browser and go to: https://www.latlong.net/"
    echo "2. Click 'Get My Location' (allow location access)"
    echo "3. Copy the coordinates shown"
    echo ""
    read -p "Enter coordinates (lat,lon) from browser: " coords
    read -p "Enter location name: " name
    
    if [[ -n "$coords" && -n "$name" ]]; then
        local lat=$(echo "$coords" | cut -d',' -f1 | tr -d ' ')
        local lon=$(echo "$coords" | cut -d',' -f2 | tr -d ' ')
        save_location "$lat" "$lon" "$name"
        echo "Browser location saved: $name at $lat, $lon"
        return 0
    fi
    
    return 1
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
    echo "Choose location method:"
    echo "1. Try multiple IP geolocation services (better accuracy)"
    echo "2. Use browser geolocation (most accurate - requires manual input)"
    echo "3. Search for specific city"
    echo "4. Enter coordinates manually"
    echo ""
    read -p "Enter your choice (1/2/3/4): " choice
    
    case $choice in
        1)
            try_ip_geolocation
            ;;
        2)
            get_browser_location
            ;;
        3)
            read -p "Enter city name: " city
            search_city "$city"
            ;;
        4)
            read -p "Enter coordinates (lat,lon): " coords
            read -p "Enter location name: " name
            local lat=$(echo "$coords" | cut -d',' -f1 | tr -d ' ')
            local lon=$(echo "$coords" | cut -d',' -f2 | tr -d ' ')
            save_location "$lat" "$lon" "$name"
            ;;
        *)
            echo "Invalid choice. Using IP geolocation..."
            try_ip_geolocation
            ;;
    esac
}

# Main execution
echo "=== Conky Weather Location Setup (Enhanced Accuracy) ==="

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
