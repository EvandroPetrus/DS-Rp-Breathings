# BreathingSystem - Fase 2 Complete! ✅

## Fase 2 - Tipos de Respiración (Breathing Types)

This phase implements 5 elemental breathing types with their respective forms:

### Breathing Types Implemented:

1. **Water Breathing** (5 forms)
   - Focus: Healing, adaptability, fluidity
   - Forms: Surface Slash, Water Wheel, Flowing Dance, Waterfall Basin, Constant Flux

2. **Fire Breathing** (9 forms)
   - Focus: Power, aggression, destruction
   - Forms: Unknowing Fire, Rising Scorching Sun, Blazing Universe, Blooming Flame Undulation, Tiger, Rengoku, Flame Dance, Hinokami Kagura, Sun Breathing

3. **Thunder Breathing** (6 forms + 2 variants)
   - Focus: Speed, precision, electrical power
   - Forms: Thunderclap and Flash, Rice Spirit, Thunder Swarm, Heat Lightning, Thunderclap and Flash (Sixfold), Honoikazuchi no Kami
   - Variants: Thunderclap and Flash (Eightfold), Thunderclap and Flash (God Speed)

4. **Stone Breathing** (5 forms)
   - Focus: Defense, endurance, unbreakable strength
   - Forms: Surface Slash, Stone Skin, Volcanic Rock, Upper Smash, Arcs of Justice

5. **Wind Breathing** (9 forms)
   - Focus: Freedom, movement, cutting power
   - Forms: Dust Whirlwind Cutter, Claws-Purifying Wind, Clean Storm Wind Tree, Rising Dust Storm, Cold Mountain Wind, Black Wind Mountain, Gale Sudden Gusts, Primary Gale Slash, Idaten Typhoon

6. **Template** (3 forms)
   - A template file for developers to create new breathing types

## File Structure

```
lua/breathingsystem/
├── core/
│   ├── init.lua              # Main entry point (updated)
│   ├── config.lua            # Configuration system
│   ├── player_registry.lua   # Player data management
│   └── forms.lua             # Forms system
├── breathing_types/
│   ├── template.lua          # Template for new breathing types
│   ├── water.lua             # Water breathing (5 forms)
│   ├── fire.lua              # Fire breathing (9 forms)
│   ├── thunder.lua           # Thunder breathing (6 forms + 2 variants)
│   ├── stone.lua             # Stone breathing (5 forms)
│   └── wind.lua              # Wind breathing (9 forms)
└── addon.txt                 # Addon metadata
```

## How to Test Fase 2 Locally in Garry's Mod:

### 1. Installation
1. Copy the `lua` folder to your Garry's Mod addons directory
2. Restart your server or use `changelevel` to load the addon

### 2. Console Commands

#### Basic Testing:
```
breathingsystem_test
```
This will show:
- Player data
- All available breathing types
- All available forms

#### List All Breathing Types:
```
breathingsystem_list_types
```
Shows all registered breathing types with descriptions.

#### List Forms for Specific Type:
```
breathingsystem_list_forms water
breathingsystem_list_forms fire
breathingsystem_list_forms thunder
breathingsystem_list_forms stone
breathingsystem_list_forms wind
```

#### Set Player Breathing Type (Admin only):
```
breathingsystem_set <player_name> <breathing_type>
```
Examples:
```
breathingsystem_set Player water
breathingsystem_set Player fire
breathingsystem_set Player thunder
breathingsystem_set Player stone
breathingsystem_set Player wind
```

### 3. Expected Console Output

When you run `breathingsystem_test`, you should see:

