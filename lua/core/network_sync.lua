-- Add this to the end of player_registry.lua to sync data to client
-- This should be added at the end of the SetPlayerBreathing function

-- Add network syncing for HUD
hook.Add("BreathingSystem_BreathingTypeChanged", "BreathingSystem_SyncToClient", function(ply, breathingType)
    if not IsValid(ply) then return end
    ply:SetNWString("BreathingType", breathingType or "none")
end)

hook.Add("BreathingSystem_PlayerDataUpdated", "BreathingSystem_SyncDataToClient", function(ply, key, value)
    if not IsValid(ply) then return end
    
    if key == "level" then
        ply:SetNWInt("BreathingLevel", value or 1)
    elseif key == "stamina" then
        ply:SetNWInt("BreathingStamina", value or 100)
    elseif key == "max_stamina" then
        ply:SetNWInt("BreathingMaxStamina", value or 100)
    end
end)

-- Sync on player spawn
hook.Add("PlayerSpawn", "BreathingSystem_SyncOnSpawn", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        
        local data = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if data then
            ply:SetNWString("BreathingType", data.breathing_type or "none")
            ply:SetNWInt("BreathingLevel", data.level or 1)
            ply:SetNWInt("BreathingStamina", data.stamina or 100)
            ply:SetNWInt("BreathingMaxStamina", data.max_stamina or 100)
        end
    end)
end)

print("[BreathingSystem] Network syncing added to player registry")
