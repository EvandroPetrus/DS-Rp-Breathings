--[[
    BreathingSystem - Counters System
    ================================
    
    This module handles interaction rules between breathing types.
    Manages counters, weaknesses, and strengths between different breathing types.
    
    Responsibilities:
    - Handle counter relationships between breathing types
    - Manage weakness and strength multipliers
    - Provide counter API functions
    - Integrate with combat system
    
    Public API:
    - BreathingSystem.Counters.GetCounterMultiplier(attackerType, defenderType) - Get counter multiplier
    - BreathingSystem.Counters.IsCounter(attackerType, defenderType) - Check if one counters another
    - BreathingSystem.Counters.GetWeakness(breathingType) - Get breathing type weaknesses
    - BreathingSystem.Counters.GetStrength(breathingType) - Get breathing type strengths
]]

-- Initialize counters module
BreathingSystem.Counters = BreathingSystem.Counters or {}

-- Counters configuration
BreathingSystem.Counters.Config = {
    -- Counter relationships
    counters = {
        -- Water counters
        water = {
            counters = {"fire", "thunder"},
            countered_by = {"stone", "wind"},
            multiplier = 1.5
        },
        
        -- Fire counters
        fire = {
            counters = {"stone", "wind"},
            countered_by = {"water", "thunder"},
            multiplier = 1.5
        },
        
        -- Thunder counters
        thunder = {
            counters = {"water", "wind"},
            countered_by = {"stone", "fire"},
            multiplier = 1.5
        },
        
        -- Stone counters
        stone = {
            counters = {"thunder", "wind"},
            countered_by = {"fire", "water"},
            multiplier = 1.5
        },
        
        -- Wind counters
        wind = {
            counters = {"fire", "stone"},
            countered_by = {"water", "thunder"},
            multiplier = 1.5
        }
    },
    
    -- Special counter rules
    special_counters = {
        -- Water vs Fire
        water_vs_fire = {
            attacker = "water",
            defender = "fire",
            multiplier = 2.0,
            description = "Water extinguishes fire"
        },
        
        -- Fire vs Stone
        fire_vs_stone = {
            attacker = "fire",
            defender = "stone",
            multiplier = 1.8,
            description = "Fire can crack stone"
        },
        
        -- Thunder vs Water
        thunder_vs_water = {
            attacker = "thunder",
            defender = "water",
            multiplier = 2.0,
            description = "Thunder conducts through water"
        },
        
        -- Stone vs Thunder
        stone_vs_thunder = {
            attacker = "stone",
            defender = "thunder",
            multiplier = 1.8,
            description = "Stone grounds thunder"
        },
        
        -- Wind vs Fire
        wind_vs_fire = {
            attacker = "wind",
            defender = "fire",
            multiplier = 1.8,
            description = "Wind fans the flames"
        }
    },
    
    -- Neutral relationships
    neutral_types = {
        "normal", "deep", "combat"
    }
}

-- Get counter multiplier
function BreathingSystem.Counters.GetCounterMultiplier(attackerType, defenderType)
    if not attackerType or not defenderType then return 1.0 end
    
    -- Check if either type is neutral
    if table.HasValue(BreathingSystem.Counters.Config.neutral_types, attackerType) or
       table.HasValue(BreathingSystem.Counters.Config.neutral_types, defenderType) then
        return 1.0
    end
    
    -- Check special counters first
    local specialKey = attackerType .. "_vs_" .. defenderType
    if BreathingSystem.Counters.Config.special_counters[specialKey] then
        return BreathingSystem.Counters.Config.special_counters[specialKey].multiplier
    end
    
    -- Check regular counters
    local attackerConfig = BreathingSystem.Counters.Config.counters[attackerType]
    if not attackerConfig then return 1.0 end
    
    if table.HasValue(attackerConfig.counters, defenderType) then
        return attackerConfig.multiplier
    end
    
    -- Check if defender counters attacker
    local defenderConfig = BreathingSystem.Counters.Config.counters[defenderType]
    if defenderConfig and table.HasValue(defenderConfig.counters, attackerType) then
        return 1.0 / defenderConfig.multiplier -- Reverse multiplier for being countered
    end
    
    return 1.0
end

-- Check if one breathing type counters another
function BreathingSystem.Counters.IsCounter(attackerType, defenderType)
    if not attackerType or not defenderType then return false end
    
    local multiplier = BreathingSystem.Counters.GetCounterMultiplier(attackerType, defenderType)
    return multiplier > 1.0
end

-- Get breathing type weaknesses
function BreathingSystem.Counters.GetWeakness(breathingType)
    if not breathingType then return {} end
    
    local config = BreathingSystem.Counters.Config.counters[breathingType]
    if not config then return {} end
    
    return config.countered_by or {}
end

-- Get breathing type strengths
function BreathingSystem.Counters.GetStrength(breathingType)
    if not breathingType then return {} end
    
    local config = BreathingSystem.Counters.Config.counters[breathingType]
    if not config then return {} end
    
    return config.counters or {}
end

