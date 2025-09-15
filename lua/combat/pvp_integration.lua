--[[
    BreathingSystem - PvP Integration
    ================================
    
    This module handles PvP integration with GMod combat system.
    Integrates with TakeDamage, EntityTakeDamage hooks and combat mechanics.
    
    Responsibilities:
    - Handle damage integration with GMod combat
    - Manage PvP combat mechanics
    - Integrate with breathing system damage
    - Provide combat API functions
    
    Public API:
    - BreathingSystem.Combat.ApplyDamage(ply, target, formID) - Apply combat damage
    - BreathingSystem.Combat.HandleDamage(ply, dmgInfo) - Handle incoming damage
    - BreathingSystem.Combat.GetCombatStats(ply) - Get combat statistics
    - BreathingSystem.Combat.IsInCombat(ply) - Check if player is in combat
]]

-- Initialize combat module
BreathingSystem.Combat = BreathingSystem.Combat or {}

-- Combat configuration
BreathingSystem.Combat.Config = {
    -- PvP settings
    pvp_enabled = true,
    pvp_damage_multiplier = 0.8, -- PvP damage is reduced
    pvp_range_multiplier = 1.2,  -- PvP range is increased
    
    -- Combat mechanics
    combat_duration = 10,        -- Seconds to stay in combat
    combat_cooldown = 5,         -- Seconds before leaving combat
    combat_stamina_drain = 2,    -- Stamina drained per second in combat
    
    -- Damage types
    damage_types = {
        water = DMG_DROWN,       -- Water breathing does drowning damage
        fire = DMG_BURN,         -- Fire breathing does burn damage
        thunder = DMG_SHOCK,     -- Thunder breathing does shock damage
        stone = DMG_CRUSH,       -- Stone breathing does crush damage
        wind = DMG_SLASH,        -- Wind breathing does slash damage
        normal = DMG_GENERIC     -- Normal breathing does generic damage
    },
    
    -- Range settings
    range_settings = {
        water = 200,    -- Water breathing range
        fire = 300,     -- Fire breathing range
        thunder = 400,  -- Thunder breathing range
        stone = 150,    -- Stone breathing range
        wind = 250,     -- Wind breathing range
        normal = 100    -- Normal breathing range
    }
}

-- Combat data per player
BreathingSystem.Combat.PlayerData = BreathingSystem.Combat.PlayerData or {}

-- Apply combat damage
function BreathingSystem.Combat.ApplyDamage(ply, target, formID)
    if not IsValid(ply) or not IsValid(target) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Check if player can use the form
    if not BreathingSystem.Prerequisites.CanUseForm(ply, formID) then
        ply:ChatPrint("[BreathingSystem] You cannot use this form!")
        return false
    end
    
    -- Check cooldown
    if not BreathingSystem.Cooldowns.CanUseForm(ply, formID) then
        local cooldownTime = BreathingSystem.Cooldowns.GetCooldownTime(ply, formID)
        ply:ChatPrint("[BreathingSystem] Form is on cooldown for " .. math.ceil(cooldownTime) .. " seconds!")
        return false
    end
    
    -- Check stamina
    local form = BreathingSystem.Forms.GetForm(formID)
    if form and form.stamina_drain and form.stamina_drain > 0 then
        if not BreathingSystem.Stamina.HasStamina(ply, form.stamina_drain) then
            ply:ChatPrint("[BreathingSystem] Not enough stamina!")
            return false
        end
    end
    
    -- Calculate damage
    local damage = BreathingSystem.Damage.CalculateDamage(ply, formID, target)
    if damage <= 0 then return false end
    
    -- Apply PvP multiplier if target is a player
    if target:IsPlayer() then
        damage = damage * BreathingSystem.Combat.Config.pvp_damage_multiplier
    end
    
    -- Create damage info
    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(damage)
    dmgInfo:SetAttacker(ply)
    dmgInfo:SetInflictor(ply)
    
    -- Set damage type based on breathing type
    local breathingType = data.current_breathing_type or "normal"
    local damageType = BreathingSystem.Combat.Config.damage_types[breathingType] or DMG_GENERIC
    dmgInfo:SetDamageType(damageType)
    
    dmgInfo:SetDamagePosition(target:GetPos())
    
    -- Apply damage
    target:TakeDamageInfo(dmgInfo)
    
    -- Drain stamina
    if form and form.stamina_drain and form.stamina_drain > 0 then
        BreathingSystem.Stamina.DrainStamina(ply, form.stamina_drain)
    end
    
    -- Set cooldown
    if form and form.cooldown and form.cooldown > 0 then
        BreathingSystem.Cooldowns.SetCooldown(ply, formID, form.cooldown)
    end
    
    -- Enter combat
    BreathingSystem.Combat.EnterCombat(ply)
    if target:IsPlayer() then
        BreathingSystem.Combat.EnterCombat(target)
    end
    
    -- Create effects
    BreathingSystem.Particles.CreateDamageEffect(ply, target)
    BreathingSystem.Animations.PlayDamageAnimation(ply, target)
    BreathingSystem.Sounds.PlayDamageSound(ply, target)
    
    print("[BreathingSystem.Combat] " .. ply:Name() .. " dealt " .. damage .. " damage to " .. target:GetName() .. " using " .. formID)
    
    return true
end

