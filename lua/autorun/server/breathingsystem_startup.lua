-- BreathingSystem Server Startup Config
-- This file runs automatically when the server starts

-- Wait for server to fully initialize
timer.Simple(10, function()
    print("========================================")
    print("BREATHINGSYSTEM - SERVER STARTUP")
    print("========================================")
    
    -- Run auto test
    if BreathingSystem and BreathingSystem.RunAutoTest then
        print("[BreathingSystem] Running startup tests...")
        BreathingSystem.RunAutoTest()
    end
    
    -- Set up demo player if in development
    timer.Simple(2, function()
        local players = player.GetAll()
        if #players > 0 then
            local ply = players[1]
            print("[BreathingSystem] Found player: " .. ply:Name())
            
            -- Auto-setup first player for testing
            if BreathingSystem.GetPlayerData then
                local data = BreathingSystem.GetPlayerData(ply)
                if data and data.breathing_type == "none" then
                    print("[BreathingSystem] Auto-configuring first player for testing...")
                    ply:ConCommand("breathingsystem_quickstart")
                end
            end
        end
    end)
    
    print("========================================")
    print("Type '!bs' in chat for quick menu")
    print("Or 'breathingsystem_menu' in console")
    print("========================================")
end)

-- Notify players when they join
hook.Add("PlayerInitialSpawn", "BreathingSystem_WelcomeMessage", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            ply:ChatPrint("========================================")
            ply:ChatPrint("Welcome to BreathingSystem!")
            ply:ChatPrint("Type '!bs' in chat for commands")
            ply:ChatPrint("Type '!bs quickstart' for instant setup")
            ply:ChatPrint("Type '!bs demo' for a demonstration")
            ply:ChatPrint("========================================")
        end
    end)
end)

print("[BreathingSystem] Server startup config loaded")
