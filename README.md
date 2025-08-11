# 🎨 Conky Desktop Widgets

A beautiful, modular Conky configuration featuring multiple widgets with Nord color scheme, anti-flicker settings, and smart update intervals.

## ✨ Features

- **🎵 Music Widget**: Real-time music player information with progress bars
- **💻 System Widget**: CPU, RAM, SWAP, uptime, and battery monitoring
- **💾 Filesystem Widget**: Disk usage for root and home directories
- **🔄 Processes Widget**: Top CPU and RAM processes with usage bars
- **🌐 Network Widget**: Upload/download speeds and total data usage
- **🌤️ Weather Widget**: Real-time weather for Heredia, Costa Rica
- **🎨 Nord Color Scheme**: Beautiful, consistent color palette
- **⚡ Smart Updates**: Anti-flicker with double buffering
- **🔧 Modular Design**: Easy to customize and extend

## 🚀 Quick Start

### Prerequisites

- **Conky**: Version 1.12.2 or higher
- **Lua**: Built-in with Conky
- **playerctl**: For music widget functionality
- **curl & jq**: For weather data fetching

### Installation

1. **Clone or download** this configuration to `~/.conky/`
2. **Install dependencies**:
   ```bash
   sudo apt install playerctl curl jq
   ```
3. **Start Conky**:
   ```bash
   conky -c ~/.conky/main.lua
   ```

### Auto-start

Add to your startup applications:
```bash
conky -c ~/.conky/main.lua &
```

## 📁 File Structure

```
~/.conky/
├── .conkyrc                 # Main Conky entry point
├── main.lua                 # Core configuration and widget loading
├── get_weather_heredia.sh  # Weather data fetcher
├── sections/                # Widget modules
│   ├── common_draw.lua     # Shared drawing utilities
│   ├── system.lua          # System information widget
│   ├── filesystem.lua      # Disk usage widget
│   ├── processes.lua       # Process monitoring widget
│   ├── network.lua         # Network statistics widget
│   ├── weather.lua         # Weather display widget
│   ├── music.lua           # Music player widget
│   └── temperature.lua     # Temperature monitoring widget
├── images/                  # Widget images and logos
│   └── pop_os.png         # System logo
└── weather/                 # Weather icons and data
    └── icons/              # Weather condition icons
        ├── sunny.png
        ├── cloudy.png
        ├── rain.png
        └── thunderstorm.png
```

## 🎯 Widget Details

### 🎵 Music Widget
- **Real-time progress bars** for current track
- **Smart updates**: Only refreshes changing elements
- **Playerctl integration** for universal music player support
- **Beautiful formatting** with track title and artist

### 💻 System Widget
- **CPU usage** with visual progress bars
- **Memory monitoring** (RAM & SWAP) with used/total display
- **System uptime** and battery percentage
- **Kernel information** display

### 💾 Filesystem Widget
- **Root (/) and Home (/home)** directory monitoring
- **Usage percentages** with visual progress bars
- **Used/Total space** display
- **Compact layout** for efficient space usage

### 🔄 Processes Widget
- **Top CPU process** with usage percentage
- **Top RAM process** with memory usage
- **Process name truncation** for clean display
- **Visual progress bars** for easy monitoring

### 🌐 Network Widget
- **Real-time upload/download** speeds
- **Total data usage** tracking
- **Clean, compact** display format
- **Nord color scheme** consistency

### 🌤️ Weather Widget
- **Heredia, Costa Rica** weather data
- **OpenWeatherMap API** integration
- **Weather condition icons** for visual appeal
- **Temperature and condition** display

## 🎨 Customization

### Colors
The configuration uses the Nord color scheme:
- **Primary**: `#2E3440` (Dark blue)
- **Secondary**: `#3B4252` (Medium blue)
- **Accent**: `#4C566A` (Light blue)
- **Highlight**: `#5E81AC` (Bright blue)
- **Text**: `#81A1C1` (Light text)

### Fonts
- **Main Font**: Droid Sans (size 10)
- **Headers**: Droid Sans Bold (size 16)
- **Widgets**: Droid Sans (size 11-14)

### Positioning
- **Alignment**: Top-left corner
- **Gaps**: 0px (no margins)
- **Window Type**: Normal, undecorated

## ⚙️ Configuration

### Update Intervals
- **Main Interval**: 1 second for responsive updates
- **Smart Updates**: Only changing elements refresh
- **Anti-flicker**: Double buffering enabled

### Performance Settings
- **Double Buffer**: `true` (prevents flickering)
- **No Buffers**: `true` (improves performance)
- **Text Buffer Size**: 2048 bytes

### Window Settings
- **Own Window**: `true`
- **Window Type**: `normal`
- **ARGB Visual**: `true` (transparency support)
- **Below**: Always on top of desktop

## 🔧 Troubleshooting

### Common Issues

1. **Music not displaying**:
   - Ensure `playerctl` is installed
   - Check if a music player is running

2. **Weather not updating**:
   - Verify internet connection
   - Check API key in `get_weather_heredia.sh`

3. **Widgets not aligned**:
   - Check font installation
   - Verify Conky version compatibility

4. **Performance issues**:
   - Reduce update interval if needed
   - Check system resources

### Debug Mode
Run with debug output:
```bash
conky -c ~/.conky/main.lua --debug
```

## 📝 Dependencies

| Package | Purpose | Installation |
|---------|---------|---------------|
| `conky` | Main application | `sudo apt install conky` |
| `playerctl` | Music control | `sudo apt install playerctl` |
| `curl` | HTTP requests | `sudo apt install curl` |
| `jq` | JSON parsing | `sudo apt install jq` |

## 🌟 Contributing

Feel free to:
- **Report issues** with specific error messages
- **Suggest improvements** for widgets or layout
- **Share customizations** you've made
- **Contribute new widgets** or themes

## 📄 License

This configuration is provided as-is for personal use. Feel free to modify and distribute according to your needs.

## 🙏 Acknowledgments

- **Nord Color Scheme** for the beautiful color palette
- **Conky Community** for the excellent desktop widget system
- **OpenWeatherMap** for weather data API
- **Playerctl** for universal music player support

---

**Happy Conky-ing! 🎉**

*Your desktop will never look the same again.*
