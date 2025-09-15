--[[
    BreathingSystem - Damage Mechanics
    =================================
    
    This module handles damage calculations and balancing for breathing forms.
    Integrates with GMod's damage system and provides balanced damage values.
    
    Responsibilities:
    - Calculate damage for breathing forms
    - Handle damage modifiers and bonuses
    - Integrate with GMod's damage system
    - Provide balanced damage values
    
    Public API:
    - BreathingSystem.Damage.CalculateDamage(ply, formID, target) - Calculate damage
    - BreathingSystem.Damage.ApplyDamage(ply, formID, target) - Apply damage
    - BreathingSystem.Damage.GetDamageModifier(ply, formID) - Get damage modifier
    - BreathingSystem.Damage.GetFormDamage(formID) - Get base form damage
]]

-- Initialize damage module
BreathingSystem.Damage = BreathingSystem.Damage or {}

-- Damage configuration
BreathingSystem.Damage.Config = {
    -- Base damage values
    base_damage = 10,
    
    -- Breathing type damage modifiers
    breathing_type_modifiers = {
        water = 0.8,   -- Water breathing does less damage
        fire = 1.3,    -- Fire breathing does more damage
        thunder = 1.1, -- Thunder breathing does slightly more damage
        stone = 1.2,   -- Stone breathing does more damage
        wind = 1.0,    -- Wind breathing does normal damage
        normal = 1.0   -- Normal breathing is baseline
    },
    
    -- Form difficulty damage modifiers
    difficulty_modifiers = {
        [1] = 0.5, -- Easy forms do less damage
        [2] = 0.7,
        [3] = 1.0, -- Medium forms do normal damage
        [4] = 1.3,
        [5] = 1.6  -- Hard forms do more damage
    },
    
    -- Player level damage modifiers
    level_modifiers = {
        [1] = 0.5,  -- Level 1 does 50% damage
        [5] = 0.7,  -- Level 5 does 70% damage
        [10] = 1.0, -- Level 10 does 100% damage
        [15] = 1.3, -- Level 15 does 130% damage
        [20] = 1.6  -- Level 20 does 160% damage
    },
    
    -- Concentration damage bonuses
    concentration_bonuses = {
        [0] = 0,    -- 0% concentration = 0% bonus
        [25] = 0.1, -- 25% concentration = 10% bonus
        [50] = 0.2, -- 50% concentration = 20% bonus
        [75] = 0.3, -- 75% concentration = 30% bonus
        [100] = 0.5 -- 100% concentration = 50% bonus
    }
}

-- Calculate damage for a breathing form
function BreathingSystem.Damage.CalculateDamage(ply, formID, target)
    if not IsValid(ply) or not formID then return 0 end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return 0 end
    
    local baseDamage = BreathingSystem.Damage.GetFormDamage(formID)
    local modifiedDamage = baseDamage
    
    -- Apply breathing type modifier
    local data = BreathingSystem.GetPlayerData(ply)
    if data then
        local breathingType = data.current_breathing_type or "normal"
        local breathingModifier = BreathingSystem.Damage.Config.breathing_type_modifiers[breathingType] or 1.0
        modifiedDamage = modifiedDamage * breathingModifier
    end
    
    -- Apply form difficulty modifier
    local difficultyModifier = BreathingSystem.Damage.Config.difficulty_modifiers[form.difficulty] or 1.0
    modifiedDamage = modifiedDamage * difficultyModifier
    
    -- Apply player level modifier
    local playerLevel = BreathingSystem.Prerequisites.GetLevel(ply)
    local levelModifier = BreathingSystem.Damage.GetLevelModifier(playerLevel)
    modifiedDamage = modifiedDamage * levelModifier
    
    -- Apply concentration bonus
    local concentrationBonus = BreathingSystem.Damage.GetConcentrationBonus(ply)
    modifiedDamage = modifiedDamage * (1 + concentrationBonus)
    
    -- Apply stamina bonus
    local staminaBonus = BreathingSystem.Damage.GetStaminaBonus(ply)
    modifiedDamage = modifiedDamage * (1 + staminaBonus)
    
    -- Apply target-specific modifiers
    if IsValid(target) then
        modifiedDamage = BreathingSystem.Damage.ApplyTargetModifiers(modifiedDamage, target)
    end
    
    return math.floor(modifiedDamage)
end

-- Get base damage for a form
function BreathingSystem.Damage.GetFormDamage(formID)
    if not formID then return BreathingSystem.Damage.Config.base_damage end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return BreathingSystem.Damage.Config.base_damage end
    
    return form.damage_modifier or BreathingSystem.Damage.Config.base_damage
end

