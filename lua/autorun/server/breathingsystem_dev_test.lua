--[[
    BreathingSystem - Development Test Suite
    ========================================
    
    Place this file in lua/autorun/server/ to automatically test the addon.
    This creates easy keybinds and aliases for testing.
]]

-- Only run on server
if not SERVER then return end

-- Create console aliases for easier testing
if game.ConsoleCommand then
    -- Short aliases for common commands
    game.ConsoleCommand("alias bs_test \"breathingsystem_test\"\n")
    game.ConsoleCommand("alias bs_types \"breathingsystem_list_types\"\n")
    game.ConsoleCommand("alias bs_water \"breathingsystem_set me water\"\n")
    game.ConsoleCommand("alias bs_forms \"breathingsystem_list_forms water\"\n")
    game.ConsoleCommand("alias bs_quick \"breathingsystem_quickstart\"\n")
    game.ConsoleCommand("alias bs_demo \"breathingsystem_demo\"\n")
    game.ConsoleCommand("alias bs_auto \"breathingsystem_autotest\"\n")
    game.ConsoleCommand("alias bs_menu \"breathingsystem_menu\"\n")
end

-- Create test keybinds (F6-F9 keys)
hook.Add("PlayerButtonDown", "BreathingSystem_TestKeys", function(ply, button)
    -- F6 = Quick test
    if button == KEY_F6 then
        ply:ConCommand("breathingsystem_test")
        ply:ChatPrint("[F6] Running player test...")
    
    -- F7 = Quick start
    elseif button == KEY_F7 then
        ply:ConCommand("breathingsystem_quickstart")
        ply:ChatPrint("[F7] Quick start activated!")
    
    -- F8 = Demo
    elseif button == KEY_F8 then
        ply:ConCommand("breathingsystem_demo")
        ply:ChatPrint("[F8] Starting demo...")
    
    -- F9 = Menu
    elseif button == KEY_F9 then
        ply:ConCommand("breathingsystem_menu")
        ply:ChatPrint("[F9] Opening menu...")
    end
end)

-- Automated test sequence
concommand.Add("breathingsystem_test_all", function(ply, cmd, args)
    local isConsole = not IsValid(ply)
    
    local function output(msg)
        if isConsole then
            print(msg)
        else
            ply:ChatPrint(msg)
        end
    end
    
    output("========================================")
    output("RUNNING COMPLETE TEST SEQUENCE")
    output("========================================")
    
    local tests = {
        {"breathingsystem_test", "Player data test"},
        {"breathingsystem_list_types", "List breathing types"},
        {"breathingsystem_set me water", "Set breathing type"},
        {"breathingsystem_list_forms water", "List water forms"},
        {"breathingsystem_test_damage water_surface_slash", "Test damage calculation"},
        {"breathingsystem_test_effects particles", "Test particle effects"},
        {"breathingsystem_test_effects sounds", "Test sound effects"},
        {"breathingsystem_test_effects animations", "Test animations"}
    }
    
    local delay = 0
    for i, test in ipairs(tests) do
        timer.Simple(delay, function()
            output("")
            output("[TEST " .. i .. "] " .. test[2])
            if isConsole then
                game.ConsoleCommand(test[1] .. "\n")
            else
                ply:ConCommand(test[1])
            end
        end)
        delay = delay + 1.5
    end
    
    timer.Simple(delay, function()
        output("")
        output("========================================")
        output("TEST SEQUENCE COMPLETE")
        output("========================================")
    end)
end)

-- Create a test config that runs on map change
hook.Add("InitPostEntity", "BreathingSystem_AutoConfig", function()
    print("========================================")
    print("BREATHINGSYSTEM TEST CONFIGURATION")
    print("========================================")
    print("")
    print("CONSOLE ALIASES CREATED:")
    print("  bs_test  - Test player data")
    print("  bs_types - List breathing types")
    print("  bs_water - Set water breathing")
    print("  bs_forms - List water forms")
    print("  bs_quick - Quick start setup")
    print("  bs_demo  - Run demonstration")
    print("  bs_auto  - Run auto test")
    print("  bs_menu  - Show menu")
    print("")
    print("KEYBINDS:")
    print("  F6 - Test player data")
    print("  F7 - Quick start")
    print("  F8 - Run demo")
    print("  F9 - Show menu")
    print("")
    print("CHAT COMMANDS:")
    print("  !bs - Show menu")
    print("  !bs test - Test player data")
    print("  !bs quickstart - Quick setup")
    print("  !bs demo - Run demo")
    print("")
    print("========================================")
end)

print("[BreathingSystem] Development test suite loaded")
