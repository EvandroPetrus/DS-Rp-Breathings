# BreathingSystem Admin HUD Guide

## Overview
The BreathingSystem Admin HUD is a comprehensive control panel that allows administrators to manage all aspects of the breathing system addon. It provides a modern, intuitive interface for player management, balance configuration, system monitoring, and testing.

## Accessing the Admin HUD

### Chat Commands
- **`!breathingadmin`** - Opens the admin HUD (admin only)
- **`/breathingadmin`** - Alternative command to open the admin HUD

### Requirements
- You must have admin or superadmin privileges
- The addon must be properly installed and initialized

## Features

### 1. Players Tab 👥
Manage individual player stats and breathing systems.

**Features:**
- View all online players
- Search players by name
- View detailed player statistics
- Modify player attributes:
  - Breathing type
  - Level
  - XP
  - Stamina
  - Concentration
- Quick actions:
  - Reset player data
  - Heal to full stamina
  - Unlock forms

### 2. Balance Tab ⚖️
Fine-tune game balance parameters in real-time.

**Categories:**
- **Damage** - Base damage, PvP multipliers, level scaling
- **Stamina** - Max stamina, regeneration rates, drain rates
- **Cooldowns** - Global multipliers, difficulty scaling
- **XP** - Gain rates, training multipliers, form usage rewards
- **Effects** - Particle intensity, sound volume, animation speed
- **Combat** - PvP settings, status effects, counter mechanics

**Features:**
- Live editing of all balance values
- Visual indicators for modified values
- Reset individual categories or all settings
- Save/load balance presets

### 3. Breathing Types Tab 🌊
Overview of all available breathing types.

**Information displayed:**
- Type name and ID
- Category (elemental, special, etc.)
- Description
- Color coding
- Associated forms count

### 4. Forms Tab ⚔️
Manage and test breathing forms.

**Features:**
- Complete list of all forms
- Form statistics (damage, stamina cost, cooldown)
- Test forms on selected players
- View form requirements
- Unlock forms for players

### 5. Logs Tab 📋
Monitor system activity and debug issues.

**Features:**
- Real-time log viewing
- Filter by log level:
  - ERROR (critical issues)
  - WARNING (potential problems)
  - INFO (general information)
  - DEBUG (detailed debugging)
- Clear logs
- View timestamps and categories
- Track admin actions

### 6. Settings Tab ⚙️
Configure system-wide settings.

**Options:**
- Log level configuration
- Auto-save toggle
- Performance monitoring
- PvP enable/disable
- System information display

## Admin Commands Reference

### Player Management
| Command | Description |
|---------|-------------|
| `set_player_breathing` | Change a player's breathing type |
| `set_player_level` | Set a player's level |
| `set_player_xp` | Set a player's XP |
| `set_player_stamina` | Modify stamina values |
| `unlock_form` | Unlock a specific form for a player |
| `reset_player` | Reset all player data |

### Balance Control
| Command | Description |
|---------|-------------|
| `set_balance` | Modify a balance value |
| `reset_balance` | Reset balance to defaults |
| `save_preset` | Save current balance as preset |
| `load_preset` | Load a balance preset |

### System Control
| Command | Description |
|---------|-------------|
| `set_log_level` | Change logging verbosity |
| `clear_logs` | Clear all system logs |
| `test_form` | Test a form on a player |
| `refresh_data` | Refresh admin HUD data |

## UI Features

### Modern Design
- Clean, dark theme with accent colors
- Smooth animations and transitions
- Responsive layout
- Visual feedback for all interactions

### Color Coding
- 🟦 **Blue** - Selected/Active items
- 🟢 **Green** - Success/Healthy status
- 🟡 **Yellow** - Warning/Modified values
- 🔴 **Red** - Error/Critical issues
- ⚪ **White** - Normal text
- 🔘 **Gray** - Inactive/Dimmed items

### Search and Filter
- Quick player search
- Log level filtering
- Preset management
- Form filtering by type

## Best Practices

### Performance
1. Close the HUD when not in use
2. Use log filtering to reduce clutter
3. Save balance presets before major changes
4. Monitor performance metrics regularly

### Security
1. Only trusted admins should have access
2. All admin actions are logged
3. Use presets to maintain consistent balance
4. Test changes on individual players first

### Testing
1. Use the test form feature before mass deployment
2. Monitor logs during testing
3. Create test presets for different scenarios
4. Reset players after testing

## Troubleshooting

### HUD Won't Open
- Verify admin privileges
- Check console for errors
- Ensure addon is properly loaded
- Try reconnecting to the server

### Data Not Updating
- Use the Refresh button
- Check network connection
- Verify server is responding
- Check logs for errors

### Balance Changes Not Applied
- Ensure values are valid
- Check for conflicting settings
- Apply balance after changes
- Restart may be required for some settings

## Tips and Tricks

1. **Quick Testing**: Select a player and use the Forms tab to quickly test abilities
2. **Batch Operations**: Use balance presets to apply multiple changes at once
3. **Monitoring**: Keep the Logs tab open during events to monitor issues
4. **Backup**: Save your balance configuration as a preset before events
5. **Efficiency**: Use keyboard shortcuts and tab navigation for faster control

## Keyboard Shortcuts
- **ESC** - Close the admin HUD
- **TAB** - Navigate between input fields
- **ENTER** - Confirm input values
- **Mouse Wheel** - Scroll through lists

## Support
For issues or feature requests, check the system logs first, then contact the addon developer with:
- Log excerpts
- Steps to reproduce
- System information from Settings tab

---

*BreathingSystem Admin HUD v1.0.0* 