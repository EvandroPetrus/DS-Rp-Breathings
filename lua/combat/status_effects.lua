--[[
    BreathingSystem - Status Effects
    ===============================
    
    This module handles status effects like stun, bleed, etc.
    Manages temporary effects that affect player performance.
    
    Responsibilities:
    - Manage status effects on players
    - Handle effect duration and stacking
    - Provide status effect API functions
    - Integrate with combat system
    
    Public API:
    - BreathingSystem.StatusEffects.ApplyEffect(ply, effectType, duration) - Apply status effect
    - BreathingSystem.StatusEffects.RemoveEffect(ply, effectType) - Remove status effect
    - BreathingSystem.StatusEffects.HasEffect(ply, effectType) - Check if player has effect
    - BreathingSystem.StatusEffects.GetActiveEffects(ply) - Get all active effects
]]

-- Initialize status effects module
BreathingSystem.StatusEffects = BreathingSystem.StatusEffects or {}

-- Status effects configuration
BreathingSystem.StatusEffects.Config = {
    -- Effect types
    effect_types = {
        "stun",           -- Stuns the player
        "bleed",          -- Causes damage over time
        "burn",           -- Fire damage over time
        "freeze",         -- Slows movement and actions
        "shock",          -- Electrical damage and stun
        "poison",         -- Damage over time
        "regeneration",   -- Heals over time
        "strength",       -- Increases damage
        "speed",          -- Increases movement speed
        "defense"         -- Reduces incoming damage
    },
    
    -- Effect properties
    effects = {
        stun = {
            name = "Stunned",
            description = "Cannot move or use abilities",
            duration = 3.0,
            stackable = false,
            max_stacks = 1,
            effects = {
                movement_speed = 0.0,
                can_use_abilities = false,
                can_move = false
            }
        },
        bleed = {
            name = "Bleeding",
            description = "Takes damage over time",
            duration = 10.0,
            stackable = true,
            max_stacks = 5,
            effects = {
                damage_per_second = 5,
                damage_type = DMG_SLASH
            }
        },
        burn = {
            name = "Burning",
            description = "Takes fire damage over time",
            duration = 8.0,
            stackable = true,
            max_stacks = 3,
            effects = {
                damage_per_second = 8,
                damage_type = DMG_BURN
            }
        },
        freeze = {
            name = "Frozen",
            description = "Movement and actions are slowed",
            duration = 6.0,
            stackable = true,
            max_stacks = 3,
            effects = {
                movement_speed = 0.5,
                action_speed = 0.7
            }
        },
        shock = {
            name = "Shocked",
            description = "Takes electrical damage and may be stunned",
            duration = 5.0,
            stackable = true,
            max_stacks = 2,
            effects = {
                damage_per_second = 6,
                damage_type = DMG_SHOCK,
                stun_chance = 0.3
            }
        },
        poison = {
            name = "Poisoned",
            description = "Takes damage over time",
            duration = 15.0,
            stackable = true,
            max_stacks = 4,
            effects = {
                damage_per_second = 3,
                damage_type = DMG_POISON
            }
        },
        regeneration = {
            name = "Regenerating",
            description = "Heals over time",
            duration = 20.0,
            stackable = true,
            max_stacks = 3,
            effects = {
                heal_per_second = 10
            }
        },
        strength = {
            name = "Strengthened",
            description = "Increases damage dealt",
            duration = 30.0,
            stackable = true,
            max_stacks = 2,
            effects = {
                damage_multiplier = 1.5
            }
        },
        speed = {
            name = "Hastened",
            description = "Increases movement speed",
            duration = 25.0,
            stackable = true,
            max_stacks = 2,
            effects = {
                movement_speed = 1.5
            }
        },
        defense = {
            name = "Protected",
            description = "Reduces incoming damage",
            duration = 35.0,
            stackable = true,
            max_stacks = 2,
            effects = {
                damage_reduction = 0.3
            }
        }
    }
}

-- Active effects per player
BreathingSystem.StatusEffects.ActiveEffects = BreathingSystem.StatusEffects.ActiveEffects or {}

-- Apply status effect
function BreathingSystem.StatusEffects.ApplyEffect(ply, effectType, duration, intensity)
    if not IsValid(ply) or not effectType then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local effectConfig = BreathingSystem.StatusEffects.Config.effects[effectType]
    if not effectConfig then return false end
    
    -- Check if effect is stackable
    if not effectConfig.stackable then
        if BreathingSystem.StatusEffects.HasEffect(ply, effectType) then
            return false -- Effect already active and not stackable
        end
    end
    
    -- Check max stacks
    local currentStacks = BreathingSystem.StatusEffects.GetEffectStacks(ply, effectType)
    if currentStacks >= effectConfig.max_stacks then
        return false -- Max stacks reached
    end
    
    -- Create effect data
    local effectData = {
        player = ply,
        effectType = effectType,
        duration = duration or effectConfig.duration,
        intensity = intensity or 1.0,
        startTime = CurTime(),
        active = true,
        stacks = 1
    }
    
    -- Store active effect
    local steamid = ply:SteamID()
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid] then
        BreathingSystem.StatusEffects.ActiveEffects[steamid] = {}
    end
    
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType] then
        BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType] = {}
    end
    
    table.insert(BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType], effectData)
    
    print("[BreathingSystem.StatusEffects] Applied " .. effectType .. " effect to " .. ply:Name())
    
    -- Trigger effect event
    hook.Run("BreathingSystem_StatusEffectApplied", ply, effectType, effectData)
    
    return true