```
[BreathingSystem] Initializing core system...
[BreathingSystem] Configuration module loaded
[BreathingSystem] Player registry module loaded
[BreathingSystem] Forms module loaded
[BreathingSystem] Registered Water Breathing with 5 forms
[BreathingSystem] Registered Fire Breathing with 9 forms
[BreathingSystem] Registered Thunder Breathing with 6 forms and 2 variants
[BreathingSystem] Registered Stone Breathing with 5 forms
[BreathingSystem] Registered Wind Breathing with 9 forms
[BreathingSystem] Core modules and breathing types loaded successfully
[BreathingSystem] Default breathing types registered
[BreathingSystem] Core initialization complete!
[BreathingSystem] Commands registered: breathingsystem_test, breathingsystem_set, breathingsystem_list_types, breathingsystem_list_forms
[BreathingSystem] Registered player: PlayerName (STEAM_0:0:123456789)
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
  - water: Water Breathing
  - fire: Fire Breathing
  - thunder: Thunder Breathing
  - stone: Stone Breathing
  - wind: Wind Breathing

[BreathingSystem] Available forms:
  - water_surface_slash: Water Surface Slash
  - water_water_wheel: Water Wheel
  - water_flowing_dance: Flowing Dance
  - water_waterfall_basin: Waterfall Basin
  - water_constant_flux: Constant Flux
  - fire_unknowing_fire: Unknowing Fire
  - fire_rising_scorching_sun: Rising Scorching Sun
  - fire_blazing_universe: Blazing Universe
  - fire_blooming_flame_undulation: Blooming Flame Undulation
  - fire_tiger: Tiger
  - fire_rengoku: Rengoku
  - fire_flame_dance: Flame Dance
  - fire_hinokami_kagura: Hinokami Kagura
  - fire_sun_breathing: Sun Breathing
  - thunder_clap_flash: Thunderclap and Flash
  - thunder_rice_spirit: Rice Spirit
  - thunder_swarm: Thunder Swarm
  - thunder_heat_lightning: Heat Lightning
  - thunder_clap_flash_sixfold: Thunderclap and Flash (Sixfold)
  - thunder_honoikazuchi_no_kami: Honoikazuchi no Kami
  - thunder_clap_flash_eightfold: Thunderclap and Flash (Eightfold)
  - thunder_clap_flash_god_speed: Thunderclap and Flash (God Speed)
  - stone_surface_slash: Surface Slash
  - stone_skin: Stone Skin
  - stone_volcanic_rock: Volcanic Rock
  - stone_upper_smash: Upper Smash
  - stone_arcs_of_justice: Arcs of Justice
  - wind_dust_whirlwind_cutter: Dust Whirlwind Cutter
  - wind_claws_purifying_wind: Claws-Purifying Wind
  - wind_clean_storm_wind_tree: Clean Storm Wind Tree
  - wind_rising_dust_storm: Rising Dust Storm
  - wind_cold_mountain_wind: Cold Mountain Wind
  - wind_black_wind_mountain: Black Wind Mountain
  - wind_gale_sudden_gusts: Gale, Sudden Gusts
  - wind_primary_gale_slash: Primary Gale Slash
  - wind_idaten_typhoon: Idaten Typhoon
```

### 4. Testing Specific Features

#### Test Water Breathing:
```
breathingsystem_set Player water
breathingsystem_list_forms water
```

#### Test Fire Breathing:
```
breathingsystem_set Player fire
breathingsystem_list_forms fire
```

#### Test Thunder Breathing:
```
breathingsystem_set Player thunder
breathingsystem_list_forms thunder
```

### 5. Verification Steps

1. **Check Loading**: Look for the registration messages in console
2. **Test Commands**: Run all the test commands to verify functionality
3. **Check Forms**: Verify that all forms are properly registered
4. **Test Permissions**: Try commands as both admin and regular player
5. **Check Player Data**: Verify that player data is properly managed

### 6. Troubleshooting

If breathing types don't load:
- Check console for error messages
- Verify all files are in the correct location
- Ensure the addon.txt file is present
- Try restarting the server

If commands don't work:
- Make sure you're an admin for the `breathingsystem_set` command
- Check that the player name is correct (case-sensitive)
- Verify the breathing type exists

## Next Phase

Fase 3 will add:
- Client-side UI for breathing types and forms
- Visual effects for each breathing type
- Sound effects
- Network synchronization
- Advanced breathing mechanics

## API Reference

### New Functions Added:
- `breathingsystem_list_types` - List all breathing types
- `breathingsystem_list_forms <type>` - List forms for specific type

### Breathing Type Structure:
Each breathing type includes:
- Basic info (name, description, category)
- Visual properties (color, icon)
- Gameplay properties (stamina_drain, damage_modifier, etc.)
- Special abilities
- Requirements

### Form Structure:
Each form includes:
- Basic info (name, description, difficulty)
- Gameplay properties (stamina_drain, damage_modifier, etc.)
- Instructions for the player
- Visual/audio effects
- Requirements to learn
