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

-- Initialize sounds module
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
        -- Water forms
        water_surface_slash = {
            sound = "breathingsystem/water_surface_slash.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        },
        water_water_wheel = {
            sound = "breathingsystem/water_wheel.wav",
            volume = 0.9,
            pitch = 1.0,
            loop = false
        },
        water_flowing_dance = {
            sound = "breathingsystem/water_flowing_dance.wav",
            volume = 0.7,
            pitch = 1.0,
            loop = false
        },
        water_waterfall_basin = {
            sound = "breathingsystem/water_waterfall_basin.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        water_constant_flux = {
            sound = "breathingsystem/water_constant_flux.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        
        -- Fire forms
        fire_unknowing_fire = {
            sound = "breathingsystem/fire_unknowing_fire.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        },
        fire_rising_scorching_sun = {
            sound = "breathingsystem/fire_rising_scorching_sun.wav",
            volume = 0.9,
            pitch = 1.0,
            loop = false
        },
        fire_blazing_universe = {
            sound = "breathingsystem/fire_blazing_universe.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        fire_sun_breathing = {
            sound = "breathingsystem/fire_sun_breathing.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        
        -- Thunder forms
        thunder_clap_flash = {
            sound = "breathingsystem/thunder_clap_flash.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        thunder_rice_spirit = {
            sound = "breathingsystem/thunder_rice_spirit.wav",
            volume = 0.9,
            pitch = 1.0,
            loop = false
        },
        thunder_honoikazuchi_no_kami = {
            sound = "breathingsystem/thunder_honoikazuchi_no_kami.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        
        -- Stone forms
        stone_surface_slash = {
            sound = "breathingsystem/stone_surface_slash.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        },
        stone_arcs_of_justice = {
            sound = "breathingsystem/stone_arcs_of_justice.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        },
        
        -- Wind forms
        wind_dust_whirlwind_cutter = {
            sound = "breathingsystem/wind_dust_whirlwind_cutter.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        },
        wind_idaten_typhoon = {
            sound = "breathingsystem/wind_idaten_typhoon.wav",
            volume = 1.0,
            pitch = 1.0,
            loop = false
        }
    },
    
    -- Special sounds
    special_sounds = {
        total_concentration = {
            sound = "breathingsystem/total_concentration.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = true
        },
        training = {
            sound = "breathingsystem/training.wav",
            volume = 0.6,
            pitch = 1.0,
            loop = true
        },
        damage = {
            sound = "breathingsystem/damage_impact.wav",
            volume = 0.9,
            pitch = 1.0,
            loop = false
        },
        healing = {
            sound = "breathingsystem/healing.wav",
            volume = 0.7,
            pitch = 1.0,
            loop = false
        },
        level_up = {
            sound = "breathingsystem/level_up.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        },
        form_unlock = {
            sound = "breathingsystem/form_unlock.wav",
            volume = 0.8,
            pitch = 1.0,
            loop = false
        }
    }
}

-- Active sounds per player
BreathingSystem.Sounds.ActiveSounds = BreathingSystem.Sounds.ActiveSounds or {}

-- Play sound
function BreathingSystem.Sounds.PlaySound(ply, soundType, formID)
    if not IsValid(ply) or not soundType then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Get sound configuration
    local soundConfig = BreathingSystem.Sounds.GetSoundConfig(soundType, formID)
    if not soundConfig then return false end
    
    -- Stop any existing sound of the same type if not looping
    if not soundConfig.loop then
        BreathingSystem.Sounds.StopSound(ply, soundType)
    end
    
    -- Create sound data
    local soundData = {
        player = ply,
        soundType = soundType,
        formID = formID,
        config = soundConfig,
        startTime = CurTime(),
        active = true
    }
    
    -- Store active sound
    local steamid = ply:SteamID()
    if not BreathingSystem.Sounds.ActiveSounds[steamid] then
        BreathingSystem.Sounds.ActiveSounds[steamid] = {}
    end
    
    BreathingSystem.Sounds.ActiveSounds[steamid][soundType] = soundData
    
    print("[BreathingSystem.Sounds] Playing " .. soundType .. " sound for " .. ply:Name())
    
    -- Trigger sound event
    hook.Run("BreathingSystem_SoundPlayed", ply, soundType, formID, soundConfig)
    
    return true
end

-- Stop sound
function BreathingSystem.Sounds.StopSound(ply, soundType)
    if not IsValid(ply) or not soundType then return false end
    
    local steamid = ply:SteamID()
    if not BreathingSystem.Sounds.ActiveSounds[steamid] then return false end
    
    local soundData = BreathingSystem.Sounds.ActiveSounds[steamid][soundType]
    if not soundData then return false end
    
    soundData.active = false
    BreathingSystem.Sounds.ActiveSounds[steamid][soundType] = nil
    
    print("[BreathingSystem.Sounds] Stopped " .. soundType .. " sound for " .. ply:Name())
    
    -- Trigger sound stop event
    hook.Run("BreathingSystem_SoundStopped", ply, soundType)
    
    return true
end

-- Get sound configuration
function BreathingSystem.Sounds.GetSoundConfig(soundType, formID)
    if not soundType then return nil end
    
    -- Check form-specific sounds first
    if formID and BreathingSystem.Sounds.Config.form_sounds[formID] then
        return BreathingSystem.Sounds.Config.form_sounds[formID]
    end
    
    -- Check breathing type sounds
    if soundType == "breathing_type" and formID then
        local form = BreathingSystem.Forms.GetForm(formID)
        if form then
            local breathingType = string.match(formID, "([^_]+)")
            if breathingType and BreathingSystem.Sounds.Config.breathing_type_sounds[breathingType] then
                return BreathingSystem.Sounds.Config.breathing_type_sounds[breathingType]
            end
        end
    end
    
    -- Check special sounds
    if BreathingSystem.Sounds.Config.special_sounds[soundType] then
        return BreathingSystem.Sounds.Config.special_sounds[soundType]
    end
    
    return nil
end

-- Register custom sound
function BreathingSystem.Sounds.RegisterCustomSound(name, config)
    if not name or not config then return false end
    
    BreathingSystem.Sounds.Config.special_sounds[name] = config
    
    print("[BreathingSystem.Sounds] Registered custom sound: " .. name)
    
    return true
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

-- Update sounds
function BreathingSystem.Sounds.UpdateSounds()
    local currentTime = CurTime()
    
    for steamid, playerSounds in pairs(BreathingSystem.Sounds.ActiveSounds) do
        local ply = player.GetBySteamID(steamid)
        if not IsValid(ply) then
            -- Clean up sounds for disconnected players
            BreathingSystem.Sounds.ActiveSounds[steamid] = nil
        else
            -- Update active sounds
            for soundType, soundData in pairs(playerSounds) do
                if soundData.active then
                    local elapsed = currentTime - soundData.startTime
                    local duration = soundData.config.duration or 1.0
                    local loop = soundData.config.loop or false
                    
                    if elapsed >= duration and not loop then
                        BreathingSystem.Sounds.StopSound(ply, soundType)
                    end
                end
            end
        end
    end
end

-- Play breathing type sound
function BreathingSystem.Sounds.PlayBreathingTypeSound(ply, breathingType)
    if not IsValid(ply) or not breathingType then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "breathing_type", breathingType)
end

-- Play form activation sound
function BreathingSystem.Sounds.PlayFormSound(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "form_activation", formID)
end

-- Play total concentration sound
function BreathingSystem.Sounds.PlayTotalConcentrationSound(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "total_concentration")
end

-- Play training sound
function BreathingSystem.Sounds.PlayTrainingSound(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "training")
end

-- Play damage sound
function BreathingSystem.Sounds.PlayDamageSound(ply, target)
    if not IsValid(ply) or not IsValid(target) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "damage")
end

-- Play healing sound
function BreathingSystem.Sounds.PlayHealingSound(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "healing")
end

-- Play level up sound
function BreathingSystem.Sounds.PlayLevelUpSound(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "level_up")
end

-- Play form unlock sound
function BreathingSystem.Sounds.PlayFormUnlockSound(ply)
    if not IsValid(ply) then return false end
    
    return BreathingSystem.Sounds.PlaySound(ply, "form_unlock")
end

-- Initialize sound system
if SERVER then
    -- Update sounds every second
    timer.Create("BreathingSystem_SoundsUpdate", 1, 0, function()
        BreathingSystem.Sounds.UpdateSounds()
    end)
    
    print("[BreathingSystem.Sounds] Sound effects system loaded")
end
