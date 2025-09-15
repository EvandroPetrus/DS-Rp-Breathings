--[[
    BreathingSystem - Animation Effects
    ==================================
    
    This module handles animation effects for breathing techniques.
    Provides hooks for technique activations and player animations.
    
    Responsibilities:
    - Manage player animations for breathing forms
    - Handle technique activation animations
    - Provide hooks for custom animations
    - Manage animation timing and synchronization
    
    Public API:
    - BreathingSystem.Animations.PlayAnimation(ply, animationType, formID) - Play animation
    - BreathingSystem.Animations.StopAnimation(ply, animationType) - Stop animation
    - BreathingSystem.Animations.GetAnimationConfig(animationType) - Get animation config
    - BreathingSystem.Animations.RegisterCustomAnimation(name, config) - Register custom animation
]]

-- Initialize animations module
BreathingSystem.Animations = BreathingSystem.Animations or {}

-- Animation configuration
BreathingSystem.Animations.Config = {
    -- Animation types
    animation_types = {
        "breathing_type",    -- Breathing type animations
        "form_activation",   -- Form activation animations
        "total_concentration", -- Total concentration animations
        "training",          -- Training animations
        "damage",            -- Damage animations
        "healing"            -- Healing animations
    },
    
    -- Breathing type animations
    breathing_type_animations = {
        water = {
            sequence = "breathing_water",
            duration = 2.0,
            loop = true,
            speed = 1.0
        },
        fire = {
            sequence = "breathing_fire",
            duration = 1.5,
            loop = true,
            speed = 1.2
        },
        thunder = {
            sequence = "breathing_thunder",
            duration = 1.0,
            loop = true,
            speed = 1.5
        },
        stone = {
            sequence = "breathing_stone",
            duration = 3.0,
            loop = true,
            speed = 0.8
        },
        wind = {
            sequence = "breathing_wind",
            duration = 2.5,
            loop = true,
            speed = 1.1
        }
    },
    
    -- Form-specific animations
    form_animations = {
        -- Water forms
        water_surface_slash = {
            sequence = "water_surface_slash",
            duration = 1.0,
            loop = false,
            speed = 1.0
        },
        water_water_wheel = {
            sequence = "water_wheel",
            duration = 3.0,
            loop = false,
            speed = 1.0
        },
        water_flowing_dance = {
            sequence = "water_flowing_dance",
            duration = 5.0,
            loop = false,
            speed = 1.0
        },
        
        -- Fire forms
        fire_unknowing_fire = {
            sequence = "fire_unknowing_fire",
            duration = 1.5,
            loop = false,
            speed = 1.0
        },
        fire_rising_scorching_sun = {
            sequence = "fire_rising_scorching_sun",
            duration = 2.0,
            loop = false,
            speed = 1.0
        },
        fire_sun_breathing = {
            sequence = "fire_sun_breathing",
            duration = 10.0,
            loop = false,
            speed = 1.0
        },
        
        -- Thunder forms
        thunder_clap_flash = {
            sequence = "thunder_clap_flash",
            duration = 0.5,
            loop = false,
            speed = 2.0
        },
        thunder_honoikazuchi_no_kami = {
            sequence = "thunder_honoikazuchi_no_kami",
            duration = 8.0,
            loop = false,
            speed = 1.0
        },
        
        -- Stone forms
        stone_surface_slash = {
            sequence = "stone_surface_slash",
            duration = 2.0,
            loop = false,
            speed = 0.8
        },
        stone_arcs_of_justice = {
            sequence = "stone_arcs_of_justice",
            duration = 6.0,
            loop = false,
            speed = 1.0
        },
        
        -- Wind forms
        wind_dust_whirlwind_cutter = {
            sequence = "wind_dust_whirlwind_cutter",
            duration = 1.5,
            loop = false,
            speed = 1.2
        },
        wind_idaten_typhoon = {
            sequence = "wind_idaten_typhoon",
            duration = 12.0,
            loop = false,
            speed = 1.0
        }
    },
    
    -- Special animations
    special_animations = {
        total_concentration = {
            sequence = "total_concentration",
            duration = 60.0,
            loop = true,
            speed = 1.0
        },
        training = {
            sequence = "training_pose",
            duration = 5.0,
            loop = true,
            speed = 1.0
        },
        damage = {
            sequence = "damage_impact",
            duration = 0.5,
            loop = false,
            speed = 1.0
        },
        healing = {
            sequence = "healing_pose",
            duration = 3.0,
            loop = false,
            speed = 1.0
        }
    }
}

-- Active animations per player
BreathingSystem.Animations.ActiveAnimations = BreathingSystem.Animations.ActiveAnimations or {}

