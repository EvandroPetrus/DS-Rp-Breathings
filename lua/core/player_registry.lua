--[[
    BreathingSystem Core - Player Registry Module
    ============================================
    
    This module handles player registration, data storage, and breathing state management.
    
    Responsibilities:
    - Register and manage player data
    - Store current breathing types per player
    - Track stamina and concentration (placeholders for future phases)
    - Provide player data API functions
    - Handle player cleanup on disconnect
    
    Public API:
    - BreathingSystem.GetPlayerData(ply) - Get player breathing data
    - BreathingSystem.SetPlayerBreathing(ply, typeID) - Set player breathing type
    - BreathingSystem.GetPlayerBreathing(ply) - Get current breathing type
    - BreathingSystem.RegisterPlayer(ply) - Register new player
    - BreathingSystem.UnregisterPlayer(ply) - Clean up player data
    
    Example Usage:
    - local data = BreathingSystem.GetPlayerData(ply)
    - BreathingSystem.SetPlayerBreathing(ply, "deep")
    - local currentType = BreathingSystem.GetPlayerBreathing(ply)
]]

-- Initialize player registry module
BreathingSystem.PlayerRegistry = BreathingSystem.PlayerRegistry or {}

-- Player data storage
BreathingSystem.PlayerRegistry.PlayerData = BreathingSystem.PlayerRegistry.PlayerData or {}

-- Initialize player data structure
local function InitializePlayerData(ply)
    local steamid = ply:SteamID()
    
    BreathingSystem.PlayerRegistry.PlayerData[steamid] = {
        -- Basic info
        player = ply,
        steamid = steamid,
        name = ply:Name(),
        
        -- Breathing state
        current_breathing_type = "normal",
        breathing_start_time = 0,
        breathing_duration = 0,
        
        -- Stats (placeholders for future phases)
        stamina = 100,
        max_stamina = 100,
        concentration = 100,
        max_concentration = 100,
        
        -- State flags
        is_breathing = false,
        is_registered = true,
        
        -- Timers
        last_update = CurTime(),
        cooldown_end = 0,
    }
    
    print("[BreathingSystem.PlayerRegistry] Registered player: " .. ply:Name() .. " (" .. steamid .. ")")
end

-- Register a player
function BreathingSystem.RegisterPlayer(ply)
    if not IsValid(ply) then
        print("[BreathingSystem.PlayerRegistry] Error: Invalid player")
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
function BreathingSystem.UnregisterPlayer(ply)
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
function BreathingSystem.GetPlayerData(ply)
    if not IsValid(ply) then
        return nil
    end
    
    local steamid = ply:SteamID()
    local data = BreathingSystem.PlayerRegistry.PlayerData[steamid]
    
    -- Auto-register if not found
    if not data then
        BreathingSystem.RegisterPlayer(ply)
        data = BreathingSystem.PlayerRegistry.PlayerData[steamid]
    end
    
    return data
end

-- Set player breathing type
function BreathingSystem.SetPlayerBreathing(ply, typeID)
    if not IsValid(ply) then
        print("[BreathingSystem.PlayerRegistry] Error: Invalid player")
        return false
    end
    
    if not typeID or type(typeID) ~= "string" then
        print("[BreathingSystem.PlayerRegistry] Error: Invalid breathing type ID")
        return false
    end
    
    -- Check if breathing type exists
    if not BreathingSystem.Config.BreathingTypeExists(typeID) then
        print("[BreathingSystem.PlayerRegistry] Error: Breathing type '" .. typeID .. "' does not exist")
        return false
    end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then
        print("[BreathingSystem.PlayerRegistry] Error: Could not get player data")
        return false
    end
    
    -- Check cooldown
    if data.cooldown_end > CurTime() then
        print("[BreathingSystem.PlayerRegistry] Error: Player is on cooldown")
        return false
    end
    
    -- Get breathing type data
    local breathingData = BreathingSystem.Config.GetBreathingType(typeID)
    if not breathingData then
        print("[BreathingSystem.PlayerRegistry] Error: Could not get breathing type data")
        return false
    end
    
    -- Set breathing type
    data.current_breathing_type = typeID
    data.breathing_start_time = CurTime()
    data.breathing_duration = breathingData.duration or 0
    data.is_breathing = true
    data.cooldown_end = CurTime() + (breathingData.cooldown or 0)
    
    print("[BreathingSystem.PlayerRegistry] Set " .. ply:Name() .. " breathing type to: " .. typeID)
    return true
end

-- Get current player breathing type
function BreathingSystem.GetPlayerBreathing(ply)
    if not IsValid(ply) then
        return nil
    end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then
        return nil
    end
    
    return data.current_breathing_type
end

-- Check if player is breathing
function BreathingSystem.IsPlayerBreathing(ply)
    if not IsValid(ply) then
        return false
    end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then
        return false
    end
    
    return data.is_breathing
end

-- Stop player breathing
function BreathingSystem.StopPlayerBreathing(ply)
    if not IsValid(ply) then
        return false
    end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then
        return false
    end
    
    data.is_breathing = false
    data.breathing_start_time = 0
    data.breathing_duration = 0
    
    print("[BreathingSystem.PlayerRegistry] Stopped breathing for: " .. ply:Name())
    return true
end

-- Get all registered players
function BreathingSystem.GetAllPlayers()
    local players = {}
    for steamid, data in pairs(BreathingSystem.PlayerRegistry.PlayerData) do
        if IsValid(data.player) then
            table.insert(players, data.player)
        end
    end
    return players
end

-- Update player data (called periodically)
function BreathingSystem.UpdatePlayerData(ply)
    if not IsValid(ply) then
        return false
    end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then
        return false
    end
    
    local currentTime = CurTime()
    data.last_update = currentTime
    
    -- Check if breathing duration has expired
    if data.is_breathing and data.breathing_duration > 0 then
        local elapsed = currentTime - data.breathing_start_time
        if elapsed >= data.breathing_duration then
            BreathingSystem.StopPlayerBreathing(ply)
        end
    end
    
    return true
end

-- Auto-register players on spawn
if SERVER then
    hook.Add("PlayerInitialSpawn", "BreathingSystem_RegisterPlayer", function(ply)
        timer.Simple(1, function() -- Delay to ensure player is fully loaded
            if IsValid(ply) then
                BreathingSystem.RegisterPlayer(ply)
            end
        end)
    end)
    
    -- Clean up on disconnect
    hook.Add("PlayerDisconnected", "BreathingSystem_UnregisterPlayer", function(ply)
        BreathingSystem.UnregisterPlayer(ply)
    end)
    
    -- Update player data periodically
    timer.Create("BreathingSystem_UpdatePlayers", 1, 0, function()
        for _, ply in pairs(player.GetAll()) do
            BreathingSystem.UpdatePlayerData(ply)
        end
    end)
end

print("[BreathingSystem.PlayerRegistry] Player registry module loaded")
