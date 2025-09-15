--[[
    BreathingSystem - Quick Menu
    ============================
    
    Provides a quick access menu for all breathing system commands.
]]

-- Only run on server
if not SERVER then return end

-- Quick menu command
concommand.Add("breathingsystem_menu", function(ply, cmd, args)
    if not IsValid(ply) then
        print("Menu command must be run by a player")
        return
    end
    
    ply:ChatPrint("========================================")
    ply:ChatPrint("BREATHINGSYSTEM QUICK MENU")
    ply:ChatPrint("========================================")
    ply:ChatPrint("")
    ply:ChatPrint("BASIC COMMANDS:")
    ply:ChatPrint("  !bs test - Check your player data")
    ply:ChatPrint("  !bs types - List all breathing types")
    ply:ChatPrint("  !bs set <type> - Set your breathing type")
    ply:ChatPrint("  !bs forms <type> - List forms for a type")
    ply:ChatPrint("")
    ply:ChatPrint("TESTING COMMANDS:")
    ply:ChatPrint("  !bs damage <form> - Test damage calculation")
    ply:ChatPrint("  !bs effects <type> - Test effects (particles/sounds/animations)")
    ply:ChatPrint("  !bs autotest - Run full system test")
    ply:ChatPrint("")
    ply:ChatPrint("QUICK SETUP:")
    ply:ChatPrint("  !bs quickstart - Set up water breathing with level 5")
    ply:ChatPrint("  !bs demo - Run a demonstration")
    ply:ChatPrint("")
    ply:ChatPrint("========================================")
    ply:ChatPrint("Type any command or 'breathingsystem_menu' for this menu")
end)

-- Chat command handler for easier access
hook.Add("PlayerSay", "BreathingSystem_ChatCommands", function(ply, text, team)
    local lower = string.lower(text)
    
    -- Check if it's a breathing system command
    if string.sub(lower, 1, 4) == "!bs " then
        local args = string.Explode(" ", string.sub(text, 5))
        local command = args[1]
        table.remove(args, 1)
        
        if command == "test" then
            ply:ConCommand("breathingsystem_test")
        elseif command == "types" then
            ply:ConCommand("breathingsystem_list_types")
        elseif command == "set" then
            if args[1] then
                ply:ConCommand("breathingsystem_set me " .. args[1])
            else
                ply:ChatPrint("Usage: !bs set <type>")
            end
        elseif command == "forms" then
            if args[1] then
                ply:ConCommand("breathingsystem_list_forms " .. args[1])
            else
                ply:ChatPrint("Usage: !bs forms <type>")
            end
        elseif command == "damage" then
            if args[1] then
                ply:ConCommand("breathingsystem_test_damage " .. args[1])
            else
                ply:ChatPrint("Usage: !bs damage <form_id>")
            end
        elseif command == "effects" then
            if args[1] then
                ply:ConCommand("breathingsystem_test_effects " .. args[1])
            else
                ply:ConCommand("breathingsystem_test_effects particles")
            end
        elseif command == "autotest" then
            ply:ConCommand("breathingsystem_autotest")
        elseif command == "quickstart" then
            ply:ConCommand("breathingsystem_quickstart")
        elseif command == "demo" then
            ply:ConCommand("breathingsystem_demo")
        elseif command == "menu" or command == "help" then
            ply:ConCommand("breathingsystem_menu")
        else
            ply:ChatPrint("Unknown command: " .. command)
            ply:ChatPrint("Type '!bs menu' for help")
        end
        
        return ""  -- Suppress the chat message
    end
    
    -- Quick help trigger
    if lower == "!bs" or lower == "!breathing" then
        ply:ConCommand("breathingsystem_menu")
        return ""
    end
end)

-- Quick start command - sets up a player instantly for testing
concommand.Add("breathingsystem_quickstart", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[BreathingSystem] Quick Start Activated!")
    
    -- Set breathing type to water
    BreathingSystem.SetPlayerBreathing(ply, "water")
    
    -- Update player data
    local data = BreathingSystem.GetPlayerData(ply)
    if data then
        data.level = 5
        data.xp = 500
        data.stamina = 100
        data.max_stamina = 150
        data.concentration = 50
        ply:ChatPrint("  ✓ Set to Water Breathing")
        ply:ChatPrint("  ✓ Level set to 5")
        ply:ChatPrint("  ✓ Stats boosted")
    end
    
    -- Test effects
    if BreathingSystem.Particles then
        BreathingSystem.Particles.CreateBreathingTypeEffect(ply, "water")
        ply:ChatPrint("  ✓ Particle effects activated")
    end
    
    ply:ChatPrint("[BreathingSystem] Quick Start Complete! You're ready to test.")
end)

-- Demo command - runs a demonstration
concommand.Add("breathingsystem_demo", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[BreathingSystem] Starting demonstration...")
    
    local step = 0
    timer.Create("BreathingSystem_Demo_" .. ply:SteamID(), 2, 6, function()
        if not IsValid(ply) then 
            timer.Remove("BreathingSystem_Demo_" .. ply:SteamID())
            return 
        end
        
        step = step + 1
        
        if step == 1 then
            ply:ChatPrint("[DEMO] Step 1: Showing your current stats...")
            ply:ConCommand("breathingsystem_test")
        elseif step == 2 then
            ply:ChatPrint("[DEMO] Step 2: Listing available breathing types...")
            ply:ConCommand("breathingsystem_list_types")
        elseif step == 3 then
            ply:ChatPrint("[DEMO] Step 3: Setting breathing type to Water...")
            ply:ConCommand("breathingsystem_set me water")
        elseif step == 4 then
            ply:ChatPrint("[DEMO] Step 4: Showing Water breathing forms...")
            ply:ConCommand("breathingsystem_list_forms water")
        elseif step == 5 then
            ply:ChatPrint("[DEMO] Step 5: Testing particle effects...")
            ply:ConCommand("breathingsystem_test_effects particles")
        elseif step == 6 then
            ply:ChatPrint("[DEMO] Demo complete! Type '!bs menu' for more commands.")
        end
    end)
end)

print("[BreathingSystem.QuickMenu] Quick menu system loaded")