-- Get counter information
function BreathingSystem.Counters.GetCounterInfo(attackerType, defenderType)
    if not attackerType or not defenderType then return nil end
    
    local multiplier = BreathingSystem.Counters.GetCounterMultiplier(attackerType, defenderType)
    local isCounter = BreathingSystem.Counters.IsCounter(attackerType, defenderType)
    local isCountered = BreathingSystem.Counters.IsCounter(defenderType, attackerType)
    
    return {
        attackerType = attackerType,
        defenderType = defenderType,
        multiplier = multiplier,
        isCounter = isCounter,
        isCountered = isCountered,
        effectiveness = multiplier > 1.0 and "effective" or (multiplier < 1.0 and "ineffective" or "neutral")
    }
end

-- Apply counter effects
function BreathingSystem.Counters.ApplyCounterEffects(attacker, defender, formID)
    if not IsValid(attacker) or not IsValid(defender) then return false end
    
    local attackerData = BreathingSystem.GetPlayerData(attacker)
    local defenderData = BreathingSystem.GetPlayerData(defender)
    
    if not attackerData or not defenderData then return false end
    
    local attackerType = attackerData.current_breathing_type or "normal"
    local defenderType = defenderData.current_breathing_type or "normal"
    
    local counterInfo = BreathingSystem.Counters.GetCounterInfo(attackerType, defenderType)
    if not counterInfo then return false end
    
    -- Apply counter multiplier to damage
    if counterInfo.multiplier != 1.0 then
        local form = BreathingSystem.Forms.GetForm(formID)
        if form then
            form.damage_modifier = (form.damage_modifier or 1.0) * counterInfo.multiplier
        end
    end
    
    -- Apply special counter effects
    if counterInfo.isCounter then
        -- Attacker gets bonus effects
        BreathingSystem.Counters.ApplyCounterBonus(attacker, defender, counterInfo)
    elseif counterInfo.isCountered then
        -- Defender gets bonus effects
        BreathingSystem.Counters.ApplyCounterBonus(defender, attacker, counterInfo)
    end
    
    return true
end

-- Apply counter bonus effects
function BreathingSystem.Counters.ApplyCounterBonus(attacker, defender, counterInfo)
    if not IsValid(attacker) or not IsValid(defender) or not counterInfo then return false end
    
    local attackerType = counterInfo.attackerType
    local defenderType = counterInfo.defenderType
    
    -- Apply status effects based on counter type
    if attackerType == "water" and defenderType == "fire" then
        -- Water vs Fire: Extinguish fire effects
        BreathingSystem.StatusEffects.RemoveEffect(defender, "burn")
        BreathingSystem.StatusEffects.ApplyEffect(defender, "freeze", 3.0)
    elseif attackerType == "fire" and defenderType == "water" then
        -- Fire vs Water: Steam effect
        BreathingSystem.StatusEffects.ApplyEffect(defender, "burn", 5.0)
    elseif attackerType == "thunder" and defenderType == "water" then
        -- Thunder vs Water: Shock effect
        BreathingSystem.StatusEffects.ApplyEffect(defender, "shock", 4.0)
    elseif attackerType == "stone" and defenderType == "thunder" then
        -- Stone vs Thunder: Ground effect
        BreathingSystem.StatusEffects.ApplyEffect(defender, "stun", 2.0)
    elseif attackerType == "wind" and defenderType == "fire" then
        -- Wind vs Fire: Fan flames
        BreathingSystem.StatusEffects.ApplyEffect(defender, "burn", 6.0)
    end
    
    return true
end

-- Get counter relationship description
function BreathingSystem.Counters.GetCounterDescription(attackerType, defenderType)
    if not attackerType or not defenderType then return "No special relationship" end
    
    local specialKey = attackerType .. "_vs_" .. defenderType
    local specialCounter = BreathingSystem.Counters.Config.special_counters[specialKey]
    
    if specialCounter then
        return specialCounter.description
    end
    
    local counterInfo = BreathingSystem.Counters.GetCounterInfo(attackerType, defenderType)
    if counterInfo.isCounter then
        return attackerType .. " is effective against " .. defenderType
    elseif counterInfo.isCountered then
        return attackerType .. " is ineffective against " .. defenderType
    else
        return "No special relationship"
    end
end

-- Get all counter relationships for a breathing type
function BreathingSystem.Counters.GetAllRelationships(breathingType)
    if not breathingType then return {} end
    
    local relationships = {
        strengths = {},
        weaknesses = {},
        neutral = {}
    }
    
    for otherType, config in pairs(BreathingSystem.Counters.Config.counters) do
        if otherType != breathingType then
            local counterInfo = BreathingSystem.Counters.GetCounterInfo(breathingType, otherType)
            
            if counterInfo.isCounter then
                table.insert(relationships.strengths, {
                    type = otherType,
                    multiplier = counterInfo.multiplier,
                    description = BreathingSystem.Counters.GetCounterDescription(breathingType, otherType)
                })
            elseif counterInfo.isCountered then
                table.insert(relationships.weaknesses, {
                    type = otherType,
                    multiplier = counterInfo.multiplier,
                    description = BreathingSystem.Counters.GetCounterDescription(breathingType, otherType)
                })
            else
                table.insert(relationships.neutral, {
                    type = otherType,
                    multiplier = counterInfo.multiplier,
                    description = BreathingSystem.Counters.GetCounterDescription(breathingType, otherType)
                })
            end
        end
    end
    
    return relationships
end

-- Initialize counters system
if SERVER then
    print("[BreathingSystem.Counters] Counters system loaded")
end