-- Get damage modifier for a form
function BreathingSystem.Damage.GetDamageModifier(ply, formID)
    if not IsValid(ply) or not formID then return 1.0 end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return 1.0 end
    
    local modifier = 1.0
    
    -- Apply breathing type modifier
    local data = BreathingSystem.GetPlayerData(ply)
    if data then
        local breathingType = data.current_breathing_type or "normal"
        local breathingModifier = BreathingSystem.Damage.Config.breathing_type_modifiers[breathingType] or 1.0
        modifier = modifier * breathingModifier
    end
    
    -- Apply form difficulty modifier
    local difficultyModifier = BreathingSystem.Damage.Config.difficulty_modifiers[form.difficulty] or 1.0
    modifier = modifier * difficultyModifier
    
    return modifier
end

-- Get level modifier for damage
function BreathingSystem.Damage.GetLevelModifier(level)
    if not level or level < 1 then return 0.5 end
    
    local modifier = 0.5 -- Default for level 1
    
    for reqLevel, mod in pairs(BreathingSystem.Damage.Config.level_modifiers) do
        if level >= reqLevel then
            modifier = mod
        end
    end
    
    return modifier
end

-- Get concentration bonus for damage
function BreathingSystem.Damage.GetConcentrationBonus(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local concentration = data.concentration or 0
    local maxConcentration = BreathingSystem.Stamina.GetMaxConcentration(ply)
    local concentrationPercent = (concentration / maxConcentration) * 100
    
    local bonus = 0
    for reqPercent, bonusValue in pairs(BreathingSystem.Damage.Config.concentration_bonuses) do
        if concentrationPercent >= reqPercent then
            bonus = bonusValue
        end
    end
    
    return bonus
end

-- Get stamina bonus for damage
function BreathingSystem.Damage.GetStaminaBonus(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local stamina = data.stamina or 0
    local maxStamina = BreathingSystem.Stamina.GetMaxStamina(ply)
    local staminaPercent = (stamina / maxStamina) * 100
    
    -- Higher stamina = higher damage bonus
    if staminaPercent >= 90 then
        return 0.2 -- 20% bonus
    elseif staminaPercent >= 70 then
        return 0.1 -- 10% bonus
    elseif staminaPercent >= 50 then
        return 0.05 -- 5% bonus
    end
    
    return 0
end

-- Apply target-specific damage modifiers
function BreathingSystem.Damage.ApplyTargetModifiers(damage, target)
    if not IsValid(target) then return damage end
    
    local modifiedDamage = damage
    
    -- Check if target is a player
    if target:IsPlayer() then
        -- Apply PvP damage reduction
        modifiedDamage = modifiedDamage * 0.8
    end
    
    -- Check if target is an NPC
    if target:IsNPC() then
        -- Apply NPC damage bonus
        modifiedDamage = modifiedDamage * 1.2
    end
    
    -- Check if target is a prop
    if target:GetClass() == "prop_physics" then
        -- Apply prop damage bonus
        modifiedDamage = modifiedDamage * 1.5
    end
    
    return modifiedDamage
end

-- Apply damage to a target
function BreathingSystem.Damage.ApplyDamage(ply, formID, target)
    if not IsValid(ply) or not formID or not IsValid(target) then return false end
    
    local damage = BreathingSystem.Damage.CalculateDamage(ply, formID, target)
    if damage <= 0 then return false end
    
    -- Create damage info
    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(damage)
    dmgInfo:SetAttacker(ply)
    dmgInfo:SetInflictor(ply)
    dmgInfo:SetDamageType(DMG_GENERIC)
    dmgInfo:SetDamagePosition(target:GetPos())
    
    -- Apply damage
    target:TakeDamageInfo(dmgInfo)
    
    print("[BreathingSystem.Damage] Applied " .. damage .. " damage to " .. target:GetName() .. " using " .. formID)
    
    return true
end

-- Get damage info for a form
function BreathingSystem.Damage.GetDamageInfo(ply, formID)
    if not IsValid(ply) or not formID then return nil end
    
    local baseDamage = BreathingSystem.Damage.GetFormDamage(formID)
    local damageModifier = BreathingSystem.Damage.GetDamageModifier(ply, formID)
    local levelModifier = BreathingSystem.Damage.GetLevelModifier(BreathingSystem.Prerequisites.GetLevel(ply))
    local concentrationBonus = BreathingSystem.Damage.GetConcentrationBonus(ply)
    local staminaBonus = BreathingSystem.Damage.GetStaminaBonus(ply)
    
    local totalDamage = baseDamage * damageModifier * levelModifier * (1 + concentrationBonus) * (1 + staminaBonus)
    
    return {
        baseDamage = baseDamage,
        damageModifier = damageModifier,
        levelModifier = levelModifier,
        concentrationBonus = concentrationBonus,
        staminaBonus = staminaBonus,
        totalDamage = math.floor(totalDamage)
    }
end

-- Initialize damage system
if SERVER then
    print("[BreathingSystem.Damage] Damage mechanics loaded")
end
