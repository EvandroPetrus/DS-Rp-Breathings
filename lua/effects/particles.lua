--[[
    BreathingSystem - Particle Effects
    =================================
    
    This module handles particle effects for breathing types and forms.
    Provides placeholder particles and hooks for server owners to customize.
    
    Responsibilities:
    - Manage particle effects for breathing types
    - Handle form-specific particle effects
    - Provide hooks for custom particle effects
    - Manage particle cleanup and optimization
    
    Public API:
    - BreathingSystem.Particles.CreateEffect(ply, effectType, formID) - Create particle effect
    - BreathingSystem.Particles.StopEffect(ply, effectType) - Stop particle effect
    - BreathingSystem.Particles.GetEffectConfig(effectType) - Get effect configuration
    - BreathingSystem.Particles.RegisterCustomEffect(name, config) - Register custom effect
]]

-- Only initialize on server
if SERVER then
    -- Initialize particles module
    BreathingSystem = BreathingSystem or {}
    BreathingSystem.Particles = BreathingSystem.Particles or {}
    
    -- Particle effects configuration
    BreathingSystem.Particles.Config = {
        -- Effect types
        effect_types = {
            "breathing_type",    -- Breathing type effects
            "form_activation",   -- Form activation effects
            "total_concentration", -- Total concentration effects
            "training",          -- Training effects
            "damage",            -- Damage effects
            "healing"            -- Healing effects
        },
        
        -- Breathing type particle effects
        breathing_type_effects = {
            water = {
                particle = "water_splash",
                color = Color(0, 150, 255, 200),
                size = 1.0,
                lifetime = 2.0,
                frequency = 0.1
            },
            fire = {
                particle = "fire_flame",
                color = Color(255, 100, 0, 200),
                size = 1.2,
                lifetime = 3.0,
                frequency = 0.05
            },
            thunder = {
                particle = "thunder_bolt",
                color = Color(255, 255, 0, 200),
                size = 0.8,
                lifetime = 1.5,
                frequency = 0.2
            },
            stone = {
                particle = "stone_dust",
                color = Color(128, 128, 128, 200),
                size = 1.5,
                lifetime = 4.0,
                frequency = 0.15
            },
            wind = {
                particle = "wind_swirl",
                color = Color(200, 200, 255, 150),
                size = 1.0,
                lifetime = 2.5,
                frequency = 0.08
            }
        },
        
        -- Form-specific effects
        form_effects = {
            -- Water forms
            water_surface_slash = {
                particle = "water_surface",
                color = Color(0, 150, 255, 200),
                size = 1.0,
                lifetime = 1.5,
                frequency = 0.1
            },
            water_water_wheel = {
                particle = "water_wheel",
                color = Color(0, 150, 255, 200),
                size = 1.5,
                lifetime = 3.0,
                frequency = 0.05
            },
            
            -- Fire forms
            fire_unknowing_fire = {
                particle = "fire_basic",
                color = Color(255, 100, 0, 200),
                size = 1.0,
                lifetime = 2.0,
                frequency = 0.1
            },
            fire_sun_breathing = {
                particle = "sun_rays",
                color = Color(255, 255, 0, 200),
                size = 2.0,
                lifetime = 5.0,
                frequency = 0.02
            },
            
            -- Thunder forms
            thunder_clap_flash = {
                particle = "thunder_flash",
                color = Color(255, 255, 0, 200),
                size = 0.8,
                lifetime = 1.0,
                frequency = 0.3
            },
            thunder_honoikazuchi_no_kami = {
                particle = "thunder_god",
                color = Color(255, 255, 0, 200),
                size = 2.5,
                lifetime = 4.0,
                frequency = 0.01
            }
        },
        
        -- Special effects
        special_effects = {
            total_concentration = {
                particle = "concentration_aura",
                color = Color(255, 255, 255, 100),
                size = 3.0,
                lifetime = 0.5,
                frequency = 0.1
            },
            training = {
                particle = "training_energy",
                color = Color(0, 255, 0, 150),
                size = 1.0,
                lifetime = 2.0,
                frequency = 0.2
            },
            damage = {
                particle = "damage_impact",
                color = Color(255, 0, 0, 200),
                size = 0.5,
                lifetime = 0.5,
                frequency = 1.0
            },
            healing = {
                particle = "healing_light",
                color = Color(0, 255, 0, 150),
                size = 1.0,
                lifetime = 1.0,
                frequency = 0.5
            }
        }
    }
    
    -- Active particle effects per player
    BreathingSystem.Particles.ActiveEffects = BreathingSystem.Particles.ActiveEffects or {}
    
    -- Create particle effect
    function BreathingSystem.Particles.CreateEffect(ply, effectType, formID)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        local effectConfig = BreathingSystem.Particles.GetEffectConfig(effectType, formID)
        
        if not effectConfig then
            print("[BreathingSystem.Particles] No config found for effect: " .. tostring(effectType))
            return false
        end
        
        -- Create effect data
        local effectData = {
            config = effectConfig,
            startTime = CurTime(),
            ply = ply
        }
        
        -- Store active effect
        if not BreathingSystem.Particles.ActiveEffects[steamid] then
            BreathingSystem.Particles.ActiveEffects[steamid] = {}
        end
        BreathingSystem.Particles.ActiveEffects[steamid][effectType] = effectData
        
        print("[BreathingSystem.Particles] Created " .. effectType .. " effect for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_ParticleEffectCreated", ply, effectType, formID, effectConfig)
        
        return true
    end
    
    -- Stop particle effect
    function BreathingSystem.Particles.StopEffect(ply, effectType)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        if not BreathingSystem.Particles.ActiveEffects[steamid] then return false end
        
        local effectData = BreathingSystem.Particles.ActiveEffects[steamid][effectType]
        if not effectData then return false end
        
        -- Remove from active effects
        BreathingSystem.Particles.ActiveEffects[steamid][effectType] = nil
        
        print("[BreathingSystem.Particles] Stopped " .. effectType .. " effect for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_ParticleEffectStopped", ply, effectType)
        
        return true
    end
    
    -- Get effect configuration
    function BreathingSystem.Particles.GetEffectConfig(effectType, formID)
        -- Check form-specific effects first
        if formID and BreathingSystem.Particles.Config.form_effects[formID] then
            return BreathingSystem.Particles.Config.form_effects[formID]
        end
        
        -- Check breathing type effects
        local breathingType = nil
        if formID then
            local formData = BreathingSystem.Forms.GetForm(formID)
            if formData then
                breathingType = formData.breathing_type
            end
        end
        
        if breathingType and BreathingSystem.Particles.Config.breathing_type_effects[breathingType] then
            return BreathingSystem.Particles.Config.breathing_type_effects[breathingType]
        end
        
        -- Check special effects
        if BreathingSystem.Particles.Config.special_effects[effectType] then
            return BreathingSystem.Particles.Config.special_effects[effectType]
        end
        
        return nil
    end
    
    -- Register custom particle effect
    function BreathingSystem.Particles.RegisterCustomEffect(name, config)
        BreathingSystem.Particles.Config.special_effects[name] = config
        print("[BreathingSystem.Particles] Registered custom effect: " .. name)
    end
    
    -- Get active effects for player
    function BreathingSystem.Particles.GetActiveEffects(ply)
        if not IsValid(ply) then return {} end
        local steamid = ply:SteamID()
        return BreathingSystem.Particles.ActiveEffects[steamid] or {}
    end
    
    -- Stop all effects for player
    function BreathingSystem.Particles.StopAllEffects(ply)
        if not IsValid(ply) then return false end
        local steamid = ply:SteamID()
        if not BreathingSystem.Particles.ActiveEffects[steamid] then return false end
        
        for effectType, effectData in pairs(BreathingSystem.Particles.ActiveEffects[steamid]) do
            BreathingSystem.Particles.StopEffect(ply, effectType)
        end
        
        return true
    end
    
    -- Update particle effects
    function BreathingSystem.Particles.UpdateEffects()
        local currentTime = CurTime()
        
        for steamid, playerEffects in pairs(BreathingSystem.Particles.ActiveEffects) do
            local ply = player.GetBySteamID(steamid)
            if not IsValid(ply) then
                -- Clean up invalid player
                BreathingSystem.Particles.ActiveEffects[steamid] = nil
                continue
            end
            
            for effectType, effectData in pairs(playerEffects) do
                local config = effectData.config
                local elapsed = currentTime - effectData.startTime
                
                -- Check if effect should expire
                if elapsed >= config.lifetime then
                    BreathingSystem.Particles.StopEffect(ply, effectType)
                end
            end
        end
    end
    
    -- Convenience functions
    function BreathingSystem.Particles.CreateBreathingTypeEffect(ply, breathingType)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "breathing_type", breathingType)
    end
    
    function BreathingSystem.Particles.CreateFormEffect(ply, formID)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "form_activation", formID)
    end
    
    function BreathingSystem.Particles.CreateTotalConcentrationEffect(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "total_concentration")
    end
    
    function BreathingSystem.Particles.CreateTrainingEffect(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "training")
    end
    
    function BreathingSystem.Particles.CreateDamageEffect(ply, target)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "damage")
    end
    
    function BreathingSystem.Particles.CreateHealingEffect(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Particles.CreateEffect(ply, "healing")
    end
    
    -- Update particle effects every second
    timer.Create("BreathingSystem_ParticleUpdate", 1, 0, function()
        BreathingSystem.Particles.UpdateEffects()
    end)
    
    print("[BreathingSystem.Particles] Particle effects system loaded")
end
