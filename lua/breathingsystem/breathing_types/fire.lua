--[[
    BreathingSystem - Fire Breathing Type
    ====================================
    
    Fire breathing focuses on power, aggression, and destruction.
    Forms are inspired by fire's properties: heat, intensity, and explosive power.
    
    Characteristics:
    - High damage and offensive capabilities
    - Intense, aggressive movements
    - Fire-based visual effects
    - Focus on attack and power
]]

-- Fire Breathing Type Configuration
local typeID = "fire"
local typeData = {
    name = "Fire Breathing",
    description = "A breathing style that channels the power and intensity of fire",
    category = "elemental",
    color = Color(255, 100, 0), -- Orange-red color
    icon = "breathingsystem/fire.png",
    
    -- Fire breathing properties
    stamina_drain = 2,
    concentration_bonus = 1,
    damage_modifier = 1.3, -- High damage
    speed_modifier = 1.1,
    jump_modifier = 1.0,
    
    -- Special abilities
    special_abilities = {
        "fire_ignition",
        "fire_explosion",
        "fire_rage"
    },
    
    -- Requirements
    requirements = {
        level = 1,
        previous_types = {},
        items = {},
        quests = {}
    }
}

-- Fire Breathing Forms
local forms = {
    -- Form 1: Unknowing Fire
    {
        id = "fire_unknowing_fire",
        name = "Unknowing Fire",
        description = "The most basic fire breathing form, igniting the inner flame",
        difficulty = 1,
        duration = 0,
        cooldown = 0,
        
        stamina_drain = 1,
        concentration_bonus = 0,
        damage_modifier = 1.1,
        speed_modifier = 1.0,
        
        instructions = {
            "Breathe in deeply, feeling the heat build",
            "Exhale sharply, releasing the fire within",
            "Focus on your inner flame",
            "Channel your passion and energy"
        },
        
        effects = {
            particle_effect = "fire_unknowing_particles",
            sound_effect = "fire_ignite_sound",
            screen_effect = "fire_unknowing_screen"
        },
        
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Rising Scorching Sun
    {
        id = "fire_rising_scorching_sun",
        name = "Rising Scorching Sun",
        description = "A powerful upward strike that mimics the rising sun",
        difficulty = 2,
        duration = 20,
        cooldown = 10,
        
        stamina_drain = 2,
        concentration_bonus = 1,
        damage_modifier = 1.2,
        speed_modifier = 1.05,
        
        instructions = {
            "Inhale while crouching low",
            "Hold your breath as you prepare",
            "Exhale explosively while rising up",
            "Channel the power of the rising sun"
        },
        
        effects = {
            particle_effect = "rising_sun_particles",
            sound_effect = "fire_rise_sound",
            screen_effect = "rising_sun_screen"
        },
        
        requirements = {
            level = 3,
            previous_forms = {"fire_unknowing_fire"}
        }
    },
    
    -- Form 3: Blazing Universe
    {
        id = "fire_blazing_universe",
        name = "Blazing Universe",
        description = "A spinning attack that creates a ring of fire",
        difficulty = 3,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 3,
        concentration_bonus = 2,
        damage_modifier = 1.3,
        speed_modifier = 1.1,
        
        instructions = {
            "Breathe in while spinning slowly",
            "Accelerate your breathing with your spin",
            "Exhale in bursts as you strike",
            "Create a blazing ring of fire around you"
        },
        
        effects = {
            particle_effect = "blazing_universe_particles",
            sound_effect = "fire_spin_sound",
            screen_effect = "blazing_universe_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun"}
        }
    },
    
    -- Form 4: Blooming Flame Undulation
    {
        id = "fire_blooming_flame_undulation",
        name = "Blooming Flame Undulation",
        description = "A flowing attack that creates waves of fire",
        difficulty = 3,
        duration = 40,
        cooldown = 20,
        
        stamina_drain = 2,
        concentration_bonus = 2,
        damage_modifier = 1.25,
        speed_modifier = 1.0,
        
        instructions = {
            "Breathe in rhythm with wave-like motions",
            "Exhale in flowing, undulating patterns",
            "Create waves of fire energy",
            "Flow like fire across the battlefield"
        },
        
        effects = {
            particle_effect = "blooming_flame_particles",
            sound_effect = "fire_wave_sound",
            screen_effect = "blooming_flame_screen"
        },
        
        requirements = {
            level = 6,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun"}
        }
    },
    
    -- Form 5: Tiger
    {
        id = "fire_tiger",
        name = "Tiger",
        description = "A fierce, clawing attack that mimics a tiger's strike",
        difficulty = 4,
        duration = 25,
        cooldown = 12,
        
        stamina_drain = 3,
        concentration_bonus = 2,
        damage_modifier = 1.4,
        speed_modifier = 1.15,
        
        instructions = {
            "Breathe in like a tiger stalking prey",
            "Hold your breath as you prepare to strike",
            "Exhale explosively with clawing motions",
            "Channel the ferocity of a tiger"
        },
        
        effects = {
            particle_effect = "fire_tiger_particles",
            sound_effect = "tiger_roar_sound",
            screen_effect = "fire_tiger_screen"
        },
        
        requirements = {
            level = 7,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blazing_universe"}
        }
    },
    
    -- Form 6: Rengoku
    {
        id = "fire_rengoku",
        name = "Rengoku",
        description = "A devastating slash that cuts through everything",
        difficulty = 4,
        duration = 35,
        cooldown = 18,
        
        stamina_drain = 4,
        concentration_bonus = 3,
        damage_modifier = 1.5,
        speed_modifier = 1.0,
        
        instructions = {
            "Inhale deeply, focusing all your energy",
            "Hold your breath as you channel power",
            "Exhale with a single, devastating slash",
            "Cut through everything in your path"
        },
        
        effects = {
            particle_effect = "rengoku_particles",
            sound_effect = "fire_slash_sound",
            screen_effect = "rengoku_screen"
        },
        
        requirements = {
            level = 9,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blazing_universe", "fire_tiger"}
        }
    },
    
    -- Form 7: Flame Dance
    {
        id = "fire_flame_dance",
        name = "Flame Dance",
        description = "A rapid series of strikes that create a dance of fire",
        difficulty = 4,
        duration = 45,
        cooldown = 25,
        
        stamina_drain = 3,
        concentration_bonus = 3,
        damage_modifier = 1.3,
        speed_modifier = 1.2,
        
        instructions = {
            "Breathe rapidly in rhythm with your strikes",
            "Move like fire dancing in the wind",
            "Create a rapid series of fire attacks",
            "Maintain the dance of destruction"
        },
        
        effects = {
            particle_effect = "flame_dance_particles",
            sound_effect = "fire_dance_sound",
            screen_effect = "flame_dance_screen"
        },
        
        requirements = {
            level = 10,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blooming_flame_undulation", "fire_tiger"}
        }
    },
    
    -- Form 8: Hinokami Kagura
    {
        id = "fire_hinokami_kagura",
        name = "Hinokami Kagura",
        description = "The sacred fire dance, the ultimate fire breathing form",
        difficulty = 5,
        duration = 60,
        cooldown = 30,
        
        stamina_drain = 5,
        concentration_bonus = 4,
        damage_modifier = 1.6,
        speed_modifier = 1.25,
        
        instructions = {
            "Breathe in the sacred fire energy",
            "Perform the ancient dance of fire",
            "Channel the power of the fire god",
            "Release the ultimate fire technique"
        },
        
        effects = {
            particle_effect = "hinokami_kagura_particles",
            sound_effect = "sacred_fire_sound",
            screen_effect = "hinokami_kagura_screen"
        },
        
        requirements = {
            level = 15,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blazing_universe", "fire_tiger", "fire_rengoku", "fire_flame_dance"}
        }
    },
    
    -- Form 9: Sun Breathing
    {
        id = "fire_sun_breathing",
        name = "Sun Breathing",
        description = "The original breathing style, channeling the power of the sun itself",
        difficulty = 5,
        duration = 90,
        cooldown = 45,
        
        stamina_drain = 6,
        concentration_bonus = 5,
        damage_modifier = 1.8,
        speed_modifier = 1.3,
        
        instructions = {
            "Breathe in the light of the sun",
            "Channel the power of the solar system",
            "Release the ultimate solar energy",
            "Become one with the sun itself"
        },
        
        effects = {
            particle_effect = "sun_breathing_particles",
            sound_effect = "solar_power_sound",
            screen_effect = "sun_breathing_screen"
        },
        
        requirements = {
            level = 20,
            previous_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blazing_universe", "fire_tiger", "fire_rengoku", "fire_flame_dance", "fire_hinokami_kagura"}
        }
    }
}

-- Register the breathing type
if SERVER then
    -- Register the breathing type
    BreathingSystem.Config.RegisterBreathingType(typeID, typeData)
    
    -- Register all forms
    for _, form in ipairs(forms) do
        BreathingSystem.Forms.RegisterForm(form.id, form)
    end
    
    print("[BreathingSystem] Registered Fire Breathing with " .. #forms .. " forms")
end

-- Return the breathing type data
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms
}