end

-- Remove status effect
function BreathingSystem.StatusEffects.RemoveEffect(ply, effectType)
    if not IsValid(ply) or not effectType then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid] then return false end
    
    local effects = BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType]
    if not effects then return false end
    
    -- Remove all instances of the effect
    BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType] = nil
    
    print("[BreathingSystem.StatusEffects] Removed " .. effectType .. " effect from " .. ply:Name())
    
    -- Trigger effect event
    hook.Run("BreathingSystem_StatusEffectRemoved", ply, effectType)
    
    return true
end

-- Check if player has effect
function BreathingSystem.StatusEffects.HasEffect(ply, effectType)
    if not IsValid(ply) or not effectType then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid] then return false end
    
    local effects = BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType]
    if not effects then return false end
    
    return #effects > 0
end

-- Get effect stacks
function BreathingSystem.StatusEffects.GetEffectStacks(ply, effectType)
    if not IsValid(ply) or not effectType then return 0 end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid] then return 0 end
    
    local effects = BreathingSystem.StatusEffects.ActiveEffects[steamid][effectType]
    if not effects then return 0 end
    
    return #effects
end

-- Get all active effects for player
function BreathingSystem.StatusEffects.GetActiveEffects(ply)
    if not IsValid(ply) then return {} end
    
    local steamid = ply:SteamID()
    local activeEffects = {}
    
    if BreathingSystem.StatusEffects.ActiveEffects[steamid] then
        for effectType, effects in pairs(BreathingSystem.StatusEffects.ActiveEffects[steamid]) do
            if #effects > 0 then
                activeEffects[effectType] = {
                    stacks = #effects,
                    totalDuration = 0,
                    remainingTime = 0
                }
                
                for _, effect in ipairs(effects) do
                    activeEffects[effectType].totalDuration = activeEffects[effectType].totalDuration + effect.duration
                    local remaining = effect.duration - (CurTime() - effect.startTime)
                    activeEffects[effectType].remainingTime = math.max(activeEffects[effectType].remainingTime, remaining)
                end
            end
        end
    end
    
    return activeEffects
end

-- Update status effects
function BreathingSystem.StatusEffects.UpdateEffects()
    local currentTime = CurTime()
    
    for steamid, playerEffects in pairs(BreathingSystem.StatusEffects.ActiveEffects) do
        local ply = player.GetBySteamID(steamid)
        if not IsValid(ply) then
            -- Clean up effects for disconnected players
            BreathingSystem.StatusEffects.ActiveEffects[steamid] = nil
        else
            -- Update active effects
            for effectType, effects in pairs(playerEffects) do
                local expiredEffects = {}
                
                for i, effect in ipairs(effects) do
                    if effect.active then
                        local elapsed = currentTime - effect.startTime
                        
                        if elapsed >= effect.duration then
                            -- Effect expired
                            table.insert(expiredEffects, i)
                        else
                            -- Apply effect
                            BreathingSystem.StatusEffects.ApplyEffectTick(ply, effect)
                        end
                    end
                end
                
                -- Remove expired effects
                for i = #expiredEffects, 1, -1 do
                    table.remove(effects, expiredEffects[i])
                end
                
                -- Clean up empty effect types
                if #effects == 0 then
                    playerEffects[effectType] = nil
                end
            end
        end
    end
end

-- Apply effect tick
function BreathingSystem.StatusEffects.ApplyEffectTick(ply, effect)
    if not IsValid(ply) or not effect then return false end
    
    local effectConfig = BreathingSystem.StatusEffects.Config.effects[effect.effectType]
    if not effectConfig then return false end
    
    local effects = effectConfig.effects or {}
    
    -- Apply damage over time effects
    if effects.damage_per_second then
        local damage = effects.damage_per_second * effect.intensity
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(damage)
        dmgInfo:SetAttacker(ply)
        dmgInfo:SetInflictor(ply)
        dmgInfo:SetDamageType(effects.damage_type or DMG_GENERIC)
        dmgInfo:SetDamagePosition(ply:GetPos())
        
        ply:TakeDamageInfo(dmgInfo)
    end
    
    -- Apply healing effects
    if effects.heal_per_second then
        local heal = effects.heal_per_second * effect.intensity
        ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + heal))
    end
    
    -- Apply stun effects
    if effects.stun_chance and math.random() < effects.stun_chance then
        BreathingSystem.StatusEffects.ApplyEffect(ply, "stun", 1.0)
    end
    
    return true
end

-- Clear all effects for player
function BreathingSystem.StatusEffects.ClearAllEffects(ply)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.StatusEffects.ActiveEffects[steamid] then return false end
    
    BreathingSystem.StatusEffects.ActiveEffects[steamid] = nil
    
    print("[BreathingSystem.StatusEffects] Cleared all effects for " .. ply:Name())
    
    return true
end

-- Initialize status effects system
if SERVER then
    -- Update status effects every second
    timer.Create("BreathingSystem_StatusEffectsUpdate", 1, 0, function()
        BreathingSystem.StatusEffects.UpdateEffects()
    end)
    
    print("[BreathingSystem.StatusEffects] Status effects system loaded")
end
