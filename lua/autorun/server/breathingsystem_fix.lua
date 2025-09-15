-- Simple test to verify breathing system works
print("[BreathingSystem] Running simple verification test...")

-- Check if main table exists
if BreathingSystem then
    print("  ✓ BreathingSystem table exists")
    
    -- Check modules
    if BreathingSystem.PlayerRegistry then
        print("  ✓ PlayerRegistry loaded")
    else
        print("  ✗ PlayerRegistry missing")
    end
    
    if BreathingSystem.BreathingTypes then
        print("  ✓ BreathingTypes loaded")
        local types = BreathingSystem.BreathingTypes.GetAllTypes()
        print("    Found " .. table.Count(types) .. " breathing types")
    else
        print("  ✗ BreathingTypes missing")
    end
    
    -- Register the missing commands if modules exist
    if SERVER and BreathingSystem.PlayerRegistry then
        -- Quick start command
        if not concommand.GetTable()["breathingsystem_quickstart"] then
            concommand.Add("breathingsystem_quickstart", function(ply, cmd, args)
                if not IsValid(ply) then return end
                
                ply:ChatPrint("[BreathingSystem] Quick Start Activated!")
                
                -- Set breathing type to water
                if BreathingSystem.SetPlayerBreathing then
                    BreathingSystem.SetPlayerBreathing(ply, "water")
                end
                
                -- Update player data
                local data = BreathingSystem.GetPlayerData(ply)
                if data then
                    data.level = 5
                    data.xp = 500
                    data.stamina = 100
                    data.max_stamina = 150
                    data.concentration = 50
                    
                    -- Sync to client
                    ply:SetNWString("BreathingType", "water")
                    ply:SetNWInt("BreathingLevel", 5)
                    ply:SetNWInt("BreathingStamina", 100)
                    ply:SetNWInt("BreathingMaxStamina", 150)
                    
                    ply:ChatPrint("  ✓ Set to Water Breathing")
                    ply:ChatPrint("  ✓ Level set to 5")
                    ply:ChatPrint("  ✓ Stats boosted")
                end
                
                ply:ChatPrint("[BreathingSystem] Quick Start Complete!")
            end)
            print("  ✓ Registered breathingsystem_quickstart command")
        end
        
        -- Menu command
        if not concommand.GetTable()["breathingsystem_menu"] then
            concommand.Add("breathingsystem_menu", function(ply, cmd, args)
                if not IsValid(ply) then return end
                
                ply:ChatPrint("========================================")
                ply:ChatPrint("BREATHINGSYSTEM QUICK MENU")
                ply:ChatPrint("========================================")
                ply:ChatPrint("")
                ply:ChatPrint("WORKING COMMANDS:")
                ply:ChatPrint("  breathingsystem_test - Check your data")
                ply:ChatPrint("  breathingsystem_set me water - Set water breathing")
                ply:ChatPrint("  breathingsystem_list_types - List types")
                ply:ChatPrint("  breathingsystem_quickstart - Quick setup")
                ply:ChatPrint("")
                ply:ChatPrint("KEYBINDS:")
                ply:ChatPrint("  F6 - Test your data")
                ply:ChatPrint("  F7 - Quick start")
                ply:ChatPrint("")
                ply:ChatPrint("========================================")
            end)
            print("  ✓ Registered breathingsystem_menu command")
        end
        
        -- Demo command
        if not concommand.GetTable()["breathingsystem_demo"] then
            concommand.Add("breathingsystem_demo", function(ply, cmd, args)
                if not IsValid(ply) then return end
                
                ply:ChatPrint("[BreathingSystem] Starting demo...")
                ply:ConCommand("breathingsystem_test")
                timer.Simple(2, function()
                    if IsValid(ply) then
                        ply:ConCommand("breathingsystem_set me water")
                    end
                end)
                timer.Simple(4, function()
                    if IsValid(ply) then
                        ply:ConCommand("breathingsystem_list_types")
                    end
                end)
                timer.Simple(6, function()
                    if IsValid(ply) then
                        ply:ChatPrint("[BreathingSystem] Demo complete!")
                    end
                end)
            end)
            print("  ✓ Registered breathingsystem_demo command")
        end
    end
else
    print("  ✗ BreathingSystem table not found - addon not loaded")
end

print("[BreathingSystem] Verification test complete")
