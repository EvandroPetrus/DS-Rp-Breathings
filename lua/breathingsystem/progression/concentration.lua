--[[
    BreathingSystem - Concentration System
    =====================================
    
    This module handles the "total concentration" special state and concentration mechanics.
    Manages concentration levels and special concentration abilities.
    
    Responsibilities:
    - Track concentration levels per player
    - Handle total concentration state
    - Manage concentration-based abilities
    - Provide concentration API functions
    
    Public API:
    - BreathingSystem.Concentration.EnterTotalConcentration(ply) - Enter total concentration
    - BreathingSystem.Concentration.ExitTotalConcentration(ply) - Exit total concentration
    - BreathingSystem.Concentration.IsInTotalConcentration(ply) - Check if in total concentration
    - BreathingSystem.Concentration.GetConcentrationLevel(ply) - Get concentration level
    - BreathingSystem.Concentration.ModifyConcentration(ply, amount) - Modify concentration
]]

-- Initialize concentration module
BreathingSystem.Concentration = BreathingSystem.Concentration or {}

-- Concentration configuration
BreathingSystem.Concentration.Config = {
    -- Concentration levels
    levels = {
        [0] = {name = "None", description = "No concentration", multiplier = 0.5},
        [1] = {name = "Low", description = "Basic concentration", multiplier = 0.8},
        [2] = {name = "Medium", description = "Good concentration", multiplier = 1.0},
        [3] = {name = "High", description = "Strong concentration", multiplier = 1.3},
        [4] = {name = "Perfect", description = "Perfect concentration", multiplier = 1.6},
        [5] = {name = "Total", description = "Total concentration", multiplier = 2.0}
    },
    
    -- Total concentration settings
    total_concentration = {
        duration = 60,            -- 1 minute duration
        cooldown = 300,           -- 5 minutes cooldown
        stamina_cost = 50,        -- Stamina cost to enter
        concentration_required = 80, -- Concentration required to enter
        effects = {
            damage_multiplier = 2.0,
            speed_multiplier = 1.5,
            stamina_regen_multiplier = 2.0,
            concentration_regen_multiplier = 3.0
        }
    },
    
    -- Concentration thresholds
    thresholds = {
        [1] = 20,  -- Low concentration
        [2] = 40,  -- Medium concentration
        [3] = 60,  -- High concentration
        [4] = 80,  -- Perfect concentration
        [5] = 95   -- Total concentration
    }
}

