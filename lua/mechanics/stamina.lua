--[[
    BreathingSystem - Stamina Mechanics
    ==================================
    
    This module handles stamina and concentration mechanics for players.
    Integrates with player_registry.lua to track and update player stats.
    
    Responsibilities:
    - Track stamina and concentration per player
    - Handle stamina drain/regeneration
    - Manage concentration bonuses and decay
    - Provide API for other systems to interact with stamina
    
    Public API:
    - BreathingSystem.Stamina.GetStamina(ply) - Get current stamina
    - BreathingSystem.Stamina.SetStamina(ply, amount) - Set stamina
    - BreathingSystem.Stamina.DrainStamina(ply, amount) - Drain stamina
    - BreathingSystem.Stamina.RegenerateStamina(ply) - Regenerate stamina
    - BreathingSystem.Stamina.GetConcentration(ply) - Get current concentration
    - BreathingSystem.Stamina.SetConcentration(ply, amount) - Set concentration
]]

-- Initialize stamina module
BreathingSystem.Stamina = BreathingSystem.Stamina or {}

-- Stamina configuration
BreathingSystem.Stamina.Config = {
    -- Base stamina values
    max_stamina = 100,
    stamina_regen_rate = 1, -- per second
    stamina_regen_delay = 2, -- seconds before regen starts
    
    -- Base concentration values
    max_concentration = 100,
    concentration_decay_rate = 0.5, -- per second
    concentration_decay_delay = 5, -- seconds before decay starts
    
    -- Breathing type modifiers
    stamina_modifiers = {
        water = 1.2, -- Water breathing regenerates stamina faster
        fire = 0.8,  -- Fire breathing drains stamina faster
        thunder = 0.9, -- Thunder breathing is moderate
        stone = 1.1, -- Stone breathing is efficient
        wind = 1.0,  -- Wind breathing is balanced
        normal = 1.0 -- Normal breathing is baseline
    },
    
    -- Concentration modifiers
    concentration_modifiers = {
        water = 1.3, -- Water breathing boosts concentration
        fire = 0.9,  -- Fire breathing reduces concentration
        thunder = 1.1, -- Thunder breathing slightly boosts concentration
        stone = 1.2, -- Stone breathing boosts concentration
        wind = 1.0,  -- Wind breathing is balanced
        normal = 1.0 -- Normal breathing is baseline
    }
}

