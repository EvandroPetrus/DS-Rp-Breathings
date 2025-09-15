--[[
    BreathingSystem - HUD System
    ===========================
    
    This module handles the HUD display for stamina, cooldowns, concentration.
    Provides real-time updates and visual feedback for players.
    
    Responsibilities:
    - Display stamina and concentration bars
    - Show cooldown timers
    - Display current breathing type and form
    - Provide visual feedback for status effects
    - Update in real-time with server state
    
    Public API:
    - BreathingSystem.HUD.UpdateHUD(ply) - Update HUD for player
    - BreathingSystem.HUD.GetHUDData(ply) - Get HUD data for player
    - BreathingSystem.HUD.ShowHUD(ply) - Show HUD for player
    - BreathingSystem.HUD.HideHUD(ply) - Hide HUD for player
]]

-- Initialize HUD module
BreathingSystem.HUD = BreathingSystem.HUD or {}

-- HUD configuration
BreathingSystem.HUD.Config = {
    -- HUD position and size
    position = {
        x = 20,
        y = 20
    },
    
    -- Bar dimensions
    bars = {
        width = 200,
        height = 20,
        spacing = 5
    },
    
    -- Colors
    colors = {
        stamina = Color(0, 255, 0, 200),
        stamina_low = Color(255, 0, 0, 200),
        concentration = Color(0, 150, 255, 200),
        cooldown = Color(255, 255, 0, 200),
        background = Color(0, 0, 0, 150),
        text = Color(255, 255, 255, 255)
    },
    
    -- Update intervals
    update_interval = 0.1, -- 10 FPS
    network_interval = 1.0  -- 1 second
}

-- HUD data per player
BreathingSystem.HUD.PlayerData = BreathingSystem.HUD.PlayerData or {}

-- Get HUD data for player
function BreathingSystem.HUD.GetHUDData(ply)
    if not IsValid(ply) then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    local hudData = {
        -- Basic info
        player = ply,
        name = ply:Name(),
        
        -- Stamina
        stamina = data.stamina or 0,
        maxStamina = BreathingSystem.Stamina.GetMaxStamina(ply),
        staminaPercent = 0,
        
        -- Concentration
        concentration = data.concentration or 0,
        maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply),
        concentrationPercent = 0,
        
        -- Breathing type
        breathingType = data.current_breathing_type or "normal",
        breathingTypeName = "Normal Breathing",
        
        -- Level and XP
        level = BreathingSystem.Training.GetLevel(ply),
        xp = BreathingSystem.Training.GetXP(ply),
        xpProgress = BreathingSystem.Training.GetXPProgress(ply),
        
        -- Status effects
        statusEffects = BreathingSystem.StatusEffects.GetActiveEffects(ply),
        
        -- Combat status
        inCombat = BreathingSystem.Combat.IsInCombat(ply),
        
        -- Total concentration
        totalConcentration = BreathingSystem.Concentration.IsInTotalConcentration(ply),
        totalConcentrationStatus = BreathingSystem.Concentration.GetTotalConcentrationStatus(ply),
        
        -- Cooldowns
        cooldowns = BreathingSystem.Cooldowns.GetAllCooldowns(ply),
        
        -- Active effects
        activeParticles = BreathingSystem.Particles.GetActiveEffects(ply),
        activeAnimations = BreathingSystem.Animations.GetActiveAnimations(ply),
        activeSounds = BreathingSystem.Sounds.GetActiveSounds(ply)
    }
    
    -- Calculate percentages
    if hudData.maxStamina > 0 then
        hudData.staminaPercent = (hudData.stamina / hudData.maxStamina) * 100
    end
    
    if hudData.maxConcentration > 0 then
        hudData.concentrationPercent = (hudData.concentration / hudData.maxConcentration) * 100
    end
    
    -- Get breathing type name
    local breathingTypeData = BreathingSystem.Config.BreathingTypes[hudData.breathingType]
    if breathingTypeData then
        hudData.breathingTypeName = breathingTypeData.name or "Unknown"
    end
    
    return hudData
end

-- Update HUD for player
function BreathingSystem.HUD.UpdateHUD(ply)
    if not IsValid(ply) then return false end
    
    local hudData = BreathingSystem.HUD.GetHUDData(ply)
    if not hudData then return false end
    
    -- Store HUD data
    local steamid = ply:SteamID()
    BreathingSystem.HUD.PlayerData[steamid] = hudData
    
    -- Send HUD data to client
    BreathingSystem.HUD.SendHUDData(ply, hudData)
    
    return true
end

-- Send HUD data to client
function BreathingSystem.HUD.SendHUDData(ply, hudData)
    if not IsValid(ply) or not hudData then return false end
    
    -- Create network message
    local netData = {
        stamina = hudData.stamina,
        maxStamina = hudData.maxStamina,
        staminaPercent = hudData.staminaPercent,
        concentration = hudData.concentration,
        maxConcentration = hudData.maxConcentration,
        concentrationPercent = hudData.concentrationPercent,
        breathingType = hudData.breathingType,
        breathingTypeName = hudData.breathingTypeName,
        level = hudData.level,
        xp = hudData.xp,
        xpProgress = hudData.xpProgress,
        statusEffects = hudData.statusEffects,
        inCombat = hudData.inCombat,
        totalConcentration = hudData.totalConcentration,
        cooldowns = hudData.cooldowns
    }
    
    -- Send to client
    net.Start("BreathingSystem_HUDUpdate")
    net.WriteTable(netData)
    net.Send(ply)
    
    return true
end

-- Show HUD for player
function BreathingSystem.HUD.ShowHUD(ply)
    if not IsValid(ply) then return false end
    
    net.Start("BreathingSystem_HUDShow")
    net.Send(ply)
    
    return true
end

-- Hide HUD for player
function BreathingSystem.HUD.HideHUD(ply)
    if not IsValid(ply) then return false end
    
    net.Start("BreathingSystem_HUDHide")
    net.Send(ply)
    
    return true
end

-- Update HUD for all players
function BreathingSystem.HUD.UpdateAllPlayers()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) then
            BreathingSystem.HUD.UpdateHUD(ply)
        end
    end
end

-- Get HUD data for all players
function BreathingSystem.HUD.GetAllHUDData()
    local allData = {}
    
    for steamid, hudData in pairs(BreathingSystem.HUD.PlayerData) do
        if IsValid(hudData.player) then
            allData[steamid] = hudData
        else
            -- Clean up data for disconnected players
            BreathingSystem.HUD.PlayerData[steamid] = nil
        end
    end
    
    return allData
end

-- Initialize HUD system
if SERVER then
    -- Update HUD every 0.1 seconds
    timer.Create("BreathingSystem_HUDUpdate", BreathingSystem.HUD.Config.update_interval, 0, function()
        BreathingSystem.HUD.UpdateAllPlayers()
    end)
    
    -- Network messages
    util.AddNetworkString("BreathingSystem_HUDUpdate")
    util.AddNetworkString("BreathingSystem_HUDShow")
    util.AddNetworkString("BreathingSystem_HUDHide")
    
    print("[BreathingSystem.HUD] HUD system loaded")
end