-- Enter total concentration
function BreathingSystem.Concentration.EnterTotalConcentration(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Check if already in total concentration
    if data.total_concentration then
        ply:ChatPrint("[BreathingSystem] You are already in total concentration!")
        return false
    end
    
    -- Check cooldown
    local lastUse = data.last_total_concentration_time or 0
    if CurTime() - lastUse < BreathingSystem.Concentration.Config.total_concentration.cooldown then
        local remaining = BreathingSystem.Concentration.Config.total_concentration.cooldown - (CurTime() - lastUse)
        ply:ChatPrint("[BreathingSystem] Total concentration is on cooldown for " .. math.ceil(remaining) .. " seconds!")
        return false
    end
    
    -- Check stamina requirement
    local staminaCost = BreathingSystem.Concentration.Config.total_concentration.stamina_cost
    if not BreathingSystem.Stamina.HasStamina(ply, staminaCost) then
        ply:ChatPrint("[BreathingSystem] Not enough stamina for total concentration!")
        return false
    end
    
    -- Check concentration requirement
    local concentrationRequired = BreathingSystem.Concentration.Config.total_concentration.concentration_required
    if not BreathingSystem.Stamina.HasConcentration(ply, concentrationRequired) then
        ply:ChatPrint("[BreathingSystem] Not enough concentration for total concentration!")
        return false
    end
    
    -- Enter total concentration
    data.total_concentration = true
    data.total_concentration_start_time = CurTime()
    data.last_total_concentration_time = CurTime()
    
    -- Drain stamina
    BreathingSystem.Stamina.DrainStamina(ply, staminaCost)
    
    print("[BreathingSystem.Concentration] " .. ply:Name() .. " entered total concentration")
    
    -- Notify player
    ply:ChatPrint("[BreathingSystem] You have entered total concentration!")
    
    -- Start total concentration timer
    timer.Create("BreathingSystem_TotalConcentration_" .. ply:SteamID(), BreathingSystem.Concentration.Config.total_concentration.duration, 1, function()
        if IsValid(ply) then
            BreathingSystem.Concentration.ExitTotalConcentration(ply)
        end
    end)
    
    -- Trigger event
    hook.Run("BreathingSystem_TotalConcentrationEntered", ply)
    
    return true
end

-- Exit total concentration
function BreathingSystem.Concentration.ExitTotalConcentration(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Check if in total concentration
    if not data.total_concentration then
        return false
    end
    
    -- Exit total concentration
    data.total_concentration = false
    data.total_concentration_start_time = nil
    
    print("[BreathingSystem.Concentration] " .. ply:Name() .. " exited total concentration")
    
    -- Notify player
    ply:ChatPrint("[BreathingSystem] You have exited total concentration!")
    
    -- Trigger event
    hook.Run("BreathingSystem_TotalConcentrationExited", ply)
    
    return true
end

-- Check if player is in total concentration
function BreathingSystem.Concentration.IsInTotalConcentration(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    return data.total_concentration or false
end

-- Get concentration level
function BreathingSystem.Concentration.GetConcentrationLevel(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local concentration = data.concentration or 0
    local maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply)
    local concentrationPercent = (concentration / maxConcentration) * 100
    
    -- Determine concentration level
    local level = 0
    for reqLevel, threshold in pairs(BreathingSystem.Concentration.Config.thresholds) do
        if concentrationPercent >= threshold then
            level = reqLevel
        end
    end
    
    return level
end

-- Get concentration level info
function BreathingSystem.Concentration.GetConcentrationLevelInfo(ply)
    if not IsValid(ply) then return nil end
    
    local level = BreathingSystem.Concentration.GetConcentrationLevel(ply)
    local levelInfo = BreathingSystem.Concentration.Config.levels[level]
    
    if not levelInfo then return nil end
    
    return {
        level = level,
        name = levelInfo.name,
        description = levelInfo.description,
        multiplier = levelInfo.multiplier
    }
end

-- Modify concentration
function BreathingSystem.Concentration.ModifyConcentration(ply, amount)
    if not IsValid(ply) or not amount then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local currentConcentration = data.concentration or 0
    local maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply)
    local newConcentration = math.Clamp(currentConcentration + amount, 0, maxConcentration)
    
    data.concentration = newConcentration
    
    return true
end

-- Get total concentration status
function BreathingSystem.Concentration.GetTotalConcentrationStatus(ply)
    if not IsValid(ply) then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    local isActive = data.total_concentration or false
    local startTime = data.total_concentration_start_time or 0
    local duration = BreathingSystem.Concentration.Config.total_concentration.duration
    local remainingTime = math.max(0, duration - (CurTime() - startTime))
    
    return {
        isActive = isActive,
        startTime = startTime,
        duration = duration,
        remainingTime = remainingTime,
        progressPercent = isActive and ((CurTime() - startTime) / duration) * 100 or 0
    }
end

-- Check if can enter total concentration
function BreathingSystem.Concentration.CanEnterTotalConcentration(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Check if already in total concentration
    if data.total_concentration then return false end
    
    -- Check cooldown
    local lastUse = data.last_total_concentration_time or 0
    if CurTime() - lastUse < BreathingSystem.Concentration.Config.total_concentration.cooldown then
        return false
    end
    
    -- Check stamina requirement
    local staminaCost = BreathingSystem.Concentration.Config.total_concentration.stamina_cost
    if not BreathingSystem.Stamina.HasStamina(ply, staminaCost) then
        return false
    end
    
    -- Check concentration requirement
    local concentrationRequired = BreathingSystem.Concentration.Config.total_concentration.concentration_required
    if not BreathingSystem.Stamina.HasConcentration(ply, concentrationRequired) then
        return false
    end
    
    return true
end

-- Get total concentration cooldown
function BreathingSystem.Concentration.GetTotalConcentrationCooldown(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local lastUse = data.last_total_concentration_time or 0
    local cooldown = BreathingSystem.Concentration.Config.total_concentration.cooldown
    local remaining = cooldown - (CurTime() - lastUse)
    
    return math.max(0, remaining)
end

-- Apply total concentration effects
function BreathingSystem.Concentration.ApplyTotalConcentrationEffects(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.total_concentration then return false end
    
    local effects = BreathingSystem.Concentration.Config.total_concentration.effects
    
    -- Apply damage multiplier
    data.damage_multiplier = effects.damage_multiplier
    
    -- Apply speed multiplier
    data.speed_multiplier = effects.speed_multiplier
    
    -- Apply stamina regen multiplier
    data.stamina_regen_multiplier = effects.stamina_regen_multiplier
    
    -- Apply concentration regen multiplier
    data.concentration_regen_multiplier = effects.concentration_regen_multiplier
    
    return true
end

-- Remove total concentration effects
function BreathingSystem.Concentration.RemoveTotalConcentrationEffects(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Remove effects
    data.damage_multiplier = nil
    data.speed_multiplier = nil
    data.stamina_regen_multiplier = nil
    data.concentration_regen_multiplier = nil
    
    return true
end

-- Update total concentration effects
function BreathingSystem.Concentration.UpdateTotalConcentrationEffects(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if data.total_concentration then
        BreathingSystem.Concentration.ApplyTotalConcentrationEffects(ply)
    else
        BreathingSystem.Concentration.RemoveTotalConcentrationEffects(ply)
    end
    
    return true
end

-- Initialize concentration system
if SERVER then
    -- Update total concentration effects for all players
    timer.Create("BreathingSystem_ConcentrationUpdate", 1, 0, function()
        for _, ply in pairs(player.GetAll()) do
            if IsValid(ply) then
                BreathingSystem.Concentration.UpdateTotalConcentrationEffects(ply)
            end
        end
    end)
    
    print("[BreathingSystem.Concentration] Concentration system loaded")
end
