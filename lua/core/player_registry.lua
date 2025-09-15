--[[
    BreathingSystem - Player Registry
    =================================
    
    This module manages player data for the breathing system.
]]

-- Initialize player registry module
BreathingSystem.PlayerRegistry = BreathingSystem.PlayerRegistry or {}

-- Player data storage
BreathingSystem.PlayerRegistry.PlayerData = BreathingSystem.PlayerRegistry.PlayerData or {}

-- Initialize player data
local function InitializePlayerData(ply)
    if not IsValid(ply) then return nil end
    
    local steamid = ply:SteamID()
    
    -- Create default player data
    local data = {
        steamid = steamid,
        name = ply:Name(),
        breathing_type = "none",
        level = 1,
        xp = 0,
        stamina = 100,
        max_stamina = 100,
        concentration = 0,
        max_concentration = 100,
        cooldowns = {},
        forms_unlocked = {},
        total_concentration_active = false,
        training_session = nil,
        joined = os.time(),
        last_save = os.time()
    }
    
    -- Store player data
    BreathingSystem.PlayerRegistry.PlayerData[steamid] = data
    
    print("[BreathingSystem.PlayerRegistry] Registered player: " .. ply:Name() .. " (" .. steamid .. ")")
    
    -- Run hook
    hook.Run("BreathingSystem_PlayerRegistered", ply, data)
    
    return data
end

-- Register a player
function BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
    if not IsValid(ply) then
        return false
    end
    
    local steamid = ply:SteamID()
    
    -- Check if already registered
    if BreathingSystem.PlayerRegistry.PlayerData[steamid] then
        print("[BreathingSystem.PlayerRegistry] Player already registered: " .. ply:Name())
        return true
    end
    
    InitializePlayerData(ply)
    return true
end

-- Unregister a player
function BreathingSystem.PlayerRegistry.UnregisterPlayer(ply)
    if not IsValid(ply) then
        return false
    end
    
    local steamid = ply:SteamID()
    
    if BreathingSystem.PlayerRegistry.PlayerData[steamid] then
        BreathingSystem.PlayerRegistry.PlayerData[steamid] = nil
        print("[BreathingSystem.PlayerRegistry] Unregistered player: " .. ply:Name() .. " (" .. steamid .. ")")
        return true
    end
    
    return false
end

-- Get player data
function BreathingSystem.PlayerRegistry.GetPlayerData(ply)
    if not IsValid(ply) then
        return nil
    end
    
    local steamid = ply:SteamID()
    local data = BreathingSystem.PlayerRegistry.PlayerData[steamid]
    
    -- Auto-register if not found
    if not data then
        BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
        data = BreathingSystem.PlayerRegistry.PlayerData[steamid]
    end
    
    return data
end

-- Set player breathing type
function BreathingSystem.PlayerRegistry.SetPlayerBreathing(ply, typeID)
    if not IsValid(ply) then
        print("[BreathingSystem.PlayerRegistry] Error: Invalid player")
        return false
    end
    
    if not typeID or type(typeID) ~= "string" then
        print("[BreathingSystem.PlayerRegistry] Error: Invalid breathing type ID")
        return false
    end
    
    -- Get player data
    local data = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
    if not data then
        print("[BreathingSystem.PlayerRegistry] Error: Could not get player data")
        return false
    end
    
    -- Check if breathing type exists
    if BreathingSystem.Config and BreathingSystem.Config.GetBreathingType then
        local breathingData = BreathingSystem.Config.GetBreathingType(typeID)
        if not breathingData then
            print("[BreathingSystem.PlayerRegistry] Error: Breathing type not found: " .. typeID)
            return false
        end
    end
    
    -- Set breathing type
    data.breathing_type = typeID
    data.breathing_start_time = CurTime()
    
    print("[BreathingSystem.PlayerRegistry] Set " .. ply:Name() .. " breathing type to: " .. typeID)
    
    -- Run hook
    hook.Run("BreathingSystem_BreathingTypeChanged", ply, typeID)
    
    return true
end

-- Get all registered players
function BreathingSystem.PlayerRegistry.GetAllPlayers()
    local players = {}
    
    for steamid, data in pairs(BreathingSystem.PlayerRegistry.PlayerData) do
        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) then
            players[ply] = data
        end
    end
    
    return players
end

-- Save player data
function BreathingSystem.PlayerRegistry.SavePlayerData(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
    if not data then return false end
    
    data.last_save = os.time()
    
    -- Here you would save to file/database
    -- For now, just keep in memory
    
    print("[BreathingSystem.PlayerRegistry] Saved data for: " .. ply:Name())
    return true
end

-- Load player data
function BreathingSystem.PlayerRegistry.LoadPlayerData(ply)
    if not IsValid(ply) then return false end
    
    -- Here you would load from file/database
    -- For now, just initialize if not exists
    
    local steamid = ply:SteamID()
    if not BreathingSystem.PlayerRegistry.PlayerData[steamid] then
        InitializePlayerData(ply)
    end
    
    print("[BreathingSystem.PlayerRegistry] Loaded data for: " .. ply:Name())
    return true
end

-- Update player data
function BreathingSystem.PlayerRegistry.UpdatePlayerData(ply, key, value)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
    if not data then return false end
    
    data[key] = value
    
    -- Run hook
    hook.Run("BreathingSystem_PlayerDataUpdated", ply, key, value)
    
    return true
end

-- Clean up disconnected players
function BreathingSystem.PlayerRegistry.CleanupDisconnected()
    for steamid, data in pairs(BreathingSystem.PlayerRegistry.PlayerData) do
        local ply = player.GetBySteamID(steamid)
        if not IsValid(ply) then
            -- Save before removing
            -- Here you would save to file/database
            
            BreathingSystem.PlayerRegistry.PlayerData[steamid] = nil
            print("[BreathingSystem.PlayerRegistry] Cleaned up disconnected player data: " .. steamid)
        end
    end
end

-- Hooks
hook.Add("PlayerInitialSpawn", "BreathingSystem_RegisterPlayer", function(ply)
    BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
    BreathingSystem.PlayerRegistry.LoadPlayerData(ply)
end)

hook.Add("PlayerDisconnected", "BreathingSystem_UnregisterPlayer", function(ply)
    BreathingSystem.PlayerRegistry.SavePlayerData(ply)
    -- Don't immediately unregister, keep data for reconnection
    timer.Simple(300, function() -- Clean up after 5 minutes
        if not IsValid(ply) then
            BreathingSystem.PlayerRegistry.UnregisterPlayer(ply)
        end
    end)
end)

-- Auto-save timer
timer.Create("BreathingSystem_AutoSave", 60, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        BreathingSystem.PlayerRegistry.SavePlayerData(ply)
    end
end)

-- Update timer
timer.Create("BreathingSystem_UpdatePlayers", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        local data = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if data then
            -- Update stamina regeneration
            if data.stamina < data.max_stamina then
                data.stamina = math.min(data.max_stamina, data.stamina + 1)
            end
            
            -- Update concentration decay
            if data.concentration > 0 and not data.total_concentration_active then
                data.concentration = math.max(0, data.concentration - 0.5)
            end
        end
    end
end)

print("[BreathingSystem.PlayerRegistry] Player registry module loaded")