-- Play animation
function BreathingSystem.Animations.PlayAnimation(ply, animationType, formID)
    if not IsValid(ply) or not animationType then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Get animation configuration
    local animationConfig = BreathingSystem.Animations.GetAnimationConfig(animationType, formID)
    if not animationConfig then return false end
    
    -- Stop any existing animation of the same type
    BreathingSystem.Animations.StopAnimation(ply, animationType)
    
    -- Create animation data
    local animationData = {
        player = ply,
        animationType = animationType,
        formID = formID,
        config = animationConfig,
        startTime = CurTime(),
        active = true
    }
    
    -- Store active animation
    local steamid = ply:SteamID()
    if not BreathingSystem.Animations.ActiveAnimations[steamid] then
        BreathingSystem.Animations.ActiveAnimations[steamid] = {}
    end
    
    BreathingSystem.Animations.ActiveAnimations[steamid][animationType] = animationData
    
    print("[BreathingSystem.Animations] Playing " .. animationType .. " animation for " .. ply:Name())
    
    -- Trigger animation event
    hook.Run("BreathingSystem_AnimationStarted", ply, animationType, formID, animationConfig)
    
    return true
end

-- Stop animation
function BreathingSystem.Animations.StopAnimation(ply, animationType)
    if not IsValid(ply) or not animationType then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.Animations.ActiveAnimations[steamid] then return false end
    
    local animationData = BreathingSystem.Animations.ActiveAnimations[steamid][animationType]
    if not animationData then return false end
    
    animationData.active = false
    BreathingSystem.Animations.ActiveAnimations[steamid][animationType] = nil
    
    print("[BreathingSystem.Animations] Stopped " .. animationType .. " animation for " .. ply:Name())
    
    -- Trigger animation stop event
    hook.Run("BreathingSystem_AnimationStopped", ply, animationType)
    
    return true
end

-- Get animation configuration
function BreathingSystem.Animations.GetAnimationConfig(animationType, formID)
    if not animationType then return nil end
    
    -- Check form-specific animations first
    if formID and BreathingSystem.Animations.Config.form_animations[formID] then
        return BreathingSystem.Animations.Config.form_animations[formID]
    end
    
    -- Check breathing type animations
    if animationType == "breathing_type" and formID then
        local form = BreathingSystem.Forms.GetForm(formID)
        if form then
            local breathingType = string.match(formID, "([^_]+)")
            if breathingType and BreathingSystem.Animations.Config.breathing_type_animations[breathingType] then
                return BreathingSystem.Animations.Config.breathing_type_animations[breathingType]
            end
        end
    end
    
    -- Check special animations
    if BreathingSystem.Animations.Config.special_animations[animationType] then
        return BreathingSystem.Animations.Config.special_animations[animationType]
    end
    
    return nil
end

-- Register custom animation
function BreathingSystem.Animations.RegisterCustomAnimation(name, config)
    if not name or not config then return false end
    
    BreathingSystem.Animations.Config.special_animations[name] = config
    
    print("[BreathingSystem.Animations] Registered custom animation: " .. name)
    
    return true
end

-- Get active animations for player
function BreathingSystem.Animations.GetActiveAnimations(ply)
    if not IsValid(ply) then return {} end
    
    local steamid = ply:SteamID()
    return BreathingSystem.Animations.ActiveAnimations[steamid] or {}
end

-- Stop all animations for player
function BreathingSystem.Animations.StopAllAnimations(ply)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.Animations.ActiveAnimations[steamid] then return false end
    
    for animationType, animationData in pairs(BreathingSystem.Animations.ActiveAnimations[steamid]) do
        BreathingSystem.Animations.StopAnimation(ply, animationType)
    end
    
    return true
end

-- Update animations
function BreathingSystem.Animations.UpdateAnimations()
    local currentTime = CurTime()
    
    for steamid, playerAnimations in pairs(BreathingSystem.Animations.ActiveAnimations) do
        local ply = player.GetBySteamID(steamid)
        if not IsValid(ply) then
            -- Clean up animations for disconnected players
            BreathingSystem.Animations.ActiveAnimations[steamid] = nil
        else
            -- Update active animations
            for animationType, animationData in pairs(playerAnimations) do
                if animationData.active then
                    local elapsed = currentTime - animationData.startTime
                    local duration = animationData.config.duration or 1.0
                    local loop = animationData.config.loop or false
                    
                    if elapsed >= duration and not loop then
                        BreathingSystem.Animations.StopAnimation(ply, animationType)
                    end
                end
            end
        end
    end
end

-- Play breathing type animation
function BreathingSystem.Animations.PlayBreathingTypeAnimation(ply, breathingType)
    if not IsValid(ply) or not breathingType then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "breathing_type", breathingType)
end

-- Play form activation animation
function BreathingSystem.Animations.PlayFormAnimation(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "form_activation", formID)
end

-- Play total concentration animation
function BreathingSystem.Animations.PlayTotalConcentrationAnimation(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "total_concentration")
end

-- Play training animation
function BreathingSystem.Animations.PlayTrainingAnimation(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "training")
end

-- Play damage animation
function BreathingSystem.Animations.PlayDamageAnimation(ply, target)
    if not IsValid(ply) or not IsValid(target) then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "damage")
end

-- Play healing animation
function BreathingSystem.Animations.PlayHealingAnimation(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Animations.PlayAnimation(ply, "healing")
end

-- Initialize animation system
if SERVER then
    -- Update animations every second
    timer.Create("BreathingSystem_AnimationsUpdate", 1, 0, function()
        BreathingSystem.Animations.UpdateAnimations()
    end)
    
    print("[BreathingSystem.Animations] Animation effects system loaded")
end
