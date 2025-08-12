#!/bin/bash
# Get real weather from current location automatically
# Using IP geolocation and OpenWeatherMap API

API_KEY="e46d6b1c945f2e9983f0735f8928ea2f"  # From your Arrakis script
WEATHER_FILE="/tmp/conky_weather.txt"

echo "Detecting your current location..."

# Get current location from IP address using ip-api.com (free service)
LOCATION_DATA=$(curl -s "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon")

# Check if location detection was successful
STATUS=$(echo "$LOCATION_DATA" | jq -r '.status // "fail"')

if [[ "$STATUS" != "success" ]]; then
    echo "Failed to detect location. Using fallback coordinates..."
    # Fallback to Heredia, Costa Rica if location detection fails
    LAT="9.9985"
    LON="-84.1165"
    LOCATION_NAME="Heredia, Costa Rica"
else
    # Extract location information
    LAT=$(echo "$LOCATION_DATA" | jq -r '.lat // "0"')
    LON=$(echo "$LOCATION_DATA" | jq -r '.lon // "0"')
    CITY=$(echo "$LOCATION_DATA" | jq -r '.city // "Unknown"')
    REGION=$(echo "$LOCATION_DATA" | jq -r '.regionName // ""')
    COUNTRY=$(echo "$LOCATION_DATA" | jq -r '.country // "Unknown"')
    
    # Format location name
    if [[ -n "$REGION" && "$REGION" != "null" ]]; then
        LOCATION_NAME="${CITY}, ${REGION}, ${COUNTRY}"
    else
        LOCATION_NAME="${CITY}, ${COUNTRY}"
    fi
    
    echo "Location detected: $LOCATION_NAME"
    echo "Coordinates: $LAT, $LON"
fi

# Fetch current weather data for detected location
echo "Fetching weather data..."
WEATHER_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=metric&lang=en")

# Extract weather information
CONDITION=$(echo "$WEATHER_DATA" | jq -r '.weather[0].main // "Unknown"')
DESCRIPTION=$(echo "$WEATHER_DATA" | jq -r '.weather[0].description // "Unknown"')
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

# Write to weather file in format: location|condition|icon
echo "${LOCATION_NAME}|${TEMP_DISPLAY} ${CONDITION}|${ICON}.png" > "$WEATHER_FILE"

echo "Weather updated for ${LOCATION_NAME}:"
echo "Location: ${LOCATION_NAME}"
echo "Condition: ${TEMP_DISPLAY} ${CONDITION}"
echo "Icon: ${ICON}.png"
echo "Humidity: ${HUMIDITY}%"
echo "Coordinates: ${LAT}, ${LON}"
