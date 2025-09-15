# BreathingSystem - Automated Testing Guide

## 🚀 Quick Access Methods

### 1. **Chat Commands** (Easiest!)
Type these in game chat:
- `!bs` - Show help menu
- `!bs test` - Check your stats
- `!bs quickstart` - Instant setup with Water breathing
- `!bs demo` - Run automatic demonstration
- `!bs types` - List breathing types
- `!bs set water` - Set your breathing to water
- `!bs autotest` - Run full system test

### 2. **Keybinds** (While in-game)
- `F6` - Test player data
- `F7` - Quick start setup
- `F8` - Run demonstration
- `F9` - Show menu

### 3. **Console Aliases** (Short commands)
```
bs_test   - Test player data
bs_types  - List breathing types
bs_water  - Set water breathing
bs_forms  - List water forms
bs_quick  - Quick start setup
bs_demo   - Run demonstration
bs_auto   - Run auto test
bs_menu   - Show menu
```

### 4. **Automatic Testing**
The addon now includes:
- **Auto-test on server start** (5 seconds after start)
- **Welcome message** for new players
- **Auto-setup** for first player if needed
- **Complete test sequence** command

## 📋 Test Commands

### Quick Setup (Recommended First Step)
```
!bs quickstart
```
This will:
- Set your breathing type to Water
- Set your level to 5
- Give you XP and stats
- Activate particle effects

### Run Full Demo
```
!bs demo
```
This runs through all features automatically.

### Run Complete Test
```
breathingsystem_test_all
```
This tests every single feature in sequence.

## 🎯 What Happens Automatically

When you start your server:
1. **After 5 seconds**: Auto-test runs to verify all modules
2. **After 10 seconds**: Server startup config runs
3. **When you join**: Welcome message with instructions
4. **First player**: Auto-configured if no breathing type set

## 📁 Files Added

### Core Testing Files:
- `lua/core/autotest.lua` - Automated testing system
- `lua/core/quickmenu.lua` - Quick menu and chat commands
- `lua/autorun/server/breathingsystem_startup.lua` - Server startup config
- `lua/autorun/server/breathingsystem_dev_test.lua` - Development test suite

## 🔧 How to Use

### First Time Setup:
1. Start your server
2. Join the game
3. Type `!bs quickstart` in chat
4. You're ready to test!

### Daily Testing:
1. Join server (auto-test runs)
2. Press `F9` for menu
3. Use `!bs` commands in chat

### Full Testing:
```
breathingsystem_test_all
```
Or press `F8` for demo

## ✅ Everything is Automated!

You no longer need to:
- Type long commands
- Remember command names
- Manually test each feature
- Set up player data

Just use:
- `!bs` in chat for everything
- `F6-F9` keys for quick access
- Auto-tests run on server start

## 🎮 Quick Reference Card

```
INSTANT SETUP:     !bs quickstart
SHOW MENU:         !bs  (or F9)
RUN DEMO:          !bs demo  (or F8)
TEST DATA:         !bs test  (or F6)
QUICK SETUP:       F7
```

The system is now fully automated and easy to use!
