# Conky Configuration - Dual Version System

A comprehensive Conky desktop widget configuration with two distinct versions: **Conky Bars** (fully functional) and **New Version** (clean slate for development).

## 🌟 Features

### Conky Bars Version (Production Ready)
- **System Widget**: CPU, RAM, SWAP, Uptime, Battery with progress bars
- **Filesystem Widget**: Disk usage for root and home directories
- **Processes Widget**: Top CPU and RAM consuming processes
- **Network Widget**: Upload/download speeds, IP addresses
- **Weather Widget**: Auto-updating weather with location detection
- **Music Widget**: Smart music player display (auto-hides when not playing)

### New Version (Development)
- **Clean slate** for new designs and approaches
- **Modular structure** ready for custom widgets
- **Placeholder widgets** for system, weather, and music

## 🚀 Quick Start

### Option 1: Interactive Startup (Recommended)
```bash
cd ~/.conky
./start_conky.sh
```
Then choose:
- **1** - Start Conky Bars (working version)
- **2** - Start New Version (development)
- **3** - Stop all Conky instances
- **4** - Exit

### Option 2: Direct Launch
```bash
# Conky Bars version
conky -c ~/.conky/main_bars.lua

# New version
conky -c ~/.conky/main.lua
```

## 📁 File Structure

```
~/.conky/
├── main_bars.lua              # Conky Bars configuration
├── main.lua                   # New version configuration
├── sections_bars/             # Working widgets (Conky Bars)
│   ├── system.lua            # System information
│   ├── filesystem.lua        # Disk usage
│   ├── processes.lua         # Process monitoring
│   ├── network.lua           # Network statistics
│   ├── weather.lua           # Auto-updating weather
│   ├── music.lua             # Music player widget
│   └── common_draw.lua       # Shared functions
├── sections/                  # New version widgets
│   ├── common.lua            # Basic helper functions
│   ├── system.lua            # Placeholder
│   ├── weather.lua           # Placeholder
│   └── music.lua             # Placeholder
├── weather/                   # Weather resources
│   └── icons/                # Weather condition icons
├── images/                    # General images
├── start_conky.sh            # Version selector script
├── update_weather.sh         # Manual weather update
├── get_weather_*.sh          # Weather location scripts
└── README.md                 # This file
```

## 🎨 Design Features

### Color Scheme
- **Nord Color Palette**: Modern, easy-on-the-eyes design
- **Consistent theming**: All widgets follow the same color scheme
- **High contrast**: Optimized for readability

### Layout
- **Column-based alignment**: Clean, organized information display
- **Progress bars**: Visual representation of system metrics
- **Smart spacing**: Optimized vertical and horizontal spacing

## 🔧 Configuration

### Conky Bars Version
- **Position**: Top-left corner
- **Transparency**: 25% (75% opaque)
- **Update interval**: 1 second
- **Anti-flicker**: Double buffering enabled

### New Version
- **Position**: Top-right corner
- **Transparency**: 25% (75% opaque)
- **Update interval**: 1 second
- **Clean slate**: Ready for custom configuration

## 🌤️ Weather System

### Automatic Features
- **Location detection**: Multiple IP geolocation services
- **Auto-updates**: Every 15-30 minutes
- **Fallback support**: Multiple service providers
- **Icon mapping**: Weather condition to icon files

### Manual Control
- **Location override**: Set custom coordinates
- **City search**: Find any city by name
- **Browser geolocation**: Most accurate method

## 🎵 Music Widget

### Smart Display
- **Auto-hide**: Only shows when music is playing
- **Player support**: Works with any MPRIS-compatible player
- **Progress tracking**: Real-time playback progress
- **Metadata display**: Title, artist, duration

### Supported Players
- Spotify
- VLC
- Rhythmbox
- Any MPRIS-compatible player

## 🛠️ Customization

### Adding New Widgets
1. Create new Lua file in `sections/`
2. Define `conky_widgetname_display()` function
3. Add to `main.lua` lua_load and conky.text
4. Restart Conky

### Modifying Colors
- Edit color values in widget files
- Use Nord color palette for consistency
- Test changes with Conky restart

### Adjusting Layout
- Modify `voffset` and `offset` values
- Use `goto` for precise positioning
- Test different alignments

## 🔍 Troubleshooting

### Common Issues

#### Weather Not Updating
```bash
# Check weather data
cat /tmp/conky_weather.txt

# Manual update
./update_weather.sh

# Check location config
cat ~/.conky/weather_location.conf
```

#### Music Widget Not Showing
```bash
# Check player status
playerctl status

# Check if any player is active
playerctl --list-all
```

#### Conky Not Starting
```bash
# Check for errors
conky -c main.lua

# Kill existing instances
pkill conky

# Check file permissions
ls -la *.lua
```

### Debug Mode
- Check Conky output for error messages
- Verify Lua script syntax
- Test individual widgets

## 📦 Dependencies

### Required Packages
- **conky**: Main application
- **curl**: Weather API requests
- **jq**: JSON parsing
- **playerctl**: Music player control

### Installation (Ubuntu/Debian)
```bash
sudo apt install conky curl jq playerctl
```

### Installation (Arch)
```bash
sudo pacman -S conky curl jq playerctl
```

## 🚀 Development

### Working with New Version
1. **Start development**: `./start_conky.sh` → Option 2
2. **Edit widgets**: Modify files in `sections/`
3. **Test changes**: Conky auto-reloads on file changes
4. **Compare versions**: Switch between bars and new version

### Version Control
- **Branch**: `conky-version2`
- **Previous**: `conky-config` (Conky Bars)
- **Main**: `main` (base)

### Contributing
1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📝 Changelog

### Latest Updates
- **Dual version system**: Conky Bars + New Version
- **Smart startup script**: Choose which version to run
- **Enhanced weather**: Multiple location services
- **Music widget**: Auto-hide when not playing
- **Repository cleanup**: Organized file structure

### Previous Versions
- **v1.0**: Basic Conky configuration
- **v2.0**: Widget system implementation
- **v3.0**: Weather and music integration
- **v4.0**: Dual version system

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- **Nord Color Scheme**: Beautiful color palette
- **OpenWeatherMap**: Weather data API
- **Conky Community**: Excellent documentation and examples
- **Linux Community**: Continuous improvements and support

## 📞 Support

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check this README first
- **Community**: Linux and Conky forums

### Reporting Issues
When reporting issues, please include:
- Conky version
- Operating system
- Error messages
- Steps to reproduce
- Expected vs. actual behavior

---

**Happy Conky-ing!** 🎉
