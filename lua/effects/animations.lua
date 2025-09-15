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

-- Only initialize on server
if SERVER then
    -- Initialize animations module
    BreathingSystem = BreathingSystem or {}
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
            water_surface_slash = {
                sequence = "water_slash",
                duration = 1.0,
                loop = false,
                speed = 1.0
            },
            fire_unknowing_fire = {
                sequence = "fire_punch",
                duration = 0.8,
                loop = false,
                speed = 1.2
            },
            thunder_clap_flash = {
                sequence = "thunder_dash",
                duration = 0.5,
                loop = false,
                speed = 2.0
            }
        },
        
        -- Special animations
        special_animations = {
            total_concentration = {
                sequence = "concentration_pose",
                duration = 5.0,
                loop = true,
                speed = 0.5
            },
            training = {
                sequence = "training_pose",
                duration = 3.0,
                loop = true,
                speed = 1.0
            },
            damage = {
                sequence = "damage_reaction",
                duration = 1.0,
                loop = false,
                speed = 1.0
            },
            healing = {
                sequence = "healing_pose",
                duration = 2.0,
                loop = true,
                speed = 0.8
            }
        }
    }
    
    -- Active animations per player
    BreathingSystem.Animations.ActiveAnimations = BreathingSystem.Animations.ActiveAnimations or {}
    
    -- Play animation
    function BreathingSystem.Animations.PlayAnimation(ply, animationType, formID)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        local animationConfig = BreathingSystem.Animations.GetAnimationConfig(animationType, formID)
        
        if not animationConfig then
            print("[BreathingSystem.Animations] No config found for animation: " .. tostring(animationType))
            return false
        end
        
        -- Create animation data
        local animationData = {
            config = animationConfig,
            startTime = CurTime(),
            ply = ply
        }
        
        -- Store active animation
        if not BreathingSystem.Animations.ActiveAnimations[steamid] then
            BreathingSystem.Animations.ActiveAnimations[steamid] = {}
        end
        BreathingSystem.Animations.ActiveAnimations[steamid][animationType] = animationData
        
        -- Send animation to client
        ply:SendLua("LocalPlayer():SetAnimation(ACT_" .. animationConfig.sequence .. ")")
        
        print("[BreathingSystem.Animations] Playing " .. animationType .. " animation for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_AnimationPlayed", ply, animationType, formID, animationConfig)
        
        return true
    end
    
    -- Stop animation
    function BreathingSystem.Animations.StopAnimation(ply, animationType)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        if not BreathingSystem.Animations.ActiveAnimations[steamid] then return false end
        
        local animationData = BreathingSystem.Animations.ActiveAnimations[steamid][animationType]
        if not animationData then return false end
        
        -- Remove from active animations
        BreathingSystem.Animations.ActiveAnimations[steamid][animationType] = nil
        
        -- Reset animation on client
        ply:SendLua("LocalPlayer():SetAnimation(ACT_IDLE)")
        
        print("[BreathingSystem.Animations] Stopped " .. animationType .. " animation for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_AnimationStopped", ply, animationType)
        
        return true
    end
    
    -- Get animation configuration
    function BreathingSystem.Animations.GetAnimationConfig(animationType, formID)
        -- Check form-specific animations first
        if formID and BreathingSystem.Animations.Config.form_animations[formID] then
            return BreathingSystem.Animations.Config.form_animations[formID]
        end
        
        -- Check breathing type animations
        local breathingType = nil
        if formID then
            local formData = BreathingSystem.Forms.GetForm(formID)
            if formData then
                breathingType = formData.breathing_type
            end
        end
        
        if breathingType and BreathingSystem.Animations.Config.breathing_type_animations[breathingType] then
            return BreathingSystem.Animations.Config.breathing_type_animations[breathingType]
        end
        
        -- Check special animations
        if BreathingSystem.Animations.Config.special_animations[animationType] then
            return BreathingSystem.Animations.Config.special_animations[animationType]
        end
        
        return nil
    end
    
    -- Register custom animation
    function BreathingSystem.Animations.RegisterCustomAnimation(name, config)
        BreathingSystem.Animations.Config.special_animations[name] = config
        print("[BreathingSystem.Animations] Registered custom animation: " .. name)
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
    
    -- Convenience functions
    function BreathingSystem.Animations.PlayBreathingTypeAnimation(ply, breathingType)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "breathing_type", breathingType)
    end
    
    function BreathingSystem.Animations.PlayFormAnimation(ply, formID)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "form_activation", formID)
    end
    
    function BreathingSystem.Animations.PlayTotalConcentrationAnimation(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "total_concentration")
    end
    
    function BreathingSystem.Animations.PlayTrainingAnimation(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "training")
    end
    
    function BreathingSystem.Animations.PlayDamageAnimation(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "damage")
    end
    
    function BreathingSystem.Animations.PlayHealingAnimation(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Animations.PlayAnimation(ply, "healing")
    end
    
    print("[BreathingSystem.Animations] Animation effects system loaded")
end
