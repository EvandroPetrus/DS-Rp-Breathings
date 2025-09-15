--[[
    BreathingSystem - Wind Breathing Type
    ====================================
    
    Wind breathing focuses on freedom, movement, and cutting power.
    Forms are inspired by wind's properties: flow, cutting, and freedom of movement.
    
    Characteristics:
    - High mobility and freedom of movement
    - Cutting and slashing attacks
    - Wind-based visual effects
    - Focus on speed and precision
]]

-- Wind Breathing Type Configuration
local typeID = "wind"
local typeData = {
    name = "Wind Breathing",
    description = "A breathing style that channels the freedom and cutting power of wind",
    category = "elemental",
    color = Color(200, 200, 255), -- Light blue color
    icon = "breathingsystem/wind.png",
    
    -- Wind breathing properties
    stamina_drain = 1,
    concentration_bonus = 2,
    damage_modifier = 1.1,
    speed_modifier = 1.2,
    jump_modifier = 1.2,
    
    -- Special abilities
    special_abilities = {
        "wind_freedom",
        "wind_cutting",
        "wind_movement"
    },
    
    -- Requirements
    requirements = {
        level = 1,
        previous_types = {},
        items = {},
        quests = {}
    }
}

-- Wind Breathing Forms
local forms = {
    -- Form 1: Dust Whirlwind Cutter
    {
        id = "wind_dust_whirlwind_cutter",
        name = "Dust Whirlwind Cutter",
        description = "A basic wind breathing form that creates a cutting whirlwind",
        difficulty = 1,
        duration = 0,
        cooldown = 0,
        
        stamina_drain = 1,
        concentration_bonus = 1,
        damage_modifier = 1.0,
        speed_modifier = 1.1,
        
        instructions = {
            "Breathe in like drawing in wind",
            "Exhale while creating a cutting motion",
            "Focus on the freedom of wind",
            "Channel the cutting power of air"
        },
        
        effects = {
            particle_effect = "dust_whirlwind_particles",
            sound_effect = "wind_cut_sound",
            screen_effect = "dust_whirlwind_screen"
        },
        
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Claws-Purifying Wind
    {
        id = "wind_claws_purifying_wind",
        name = "Claws-Purifying Wind",
        description = "A defensive form that creates a purifying wind barrier",
        difficulty = 2,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 1,
        concentration_bonus = 2,
        damage_modifier = 0.9,
        speed_modifier = 1.0,
        
        instructions = {
            "Breathe in while creating claw-like motions",
            "Hold your breath as you channel purifying energy",
            "Exhale slowly, creating a wind barrier",
            "Focus on purification and protection"
        },
        
        effects = {
            particle_effect = "claws_purifying_particles",
            sound_effect = "wind_purify_sound",
            screen_effect = "claws_purifying_screen"
        },
        
        requirements = {
            level = 3,
            previous_forms = {"wind_dust_whirlwind_cutter"}
        }
    },
    
    -- Form 3: Clean Storm Wind Tree
    {
        id = "wind_clean_storm_wind_tree",
        name = "Clean Storm Wind Tree",
        description = "A powerful form that creates a storm of cutting winds",
        difficulty = 3,
        duration = 40,
        cooldown = 20,
        
        stamina_drain = 2,
        concentration_bonus = 3,
        damage_modifier = 1.2,
        speed_modifier = 1.15,
        
        instructions = {
            "Breathe in the power of a storm",
            "Channel multiple cutting winds",
            "Exhale as you release the storm",
            "Focus on the destructive power of wind"
        },
        
        effects = {
            particle_effect = "clean_storm_particles",
            sound_effect = "wind_storm_sound",
            screen_effect = "clean_storm_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind"}
        }
    },
    
    -- Form 4: Rising Dust Storm
    {
        id = "wind_rising_dust_storm",
        name = "Rising Dust Storm",
        description = "An upward attack that creates a rising dust storm",
        difficulty = 3,
        duration = 25,
        cooldown = 12,
        
        stamina_drain = 2,
        concentration_bonus = 2,
        damage_modifier = 1.1,
        speed_modifier = 1.2,
        
        instructions = {
            "Breathe in while crouching low",
            "Hold your breath as you prepare to rise",
            "Exhale explosively while rising up",
            "Channel the power of a rising dust storm"
        },
        
        effects = {
            particle_effect = "rising_dust_particles",
            sound_effect = "dust_storm_sound",
            screen_effect = "rising_dust_screen"
        },
        
        requirements = {
            level = 6,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind"}
        }
    },
    
    -- Form 5: Cold Mountain Wind
    {
        id = "wind_cold_mountain_wind",
        name = "Cold Mountain Wind",
        description = "A chilling form that freezes enemies with cold wind",
        difficulty = 4,
        duration = 35,
        cooldown = 18,
        
        stamina_drain = 3,
        concentration_bonus = 3,
        damage_modifier = 1.3,
        speed_modifier = 1.1,
        
        instructions = {
            "Breathe in the cold mountain air",
            "Channel the freezing power of wind",
            "Exhale slowly, releasing cold energy",
            "Focus on the chilling power of wind"
        },
        
        effects = {
            particle_effect = "cold_mountain_particles",
            sound_effect = "cold_wind_sound",
            screen_effect = "cold_mountain_screen"
        },
        
        requirements = {
            level = 7,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind", "wind_clean_storm_wind_tree"}
        }
    },
    
    -- Form 6: Black Wind Mountain
    {
        id = "wind_black_wind_mountain",
        name = "Black Wind Mountain",
        description = "A dark form that creates a mountain of black wind",
        difficulty = 4,
        duration = 50,
        cooldown = 25,
        
        stamina_drain = 3,
        concentration_bonus = 4,
        damage_modifier = 1.4,
        speed_modifier = 1.0,
        
        instructions = {
            "Breathe in the dark power of black wind",
            "Channel the strength of a mountain",
            "Exhale as you create a black wind mountain",
            "Focus on the overwhelming power of wind"
        },
        
        effects = {
            particle_effect = "black_wind_particles",
            sound_effect = "black_wind_sound",
            screen_effect = "black_wind_screen"
        },
        
        requirements = {
            level = 9,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind", "wind_clean_storm_wind_tree", "wind_rising_dust_storm"}
        }
    },
    
    -- Form 7: Gale, Sudden Gusts
    {
        id = "wind_gale_sudden_gusts",
        name = "Gale, Sudden Gusts",
        description = "A rapid form that creates sudden gusts of wind",
        difficulty = 4,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 2,
        concentration_bonus = 3,
        damage_modifier = 1.2,
        speed_modifier = 1.3,
        
        instructions = {
            "Breathe rapidly in sudden bursts",
            "Channel the power of sudden gusts",
            "Exhale in quick, powerful bursts",
            "Focus on the unpredictability of wind"
        },
        
        effects = {
            particle_effect = "gale_gusts_particles",
            sound_effect = "wind_gusts_sound",
            screen_effect = "gale_gusts_screen"
        },
        
        requirements = {
            level = 8,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind", "wind_rising_dust_storm", "wind_cold_mountain_wind"}
        }
    },
    
    -- Form 8: Primary Gale Slash
    {
        id = "wind_primary_gale_slash",
        name = "Primary Gale Slash",
        description = "A powerful primary attack that creates a massive gale slash",
        difficulty = 5,
        duration = 45,
        cooldown = 30,
        
        stamina_drain = 4,
        concentration_bonus = 4,
        damage_modifier = 1.5,
        speed_modifier = 1.25,
        
        instructions = {
            "Breathe in the power of a primary gale",
            "Channel the ultimate wind energy",
            "Exhale as you create a massive slash",
            "Focus on the primary power of wind"
        },
        
        effects = {
            particle_effect = "primary_gale_particles",
            sound_effect = "primary_gale_sound",
            screen_effect = "primary_gale_screen"
        },
        
        requirements = {
            level = 11,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind", "wind_clean_storm_wind_tree", "wind_rising_dust_storm", "wind_cold_mountain_wind", "wind_black_wind_mountain"}
        }
    },
    
    -- Form 9: Idaten Typhoon
    {
        id = "wind_idaten_typhoon",
        name = "Idaten Typhoon",
        description = "The ultimate wind breathing form, creating a devastating typhoon",
        difficulty = 5,
        duration = 60,
        cooldown = 45,
        
        stamina_drain = 5,
        concentration_bonus = 5,
        damage_modifier = 1.7,
        speed_modifier = 1.4,
        
        instructions = {
            "Breathe in the power of a typhoon",
            "Channel the ultimate wind energy",
            "Exhale as you create a devastating typhoon",
            "Focus on the overwhelming power of wind"
        },
        
        effects = {
            particle_effect = "idaten_typhoon_particles",
            sound_effect = "typhoon_sound",
            screen_effect = "idaten_typhoon_screen"
        },
        
        requirements = {
            level = 15,
            previous_forms = {"wind_dust_whirlwind_cutter", "wind_claws_purifying_wind", "wind_clean_storm_wind_tree", "wind_rising_dust_storm", "wind_cold_mountain_wind", "wind_black_wind_mountain", "wind_gale_sudden_gusts", "wind_primary_gale_slash"}
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
    
    print("[BreathingSystem] Registered Wind Breathing with " .. #forms .. " forms")
end

-- Return the breathing type data
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms
}
