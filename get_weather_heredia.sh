#!/bin/bash

# Get real weather from Heredia, Costa Rica
# Using OpenWeatherMap API (free tier)

# Heredia, Costa Rica coordinates
LAT="9.9985"
LON="-84.1165"
API_KEY="e46d6b1c945f2e9983f0735f8928ea2f"  # From your Arrakis script
WEATHER_FILE="/tmp/conky_weather.txt"

# Fetch current weather data
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
echo "Heredia, Costa Rica|${TEMP_DISPLAY} ${CONDITION}|${ICON}.png" > "$WEATHER_FILE"

echo "Weather updated for Heredia, Costa Rica:"
echo "Location: Heredia, Costa Rica"
echo "Condition: ${TEMP_DISPLAY} ${CONDITION}"
echo "Icon: ${ICON}.png"
echo "Humidity: ${HUMIDITY}%"