-- Handle incoming damage
function BreathingSystem.Combat.HandleDamage(ply, dmgInfo)
    if not IsValid(ply) or not dmgInfo then return end
    
    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) then return end
    
    -- Check if attacker is using breathing system
    if attacker:IsPlayer() then
        local attackerData = BreathingSystem.GetPlayerData(attacker)
        if attackerData and attackerData.current_breathing_type then
            -- Apply breathing system damage modifiers
            local breathingType = attackerData.current_breathing_type
            local modifier = BreathingSystem.Combat.GetDamageModifier(attacker, breathingType)
            
            if modifier != 1.0 then
                dmgInfo:SetDamage(dmgInfo:GetDamage() * modifier)
            end
        end
    end
    
    -- Enter combat
    BreathingSystem.Combat.EnterCombat(ply)
    
    -- Apply damage reduction based on breathing type
    local data = BreathingSystem.GetPlayerData(ply)
    if data and data.current_breathing_type then
        local reduction = BreathingSystem.Combat.GetDamageReduction(ply, data.current_breathing_type)
        if reduction > 0 then
            dmgInfo:SetDamage(dmgInfo:GetDamage() * (1 - reduction))
        end
    end
end

-- Get damage modifier for breathing type
function BreathingSystem.Combat.GetDamageModifier(ply, breathingType)
    if not IsValid(ply) or not breathingType then return 1.0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 1.0 end
    
    local modifier = 1.0
    
    -- Apply breathing type modifier
    local breathingTypeData = BreathingSystem.Config.BreathingTypes[breathingType]
    if breathingTypeData and breathingTypeData.damage_modifier then
        modifier = modifier * breathingTypeData.damage_modifier
    end
    
    -- Apply total concentration modifier
    if BreathingSystem.Concentration.IsInTotalConcentration(ply) then
        modifier = modifier * 2.0
    end
    
    -- Apply stamina modifier
    local staminaPercent = (data.stamina or 0) / BreathingSystem.Stamina.GetMaxStamina(ply)
    if staminaPercent < 0.2 then
        modifier = modifier * 0.5 -- Low stamina reduces damage
    elseif staminaPercent > 0.8 then
        modifier = modifier * 1.2 -- High stamina increases damage
    end
    
    return modifier
end

-- Get damage reduction for breathing type
function BreathingSystem.Combat.GetDamageReduction(ply, breathingType)
    if not IsValid(ply) or not breathingType then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local reduction = 0
    
    -- Apply breathing type reduction
    if breathingType == "stone" then
        reduction = 0.3 -- Stone breathing provides 30% damage reduction
    elseif breathingType == "water" then
        reduction = 0.2 -- Water breathing provides 20% damage reduction
    elseif breathingType == "wind" then
        reduction = 0.1 -- Wind breathing provides 10% damage reduction
    end
    
    -- Apply total concentration reduction
    if BreathingSystem.Concentration.IsInTotalConcentration(ply) then
        reduction = reduction + 0.2 -- Total concentration provides additional 20% reduction
    end
    
    return math.min(reduction, 0.8) -- Cap at 80% reduction
end

-- Enter combat
function BreathingSystem.Combat.EnterCombat(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    data.in_combat = true
    data.combat_start_time = CurTime()
    data.combat_end_time = CurTime() + BreathingSystem.Combat.Config.combat_duration
    
    print("[BreathingSystem.Combat] " .. ply:Name() .. " entered combat")
    
    -- Trigger combat event
    hook.Run("BreathingSystem_CombatEntered", ply)
    
    return true
end

-- Exit combat
function BreathingSystem.Combat.ExitCombat(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.in_combat then return false end
    
    data.in_combat = false
    data.combat_start_time = nil
    data.combat_end_time = nil
    
    print("[BreathingSystem.Combat] " .. ply:Name() .. " exited combat")
    
    -- Trigger combat event
    hook.Run("BreathingSystem_CombatExited", ply)
    
    return true
end

-- Check if player is in combat
function BreathingSystem.Combat.IsInCombat(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    return data.in_combat or false
end

-- Get combat statistics
function BreathingSystem.Combat.GetCombatStats(ply)
    if not IsValid(ply) then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    return {
        inCombat = data.in_combat or false,
        combatStartTime = data.combat_start_time,
        combatEndTime = data.combat_end_time,
        totalDamageDealt = data.total_damage_dealt or 0,
        totalDamageTaken = data.total_damage_taken or 0,
        kills = data.kills or 0,
        deaths = data.deaths or 0
    }
end

-- Update combat status
function BreathingSystem.Combat.UpdateCombatStatus(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if data.in_combat then
        local currentTime = CurTime()
        local combatEndTime = data.combat_end_time or 0
        
        if currentTime >= combatEndTime then
            BreathingSystem.Combat.ExitCombat(ply)
        else
            -- Drain stamina while in combat
            local staminaDrain = BreathingSystem.Combat.Config.combat_stamina_drain
            BreathingSystem.Stamina.DrainStamina(ply, staminaDrain)
        end
    end
    
    return true
end

-- Update all players' combat status
function BreathingSystem.Combat.UpdateAllPlayers()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) then
            BreathingSystem.Combat.UpdateCombatStatus(ply)
        end
    end
end

-- Initialize combat system
if SERVER then
    -- Hook into GMod damage system
    hook.Add("EntityTakeDamage", "BreathingSystem_Combat_Damage", function(target, dmgInfo)
        if IsValid(target) and target:IsPlayer() then
            BreathingSystem.Combat.HandleDamage(target, dmgInfo)
        end
    end)
    
    -- Update combat status every second
    timer.Create("BreathingSystem_CombatUpdate", 1, 0, function()
        BreathingSystem.Combat.UpdateAllPlayers()
    end)
    
    print("[BreathingSystem.Combat] PvP integration loaded")
end
