# BreathingSystem - Complete Testing Guide

## Overview
This guide provides comprehensive testing instructions for all 8 phases of the BreathingSystem addon.

## Installation
1. Copy the `lua` folder to your Garry's Mod addons directory
2. Restart your server or use `changelevel` to load the addon

## Phase Testing

### Fase 1 - Core Structure ✅
**Test Commands:**
```
breathingsystem_test
breathingsystem_set <player_name> <breathing_type>
breathingsystem_list_types
breathingsystem_list_forms <breathing_type>
```

**Expected Output:**
- Core modules load successfully
- Player data is registered
- Breathing types are available
- Forms are registered

### Fase 2 - Breathing Types ✅
**Test Commands:**
```
breathingsystem_list_types
breathingsystem_list_forms water
breathingsystem_list_forms fire
breathingsystem_list_forms thunder
breathingsystem_list_forms stone
breathingsystem_list_forms wind
```

**Expected Output:**
- 5 elemental breathing types loaded
- 34 total forms across all types
- Each type has unique characteristics

### Fase 3 - Core Mechanics ✅
**Test Commands:**
```
breathingsystem_test
breathingsystem_test_damage <form_id>
```

**Expected Output:**
- Stamina and concentration systems working
- Cooldowns functioning
- Prerequisites checking
- Damage calculations working

### Fase 4 - Progression ✅
**Test Commands:**
```
breathingsystem_train <student_name> <form_id>
breathingsystem_total_concentration
```

**Expected Output:**
- Training sessions work
- XP gain functions
- Level progression
- Total concentration state

### Fase 5 - Visual Effects ✅
**Test Commands:**
```
breathingsystem_test_effects particles
breathingsystem_test_effects animations
breathingsystem_test_effects sounds
```

**Expected Output:**
- Particle effects trigger
- Animations play
- Sounds play
- Effects are modular

### Fase 6 - Combat System ✅
**Test Commands:**
```
breathingsystem_test_combat <target_name> <form_id>
breathingsystem_test_status <effect_type>
```

**Expected Output:**
- PvP integration works
- Status effects apply
- Counters function
- Combat mechanics work

### Fase 7 - UI/UX ✅
**Test Commands:**
```
breathingsystem_menu breathing
breathingsystem_menu forms
breathingsystem_menu training
breathingsystem_menu progression
```

**Expected Output:**
- HUD displays correctly
- Menus open and function
- Keybinds work
- Real-time updates

### Fase 8 - Configuration and Balance ✅
**Test Commands:**
```
breathingsystem_balance <category> <key> <value>
breathingsystem_balance_report
breathingsystem_balance_reset <category|all>
breathingsystem_log_level <level>
breathingsystem_logs
```

**Expected Output:**
- Configuration loads/saves
- Balance values can be adjusted
- Logging system works
- Admin commands function

## Comprehensive Testing Scenarios

### Scenario 1: New Player Experience
1. Join server as new player
2. Run `breathingsystem_test` - should show basic data
3. Try `breathingsystem_menu breathing` - should show available types
4. Set breathing type to "water"
5. Try using forms - should be limited by level
6. Start training with another player
7. Gain XP and level up
8. Unlock new forms

### Scenario 2: Combat Testing
1. Set two players to different breathing types
2. Use `breathingsystem_test_combat` to test damage
3. Apply status effects with `breathingsystem_test_status`
4. Test counter relationships
5. Enter total concentration
6. Test PvP mechanics

### Scenario 3: Admin Testing
1. Set balance values with `breathingsystem_balance`
2. Check balance report with `breathingsystem_balance_report`
3. Adjust logging level with `breathingsystem_log_level`
4. View logs with `breathingsystem_logs`
5. Reset balance with `breathingsystem_balance_reset`

### Scenario 4: Effects Testing
1. Test particle effects for each breathing type
2. Test animations for different forms
3. Test sounds for various actions
4. Verify effects are modular and replaceable

## Troubleshooting

### Common Issues

**Addon doesn't load:**
- Check console for error messages
- Verify all files are in correct location
- Ensure addon.txt is present
- Try restarting server

**Commands don't work:**
- Check if you're admin for admin commands
- Verify player name is correct (case-sensitive)
- Check if breathing type exists
- Look for error messages in console

**Effects don't show:**
- Check if effects are enabled in config
- Verify particle/sound files exist
- Check console for error messages

**Balance changes don't apply:**
- Use `breathingsystem_balance_report` to check values
- Restart server to apply changes
- Check if values are being overridden

### Debug Commands

**System Status:**
```
breathingsystem_test
```

**Player Data:**
```
breathingsystem_set <player_name> <breathing_type>
```

**Damage Testing:**
```
breathingsystem_test_damage <form_id>
```

**Effects Testing:**
```
breathingsystem_test_effects <effect_type> [form_id]
```

**Combat Testing:**
```
breathingsystem_test_combat <target_name> <form_id>
```

**Status Effects:**
```
breathingsystem_test_status <effect_type>
```

**Menu Testing:**
```
breathingsystem_menu <menu_type>
```

**Balance Testing:**
```
breathingsystem_balance <category> <key> <value>
breathingsystem_balance_report
```

**Logging:**
```
breathingsystem_log_level <level>
breathingsystem_logs [count] [level]
```

## Performance Testing

### Load Testing
1. Spawn multiple players
2. Have all players use breathing system simultaneously
3. Monitor server performance
4. Check for memory leaks

### Stress Testing
1. Rapidly use forms and abilities
2. Test with maximum players
3. Monitor logging system
4. Check file I/O performance

## Expected Performance

### Server Load
- Minimal impact on server performance
- Efficient memory usage
- Fast response times

### Client Experience
- Smooth HUD updates
- Responsive menus
- Clear visual feedback

### Admin Tools
- Real-time balance adjustments
- Comprehensive logging
- Easy configuration management

## Success Criteria

### Phase 1-2: Core Structure
- ✅ All modules load without errors
- ✅ Player data is properly managed
- ✅ Breathing types and forms are registered

### Phase 3-4: Mechanics and Progression
- ✅ Stamina and concentration work correctly
- ✅ Cooldowns function properly
- ✅ Training and XP systems work
- ✅ Progression unlocks function

### Phase 5-6: Effects and Combat
- ✅ Visual effects display correctly
- ✅ Combat mechanics work
- ✅ Status effects apply properly
- ✅ PvP integration functions

### Phase 7-8: UI and Admin
- ✅ HUD displays real-time data
- ✅ Menus are functional
- ✅ Admin tools work correctly
- ✅ Configuration system functions

## Conclusion

The BreathingSystem addon is now complete with all 8 phases implemented. The system provides:

- **Complete breathing system** with 5 elemental types
- **34 unique forms** across all breathing types
- **Comprehensive mechanics** for stamina, concentration, and progression
- **Visual and audio effects** for immersive gameplay
- **Combat integration** with PvP and status effects
- **User-friendly UI** with menus and HUD
- **Admin tools** for configuration and balance

The addon is ready for production use and can be easily extended with additional breathing types, forms, and features.
