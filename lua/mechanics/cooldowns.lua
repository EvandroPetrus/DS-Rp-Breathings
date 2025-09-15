--[[
    BreathingSystem - Cooldowns Mechanics
    ====================================
    
    This module handles cooldowns for breathing forms and techniques.
    Tracks individual cooldowns per form per player.
    
    Responsibilities:
    - Track cooldowns for each breathing form per player
    - Handle cooldown timers and expiration
    - Provide API for checking and managing cooldowns
    - Integrate with player_registry.lua
    
    Public API:
    - BreathingSystem.Cooldowns.IsOnCooldown(ply, formID) - Check if form is on cooldown
    - BreathingSystem.Cooldowns.GetCooldownTime(ply, formID) - Get remaining cooldown time
    - BreathingSystem.Cooldowns.SetCooldown(ply, formID, duration) - Set cooldown
    - BreathingSystem.Cooldowns.ClearCooldown(ply, formID) - Clear cooldown
    - BreathingSystem.Cooldowns.GetAllCooldowns(ply) - Get all cooldowns for player
]]

-- Initialize cooldowns module
BreathingSystem.Cooldowns = BreathingSystem.Cooldowns or {}

-- Cooldown configuration
BreathingSystem.Cooldowns.Config = {
    -- Global cooldown modifiers
    global_cooldown_modifier = 1.0,
    
    -- Breathing type cooldown modifiers
    breathing_type_modifiers = {
        water = 0.8,   -- Water breathing has shorter cooldowns
        fire = 1.2,    -- Fire breathing has longer cooldowns
        thunder = 0.9, -- Thunder breathing has slightly shorter cooldowns
        stone = 1.1,   -- Stone breathing has slightly longer cooldowns
        wind = 1.0,    -- Wind breathing has normal cooldowns
        normal = 1.0   -- Normal breathing is baseline
    },
    
    -- Form difficulty cooldown modifiers
    difficulty_modifiers = {
        [1] = 0.5, -- Easy forms have shorter cooldowns
        [2] = 0.7,
        [3] = 1.0, -- Medium forms have normal cooldowns
        [4] = 1.3,
        [5] = 1.6  -- Hard forms have longer cooldowns
    }
}

-- Check if a form is on cooldown for a player
function BreathingSystem.Cooldowns.IsOnCooldown(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local cooldowns = data.cooldowns or {}
    local cooldownEnd = cooldowns[formID]
    
    if not cooldownEnd then return false end
    
    return CurTime() < cooldownEnd
end

-- Get remaining cooldown time for a form
function BreathingSystem.Cooldowns.GetCooldownTime(ply, formID)
    if not IsValid(ply) or not formID then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local cooldowns = data.cooldowns or {}
    local cooldownEnd = cooldowns[formID]
    
    if not cooldownEnd then return 0 end
    
    local remaining = cooldownEnd - CurTime()
    return math.max(0, remaining)
end

-- Set cooldown for a form
function BreathingSystem.Cooldowns.SetCooldown(ply, formID, duration)
    if not IsValid(ply) or not formID or duration <= 0 then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Initialize cooldowns table if it doesn't exist
    if not data.cooldowns then
        data.cooldowns = {}
    end
    
    -- Apply modifiers
    local modifiedDuration = BreathingSystem.Cooldowns.ApplyModifiers(ply, formID, duration)
    
    -- Set cooldown end time
    data.cooldowns[formID] = CurTime() + modifiedDuration
    
    print("[BreathingSystem.Cooldowns] Set cooldown for " .. ply:Name() .. " form " .. formID .. " for " .. modifiedDuration .. " seconds")
    
    return true
end

-- Clear cooldown for a form
function BreathingSystem.Cooldowns.ClearCooldown(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.cooldowns then return false end
    
    data.cooldowns[formID] = nil
    
    print("[BreathingSystem.Cooldowns] Cleared cooldown for " .. ply:Name() .. " form " .. formID)
    
    return true
end

-- Get all cooldowns for a player
function BreathingSystem.Cooldowns.GetAllCooldowns(ply)
    if not IsValid(ply) then return {} end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return {} end
    
    local cooldowns = data.cooldowns or {}
    local activeCooldowns = {}
    
    for formID, cooldownEnd in pairs(cooldowns) do
        local remaining = cooldownEnd - CurTime()
        if remaining > 0 then
            activeCooldowns[formID] = remaining
        else
            -- Clean up expired cooldowns
            cooldowns[formID] = nil
        end
    end
    
    return activeCooldowns
end

-- Apply cooldown modifiers
function BreathingSystem.Cooldowns.ApplyModifiers(ply, formID, duration)
    if not IsValid(ply) or not formID then return duration end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return duration end
    
    local modifiedDuration = duration
    
    -- Apply global modifier
    modifiedDuration = modifiedDuration * BreathingSystem.Cooldowns.Config.global_cooldown_modifier
    
    -- Apply breathing type modifier
    local breathingType = data.current_breathing_type or "normal"
    local breathingModifier = BreathingSystem.Cooldowns.Config.breathing_type_modifiers[breathingType] or 1.0
    modifiedDuration = modifiedDuration * breathingModifier
    
    -- Apply form difficulty modifier
    local form = BreathingSystem.Forms.GetForm(formID)
    if form and form.difficulty then
        local difficultyModifier = BreathingSystem.Cooldowns.Config.difficulty_modifiers[form.difficulty] or 1.0
        modifiedDuration = modifiedDuration * difficultyModifier
    end
    
    return modifiedDuration
end

-- Check if player can use a form (not on cooldown)
function BreathingSystem.Cooldowns.CanUseForm(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    return not BreathingSystem.Cooldowns.IsOnCooldown(ply, formID)
end

-- Get cooldown info for a form
function BreathingSystem.Cooldowns.GetCooldownInfo(ply, formID)
    if not IsValid(ply) or not formID then return nil end
    
    local isOnCooldown = BreathingSystem.Cooldowns.IsOnCooldown(ply, formID)
    local remainingTime = BreathingSystem.Cooldowns.GetCooldownTime(ply, formID)
    
    return {
        isOnCooldown = isOnCooldown,
        remainingTime = remainingTime,
        canUse = not isOnCooldown
    }
end

-- Clear all cooldowns for a player
function BreathingSystem.Cooldowns.ClearAllCooldowns(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    data.cooldowns = {}
    
    print("[BreathingSystem.Cooldowns] Cleared all cooldowns for " .. ply:Name())
    
    return true
end

-- Update cooldowns for all players (cleanup expired ones)
function BreathingSystem.Cooldowns.UpdateAllPlayers()
    for _, ply in pairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        
        local data = BreathingSystem.GetPlayerData(ply)
        if not data then continue end
        
        if not data.cooldowns then continue end
        
        local currentTime = CurTime()
        local expiredForms = {}
        
        -- Check for expired cooldowns
        for formID, cooldownEnd in pairs(data.cooldowns) do
            if currentTime >= cooldownEnd then
                table.insert(expiredForms, formID)
            end
        end
        
        -- Remove expired cooldowns
        for _, formID in ipairs(expiredForms) do
            data.cooldowns[formID] = nil
        end
    end
end

-- Initialize cooldowns system
if SERVER then
    -- Update cooldowns every second
    timer.Create("BreathingSystem_CooldownsUpdate", 1, 0, function()
        BreathingSystem.Cooldowns.UpdateAllPlayers()
    end)
    
    print("[BreathingSystem.Cooldowns] Cooldowns mechanics loaded")
end
