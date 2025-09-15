-- BreathingSystem Local Server Auto-Setup
-- This file automatically configures everything for local testing

-- This runs on both server and client since you're the host
hook.Add("InitPostEntity", "BreathingSystem_LocalSetup", function()
    -- Wait a bit for everything to load
    timer.Simple(3, function()
        print("========================================")
        print("BREATHINGSYSTEM LOCAL SERVER SETUP")
        print("========================================")
        
        if SERVER then
            print("[SERVER] Configuring host player...")
            
            -- Get the local player (you)
            local hostPlayer = player.GetAll()[1]
            
            if IsValid(hostPlayer) then
                -- Initialize player data
                if BreathingSystem and BreathingSystem.PlayerRegistry then
                    BreathingSystem.PlayerRegistry.RegisterPlayer(hostPlayer)
                end
                
                -- Set breathing data
                local data = BreathingSystem and BreathingSystem.GetPlayerData and BreathingSystem.GetPlayerData(hostPlayer)
                if data then
                    data.breathing_type = "water"
                    data.level = 5
                    data.xp = 500
                    data.stamina = 100
                    data.max_stamina = 150
                    data.concentration = 50
                end
                
                -- Sync to client (yourself)
                hostPlayer:SetNWString("BreathingType", "water")
                hostPlayer:SetNWInt("BreathingLevel", 5)
                hostPlayer:SetNWInt("BreathingStamina", 100)
                hostPlayer:SetNWInt("BreathingMaxStamina", 150)
                
                print("[SERVER] Host player configured with Water Breathing")
                
                -- Send message to yourself
                hostPlayer:ChatPrint("========================================")
                hostPlayer:ChatPrint("BREATHINGSYSTEM AUTO-CONFIGURED")
                hostPlayer:ChatPrint("========================================")
                hostPlayer:ChatPrint("✓ Breathing Type: Water")
                hostPlayer:ChatPrint("✓ Level: 5")
                hostPlayer:ChatPrint("✓ Stamina: 100/150")
                hostPlayer:ChatPrint("✓ HUD should be visible")
                hostPlayer:ChatPrint("")
                hostPlayer:ChatPrint("Commands:")
                hostPlayer:ChatPrint("  F6 - Test your data")
                hostPlayer:ChatPrint("  F7 - Quick start")
                hostPlayer:ChatPrint("  F8 - Demo")
                hostPlayer:ChatPrint("  F9 - Menu")
                hostPlayer:ChatPrint("========================================")
            end
        end
        
        if CLIENT then
            -- Force enable HUD on client
            timer.Simple(1, function()
                print("[CLIENT] Enabling HUD display...")
                
                -- Make sure HUD is enabled
                if hook.GetTable()["HUDPaint"] and hook.GetTable()["HUDPaint"]["BreathingSystem_HUD"] then
                    print("[CLIENT] HUD hook is active")
                else
                    print("[CLIENT] HUD hook not found, check if HUD file loaded")
                end
                
                -- Check if we have data
                local ply = LocalPlayer()
                if IsValid(ply) then
                    local breathingType = ply:GetNWString("BreathingType", "none")
                    local level = ply:GetNWInt("BreathingLevel", 1)
                    print("[CLIENT] Current data: " .. breathingType .. " Level " .. level)
                    
                    if breathingType == "none" then
                        print("[CLIENT] No data yet, waiting for sync...")
                        -- Force set test data if no sync after 2 seconds
                        timer.Simple(2, function()
                            if ply:GetNWString("BreathingType", "none") == "none" then
                                print("[CLIENT] Forcing test data...")
                                ply:SetNWString("BreathingType", "water")
                                ply:SetNWInt("BreathingLevel", 5)
                                ply:SetNWInt("BreathingStamina", 100)
                                ply:SetNWInt("BreathingMaxStamina", 150)
                            end
                        end)
                    end
                end
            end)
        end
    end)
end)

-- Auto-run on map change for local servers
hook.Add("Initialize", "BreathingSystem_LocalInit", function()
    if game.SinglePlayer() or (SERVER and not game.IsDedicated()) then
        print("[BreathingSystem] Local server detected - auto-setup enabled")
        
        -- Register a command to manually trigger setup
        concommand.Add("bs_local_setup", function(ply)
            if SERVER then
                local hostPlayer = IsValid(ply) and ply or player.GetAll()[1]
                
                if IsValid(hostPlayer) then
                    -- Set all the data
                    hostPlayer:SetNWString("BreathingType", "water")
                    hostPlayer:SetNWInt("BreathingLevel", 5)
                    hostPlayer:SetNWInt("BreathingStamina", 100)
                    hostPlayer:SetNWInt("BreathingMaxStamina", 150)
                    
                    hostPlayer:ChatPrint("[BreathingSystem] Local setup complete!")
                    hostPlayer:ChatPrint("  ✓ Water Breathing active")
                    hostPlayer:ChatPrint("  ✓ Level 5")
                    hostPlayer:ChatPrint("  ✓ HUD data synced")
                end
            end
        end)
    end
end)

-- Quick command that works on local servers
concommand.Add("bs_local", function(ply)
    if CLIENT then
        -- Client side - show status
        local lp = LocalPlayer()
        print("========================================")
        print("LOCAL CLIENT STATUS")
        print("========================================")
        print("Breathing: " .. lp:GetNWString("BreathingType", "none"))
        print("Level: " .. lp:GetNWInt("BreathingLevel", 1))
        print("Stamina: " .. lp:GetNWInt("BreathingStamina", 100))
        print("Max Stamina: " .. lp:GetNWInt("BreathingMaxStamina", 100))
        print("========================================")
        
        if lp:GetNWString("BreathingType", "none") == "none" then
            print("No data! Run 'bs_local_setup' to configure")
        end
    end
    
    if SERVER and IsValid(ply) then
        -- Server side - configure player
        ply:SetNWString("BreathingType", "water")
        ply:SetNWInt("BreathingLevel", 5)
        ply:SetNWInt("BreathingStamina", 100)
        ply:SetNWInt("BreathingMaxStamina", 150)
        
        ply:ChatPrint("[BreathingSystem] Configured for local testing!")
    end
end)

print("[BreathingSystem] Local server auto-setup loaded")
