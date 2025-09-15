# BreathingSystem - Installation & Testing Guide

## Quick Fix for Your Issue

The problem was that the addon structure wasn't properly set up for Garry's Mod. I've fixed this by:

1. **Moved all files** from `lua/breathingsystem/` to `lua/` (GMod expects addon files directly in lua folder)
2. **Created proper autorun file** at `lua/autorun/server/breathingsystem_init.lua`
3. **Fixed all include paths** in the core init file
4. **Changed addon type** from "gamemode" to "tool"

## Installation Steps

1. **Copy the entire project folder** to your Garry's Mod addons directory:
   ```
   garrysmod/addons/breathingsystem/
   ```

2. **Your folder structure should now look like:**
   ```
   garrysmod/addons/breathingsystem/
   ├── addon.txt
   └── lua/
       ├── autorun/
       │   └── server/
       │       └── breathingsystem_init.lua
       ├── core/
       ├── breathing_types/
       ├── effects/
       ├── mechanics/
       ├── progression/
       ├── combat/
       ├── ui/
       └── admin/
   ```

3. **Restart your Garry's Mod server** or use `changelevel gm_construct`

## Testing Commands

Once installed, these commands should work:

**Basic Test:**
```
breathingsystem_test
```

**Set Breathing Type:**
```
breathingsystem_set <your_name> water
```

**List Types:**
```
breathingsystem_list_types
```

**List Forms:**
```
breathingsystem_list_forms water
```

**Test Effects:**
```
breathingsystem_test_effects particles
breathingsystem_test_effects sounds
breathingsystem_test_effects animations
```

## What's Fixed

- ✅ Proper addon structure for Garry's Mod
- ✅ All include paths corrected
- ✅ Autorun file created for automatic loading
- ✅ All test commands registered
- ✅ Particle effects system ready
- ✅ Sound effects system ready
- ✅ Animation system ready

The addon should now load properly and all commands should work!
