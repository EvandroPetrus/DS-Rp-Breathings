--[[
    BreathingSystem - Sound Effects
    ==============================
    
    This module handles sound effects for breathing techniques.
    Provides placeholder sound triggers and hooks for customization.
    
    Responsibilities:
    - Manage sound effects for breathing forms
    - Handle technique activation sounds
    - Provide hooks for custom sounds
    - Manage sound cleanup and optimization
    
    Public API:
    - BreathingSystem.Sounds.PlaySound(ply, soundType, formID) - Play sound
    - BreathingSystem.Sounds.StopSound(ply, soundType) - Stop sound
    - BreathingSystem.Sounds.GetSoundConfig(soundType) - Get sound config
    - BreathingSystem.Sounds.RegisterCustomSound(name, config) - Register custom sound
]]

-- Only initialize on server
if SERVER then
    -- Initialize sounds module
    BreathingSystem = BreathingSystem or {}
    BreathingSystem.Sounds = BreathingSystem.Sounds or {}
    
    -- Sound effects configuration
    BreathingSystem.Sounds.Config = {
        -- Sound types
        sound_types = {
            "breathing_type",    -- Breathing type sounds
            "form_activation",   -- Form activation sounds
            "total_concentration", -- Total concentration sounds
            "training",          -- Training sounds
            "damage",            -- Damage sounds
            "healing"            -- Healing sounds
        },
        
        -- Breathing type sounds
        breathing_type_sounds = {
            water = {
                sound = "breathingsystem/water_flow.wav",
                volume = 0.7,
                pitch = 1.0,
                loop = true
            },
            fire = {
                sound = "breathingsystem/fire_crackle.wav",
                volume = 0.8,
                pitch = 1.0,
                loop = true
            },
            thunder = {
                sound = "breathingsystem/thunder_rumble.wav",
                volume = 0.9,
                pitch = 1.0,
                loop = true
            },
            stone = {
                sound = "breathingsystem/stone_grind.wav",
                volume = 0.6,
                pitch = 1.0,
                loop = true
            },
            wind = {
                sound = "breathingsystem/wind_howl.wav",
                volume = 0.7,
                pitch = 1.0,
                loop = true
            }
        },
        
        -- Form-specific sounds
        form_sounds = {
            water_surface_slash = {
                sound = "breathingsystem/water_slash.wav",
                volume = 0.8,
                pitch = 1.0,
                loop = false
            },
            fire_unknowing_fire = {
                sound = "breathingsystem/fire_ignite.wav",
                volume = 0.9,
                pitch = 1.0,
                loop = false
            },
            thunder_clap_flash = {
                sound = "breathingsystem/thunder_clap.wav",
                volume = 1.0,
                pitch = 1.0,
                loop = false
            }
        },
        
        -- Special sounds
        special_sounds = {
            total_concentration = {
                sound = "breathingsystem/concentration.wav",
                volume = 0.8,
                pitch = 1.0,
                loop = true
            },
            training = {
                sound = "breathingsystem/training.wav",
                volume = 0.6,
                pitch = 1.0,
                loop = false
            },
            damage = {
                sound = "breathingsystem/impact.wav",
                volume = 0.9,
                pitch = 1.0,
                loop = false
            },
            healing = {
                sound = "breathingsystem/healing.wav",
                volume = 0.7,
                pitch = 1.0,
                loop = false
            }
        }
    }
    
    -- Active sounds per player
    BreathingSystem.Sounds.ActiveSounds = BreathingSystem.Sounds.ActiveSounds or {}
    
    -- Play sound
    function BreathingSystem.Sounds.PlaySound(ply, soundType, formID)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        local soundConfig = BreathingSystem.Sounds.GetSoundConfig(soundType, formID)
        
        if not soundConfig then
            print("[BreathingSystem.Sounds] No config found for sound: " .. tostring(soundType))
            return false
        end
        
        -- Create sound data
        local soundData = {
            config = soundConfig,
            startTime = CurTime(),
            ply = ply
        }
        
        -- Store active sound
        if not BreathingSystem.Sounds.ActiveSounds[steamid] then
            BreathingSystem.Sounds.ActiveSounds[steamid] = {}
        end
        BreathingSystem.Sounds.ActiveSounds[steamid][soundType] = soundData
        
        -- Play sound on client
        ply:SendLua("surface.PlaySound(\"" .. soundConfig.sound .. "\")")
        
        print("[BreathingSystem.Sounds] Playing " .. soundType .. " sound for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_SoundPlayed", ply, soundType, formID, soundConfig)
        
        return true
    end
    
    -- Stop sound
    function BreathingSystem.Sounds.StopSound(ply, soundType)
        if not IsValid(ply) then return false end
        
        local steamid = ply:SteamID()
        if not BreathingSystem.Sounds.ActiveSounds[steamid] then return false end
        
        local soundData = BreathingSystem.Sounds.ActiveSounds[steamid][soundType]
        if not soundData then return false end
        
        -- Remove from active sounds
        BreathingSystem.Sounds.ActiveSounds[steamid][soundType] = nil
        
        print("[BreathingSystem.Sounds] Stopped " .. soundType .. " sound for " .. ply:Name())
        
        -- Run hook
        hook.Run("BreathingSystem_SoundStopped", ply, soundType)
        
        return true
    end
    
    -- Get sound configuration
    function BreathingSystem.Sounds.GetSoundConfig(soundType, formID)
        -- Check form-specific sounds first
        if formID and BreathingSystem.Sounds.Config.form_sounds[formID] then
            return BreathingSystem.Sounds.Config.form_sounds[formID]
        end
        
        -- Check breathing type sounds
        local breathingType = nil
        if formID then
            local formData = BreathingSystem.Forms.GetForm(formID)
            if formData then
                breathingType = formData.breathing_type
            end
        end
        
        if breathingType and BreathingSystem.Sounds.Config.breathing_type_sounds[breathingType] then
            return BreathingSystem.Sounds.Config.breathing_type_sounds[breathingType]
        end
        
        -- Check special sounds
        if BreathingSystem.Sounds.Config.special_sounds[soundType] then
            return BreathingSystem.Sounds.Config.special_sounds[soundType]
        end
        
        return nil
    end
    
    -- Register custom sound
    function BreathingSystem.Sounds.RegisterCustomSound(name, config)
        BreathingSystem.Sounds.Config.special_sounds[name] = config
        print("[BreathingSystem.Sounds] Registered custom sound: " .. name)
    end
    
    -- Get active sounds for player
    function BreathingSystem.Sounds.GetActiveSounds(ply)
        if not IsValid(ply) then return {} end
        local steamid = ply:SteamID()
        return BreathingSystem.Sounds.ActiveSounds[steamid] or {}
    end
    
    -- Stop all sounds for player
    function BreathingSystem.Sounds.StopAllSounds(ply)
        if not IsValid(ply) then return false end
        local steamid = ply:SteamID()
        if not BreathingSystem.Sounds.ActiveSounds[steamid] then return false end
        
        for soundType, soundData in pairs(BreathingSystem.Sounds.ActiveSounds[steamid]) do
            BreathingSystem.Sounds.StopSound(ply, soundType)
        end
        
        return true
    end
    
    -- Convenience functions
    function BreathingSystem.Sounds.PlayBreathingTypeSound(ply, breathingType)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "breathing_type", breathingType)
    end
    
    function BreathingSystem.Sounds.PlayFormSound(ply, formID)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "form_activation", formID)
    end
    
    function BreathingSystem.Sounds.PlayTotalConcentrationSound(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "total_concentration")
    end
    
    function BreathingSystem.Sounds.PlayTrainingSound(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "training")
    end
    
    function BreathingSystem.Sounds.PlayDamageSound(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "damage")
    end
    
    function BreathingSystem.Sounds.PlayHealingSound(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Sounds.PlaySound(ply, "healing")
    end
    
    print("[BreathingSystem.Sounds] Sound effects system loaded")
end
