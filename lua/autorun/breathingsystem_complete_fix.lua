-- BreathingSystem Complete Fix
-- This ensures everything works properly

if SERVER then
    -- Fix for server-side
    print("[BreathingSystem] Applying server-side fixes...")
    
    -- Ensure the quickstart command works
    concommand.Add("bs_fix", function(ply, cmd, args)
        if not IsValid(ply) then
            print("This command must be run by a player, not the server console")
            print("Use: breathingsystem_quickstart_all to setup all players")
            return
        end
        
        print("[BreathingSystem] Fixing player: " .. ply:Name())
        
        -- Initialize player data if needed
        if BreathingSystem and BreathingSystem.PlayerRegistry then
            BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
        end
        
        -- Set player data
        local data = BreathingSystem and BreathingSystem.GetPlayerData and BreathingSystem.GetPlayerData(ply)
        if data then
            data.breathing_type = "water"
            data.level = 5
            data.xp = 500
            data.stamina = 100
            data.max_stamina = 150
            data.concentration = 50
        end
        
        -- Network to client for HUD
        ply:SetNWString("BreathingType", "water")
        ply:SetNWInt("BreathingLevel", 5)
        ply:SetNWInt("BreathingStamina", 100)
        ply:SetNWInt("BreathingMaxStamina", 150)
        
        ply:ChatPrint("========================================")
        ply:ChatPrint("[BreathingSystem] Fixed and configured!")
        ply:ChatPrint("  ✓ Breathing Type: Water")
        ply:ChatPrint("  ✓ Level: 5")
        ply:ChatPrint("  ✓ Stamina: 100/150")
        ply:ChatPrint("  ✓ HUD data synced")
        ply:ChatPrint("========================================")
    end)
    
    -- Command to setup all players at once
    concommand.Add("breathingsystem_quickstart_all", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                -- Initialize player data
                if BreathingSystem and BreathingSystem.PlayerRegistry then
                    BreathingSystem.PlayerRegistry.RegisterPlayer(player)
                end
                
                -- Set data
                local data = BreathingSystem and BreathingSystem.GetPlayerData and BreathingSystem.GetPlayerData(player)
                if data then
                    data.breathing_type = "water"
                    data.level = 5
                    data.xp = 500
                    data.stamina = 100
                    data.max_stamina = 150
                    data.concentration = 50
                end
                
                -- Network to client
                player:SetNWString("BreathingType", "water")
                player:SetNWInt("BreathingLevel", 5)
                player:SetNWInt("BreathingStamina", 100)
                player:SetNWInt("BreathingMaxStamina", 150)
                
                player:ChatPrint("[BreathingSystem] You've been set up with Water Breathing!")
                
                if isConsole then
                    print("Set up player: " .. player:Name())
                end
            end
        end
        
        local msg = "All players have been configured with Water Breathing"
        if isConsole then
            print(msg)
        else
            ply:ChatPrint(msg)
        end
    end)
    
    -- Simple status command
    concommand.Add("bs_status", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        if isConsole then
            print("========================================")
            print("BREATHINGSYSTEM STATUS")
            print("========================================")
            
            -- Check what's loaded
            print("Core System: " .. (BreathingSystem and "✓ Loaded" or "✗ Not loaded"))
            
            if BreathingSystem then
                print("PlayerRegistry: " .. (BreathingSystem.PlayerRegistry and "✓" or "✗"))
                print("BreathingTypes: " .. (BreathingSystem.BreathingTypes and "✓" or "✗"))
                print("Particles: " .. (BreathingSystem.Particles and "✓" or "✗"))
                print("Sounds: " .. (BreathingSystem.Sounds and "✓" or "✗"))
            end
            
            -- List players and their status
            print("")
            print("Players:")
            for _, player in ipairs(player.GetAll()) do
                local breathType = player:GetNWString("BreathingType", "none")
                local level = player:GetNWInt("BreathingLevel", 1)
                print("  " .. player:Name() .. " - " .. breathType .. " (Level " .. level .. ")")
            end
            
            print("========================================")
        else
            ply:ChatPrint("========================================")
            ply:ChatPrint("YOUR BREATHING SYSTEM STATUS")
            ply:ChatPrint("========================================")
            ply:ChatPrint("Breathing Type: " .. ply:GetNWString("BreathingType", "none"))
            ply:ChatPrint("Level: " .. ply:GetNWInt("BreathingLevel", 1))
            ply:ChatPrint("Stamina: " .. ply:GetNWInt("BreathingStamina", 100) .. "/" .. ply:GetNWInt("BreathingMaxStamina", 100))
            ply:ChatPrint("========================================")
            ply:ChatPrint("Use 'bs_fix' to setup Water Breathing")
        end
    end)
    
    print("[BreathingSystem] Fix commands registered:")
    print("  bs_fix - Fix and setup player with Water Breathing")
    print("  bs_status - Check system and player status")
    print("  breathingsystem_quickstart_all - Setup all players")
    
end

if CLIENT then
    -- Client-side HUD fix
    print("[BreathingSystem] Client-side HUD fix loading...")
    
    -- Simple command to check HUD data
    concommand.Add("bs_hud_check", function()
        local ply = LocalPlayer()
        print("========================================")
        print("HUD DATA CHECK")
        print("========================================")
        print("Breathing Type: " .. ply:GetNWString("BreathingType", "none"))
        print("Level: " .. ply:GetNWInt("BreathingLevel", 1))
        print("Stamina: " .. ply:GetNWInt("BreathingStamina", 100))
        print("Max Stamina: " .. ply:GetNWInt("BreathingMaxStamina", 100))
        print("========================================")
        print("If all show default values, run 'bs_fix' in console")
    end)
end

print("[BreathingSystem] Complete fix loaded")
