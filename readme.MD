# BreathingSystem - Garry's Mod Addon

A comprehensive breathing system addon for Garry's Mod that allows players to use different breathing techniques for various effects.

## Fase 1 - Core Structure

This phase implements the basic structure with:
- Core module system
- Configuration management
- Player registry
- Forms (breathing techniques) system
- Basic permissions
- Test commands

## Installation

1. Place the `lua` folder in your Garry's Mod addons directory
2. Restart your server or use `changelevel` to load the addon

## Testing Fase 1

### Console Commands

1. **Test the system:**
   ```
   breathingsystem_test
   ```
   This will display:
   - Player data for the current player
   - Available breathing types
   - Available forms
   - Debug information

2. **Set player breathing type (Admin only):**
   ```
   breathingsystem_set <player_name> <breathing_type>
   ```
   Example:
   ```
   breathingsystem_set Player normal
   breathingsystem_set Player deep
   breathingsystem_set Player combat
   ```

### Expected Output

When you run `breathingsystem_test`, you should see:

```
[BreathingSystem] Test command executed by PlayerName
[BreathingSystem] Player data for PlayerName:
  player = Player [1]
  steamid = STEAM_0:0:123456789
  name = PlayerName
  current_breathing_type = normal
  breathing_start_time = 0
  breathing_duration = 0
  stamina = 100
  max_stamina = 100
  concentration = 100
  max_concentration = 100
  is_breathing = false
  is_registered = true
  last_update = 1234.567
  cooldown_end = 0

[BreathingSystem] Available breathing types:
  - normal: Normal Breathing
  - deep: Deep Breathing
  - combat: Combat Breathing

[BreathingSystem] Available forms:
  - box_breathing: Box Breathing
  - combat_breathing: Combat Breathing
  - deep_breathing: Deep Breathing
  - focus_breathing: Focus Breathing
```

### File Structure

```
lua/breathingsystem/
├── core/
│   ├── init.lua          # Main entry point
│   ├── config.lua        # Configuration and breathing types
│   ├── player_registry.lua # Player data management
│   └── forms.lua         # Breathing forms/techniques
└── addon.txt             # Addon metadata
```

## API Reference

### Core Functions

- `BreathingSystem.GetPlayerData(ply)` - Get player breathing data
- `BreathingSystem.SetPlayerBreathing(ply, typeID)` - Set player breathing type
- `BreathingSystem.GetPlayerBreathing(ply)` - Get current breathing type
- `BreathingSystem.IsPlayerBreathing(ply)` - Check if player is breathing

### Configuration

- `BreathingSystem.Config.RegisterBreathingType(id, data)` - Register new breathing type
- `BreathingSystem.Config.GetBreathingType(id)` - Get breathing type data
- `BreathingSystem.Config.GetAllBreathingTypes()` - Get all breathing types

### Forms

- `BreathingSystem.Forms.RegisterForm(id, data)` - Register new form
- `BreathingSystem.Forms.GetForm(id)` - Get form data
- `BreathingSystem.Forms.GetAll()` - Get all forms

## Next Phases

Future phases will add:
- Client-side UI
- Network synchronization
- Visual effects
- Sound effects
- Advanced breathing mechanics
- Integration with other systems

## Troubleshooting

If the addon doesn't load:
1. Check the console for error messages
2. Ensure all files are in the correct location
3. Verify the addon.txt file is present
4. Try restarting the server

If commands don't work:
1. Make sure you're an admin for the `breathingsystem_set` command
2. Check that the player name is correct (case-sensitive)
3. Verify the breathing type exists