-- Get player stamina
function BreathingSystem.Stamina.GetStamina(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    return data.stamina or 0
end

-- Set player stamina
function BreathingSystem.Stamina.SetStamina(ply, amount)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local maxStamina = BreathingSystem.Stamina.GetMaxStamina(ply)
    data.stamina = math.Clamp(amount, 0, maxStamina)
    
    -- Update last stamina change time
    data.last_stamina_change = CurTime()
    
    return true
end

-- Get maximum stamina for player
function BreathingSystem.Stamina.GetMaxStamina(ply)
    if not IsValid(ply) then return BreathingSystem.Stamina.Config.max_stamina end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return BreathingSystem.Stamina.Config.max_stamina end
    
    local baseMax = data.max_stamina or BreathingSystem.Stamina.Config.max_stamina
    local breathingType = data.current_breathing_type or "normal"
    local modifier = BreathingSystem.Stamina.Config.stamina_modifiers[breathingType] or 1.0
    
    return math.floor(baseMax * modifier)
end

-- Drain stamina
function BreathingSystem.Stamina.DrainStamina(ply, amount)
    if not IsValid(ply) or amount <= 0 then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local currentStamina = data.stamina or 0
    local newStamina = math.max(0, currentStamina - amount)
    
    data.stamina = newStamina
    data.last_stamina_change = CurTime()
    
    -- Check if stamina is depleted
    if newStamina <= 0 then
        BreathingSystem.Stamina.OnStaminaDepleted(ply)
    end
    
    return true
end

-- Regenerate stamina
function BreathingSystem.Stamina.RegenerateStamina(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local currentStamina = data.stamina or 0
    local maxStamina = BreathingSystem.Stamina.GetMaxStamina(ply)
    
    if currentStamina >= maxStamina then return false end
    
    local breathingType = data.current_breathing_type or "normal"
    local modifier = BreathingSystem.Stamina.Config.stamina_modifiers[breathingType] or 1.0
    local regenRate = BreathingSystem.Stamina.Config.stamina_regen_rate * modifier
    
    local newStamina = math.min(maxStamina, currentStamina + regenRate)
    data.stamina = newStamina
    
    return true
end

-- Get player concentration
function BreathingSystem.Stamina.GetConcentration(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    return data.concentration or 0
end

-- Set player concentration
function BreathingSystem.Stamina.SetConcentration(ply, amount)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply)
    data.concentration = math.Clamp(amount, 0, maxConcentration)
    
    -- Update last concentration change time
    data.last_concentration_change = CurTime()
    
    return true
end

-- Get maximum concentration for player
function BreathingSystem.Stamina.GetMaxConcentration(ply)
    if not IsValid(ply) then return BreathingSystem.Stamina.Config.max_concentration end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return BreathingSystem.Stamina.Config.max_concentration end
    
    local baseMax = data.max_concentration or BreathingSystem.Stamina.Config.max_concentration
    local breathingType = data.current_breathing_type or "normal"
    local modifier = BreathingSystem.Stamina.Config.concentration_modifiers[breathingType] or 1.0
    
    return math.floor(baseMax * modifier)
end

-- Apply concentration bonus
function BreathingSystem.Stamina.ApplyConcentrationBonus(ply, amount)
    if not IsValid(ply) or amount <= 0 then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local currentConcentration = data.concentration or 0
    local maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply)
    local newConcentration = math.min(maxConcentration, currentConcentration + amount)
    
    data.concentration = newConcentration
    data.last_concentration_change = CurTime()
    
    return true
end

-- Decay concentration
function BreathingSystem.Stamina.DecayConcentration(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local currentConcentration = data.concentration or 0
    if currentConcentration <= 0 then return false end
    
    local breathingType = data.current_breathing_type or "normal"
    local modifier = BreathingSystem.Stamina.Config.concentration_modifiers[breathingType] or 1.0
    local decayRate = BreathingSystem.Stamina.Config.concentration_decay_rate / modifier
    
    local newConcentration = math.max(0, currentConcentration - decayRate)
    data.concentration = newConcentration
    
    return true
end

-- Check if player has enough stamina
function BreathingSystem.Stamina.HasStamina(ply, amount)
    if not IsValid(ply) then return false end
    
    local currentStamina = BreathingSystem.Stamina.GetStamina(ply)
    return currentStamina >= amount
end

-- Check if player has enough concentration
function BreathingSystem.Stamina.HasConcentration(ply, amount)
    if not IsValid(ply) then return false end
    
    local currentConcentration = BreathingSystem.Stamina.GetConcentration(ply)
    return currentConcentration >= amount
end

-- Stamina depleted callback
function BreathingSystem.Stamina.OnStaminaDepleted(ply)
    if not IsValid(ply) then return end
    
    print("[BreathingSystem.Stamina] Player " .. ply:Name() .. " stamina depleted")
    
    -- Stop current breathing if stamina is depleted
    BreathingSystem.StopPlayerBreathing(ply)
    
    -- Apply stamina depletion effects
    ply:ChatPrint("[BreathingSystem] You are exhausted! Rest to recover stamina.")
end

-- Update stamina and concentration for all players
function BreathingSystem.Stamina.UpdateAllPlayers()
    for _, ply in pairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        
        local data = BreathingSystem.GetPlayerData(ply)
        if not data then continue end
        
        local currentTime = CurTime()
        
        -- Update stamina
        if data.stamina and data.stamina < BreathingSystem.Stamina.GetMaxStamina(ply) then
            local lastChange = data.last_stamina_change or 0
            if currentTime - lastChange >= BreathingSystem.Stamina.Config.stamina_regen_delay then
                BreathingSystem.Stamina.RegenerateStamina(ply)
            end
        end
        
        -- Update concentration
        if data.concentration and data.concentration > 0 then
            local lastChange = data.last_concentration_change or 0
            if currentTime - lastChange >= BreathingSystem.Stamina.Config.concentration_decay_delay then
                BreathingSystem.Stamina.DecayConcentration(ply)
            end
        end
    end
end

-- Initialize stamina system
if SERVER then
    -- Update stamina and concentration every second
    timer.Create("BreathingSystem_StaminaUpdate", 1, 0, function()
        BreathingSystem.Stamina.UpdateAllPlayers()
    end)
    
    print("[BreathingSystem.Stamina] Stamina mechanics loaded")
end
