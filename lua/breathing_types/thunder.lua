--[[
    BreathingSystem - Thunder Breathing Type
    =======================================
    
    Thunder breathing focuses on speed, precision, and electrical power.
    Forms are inspired by lightning's properties: speed, electricity, and precision.
    
    Characteristics:
    - Extremely high speed and mobility
    - Electrical damage and effects
    - Lightning-based visual effects
    - Focus on speed and precision strikes
]]

-- Thunder Breathing Type Configuration
local typeID = "thunder"
local typeData = {
    name = "Thunder Breathing",
    description = "A breathing style that channels the speed and power of lightning",
    category = "elemental",
    color = Color(255, 255, 0), -- Yellow color
    icon = "breathingsystem/thunder.png",
    
    -- Thunder breathing properties
    stamina_drain = 3,
    concentration_bonus = 2,
    damage_modifier = 1.2,
    speed_modifier = 1.4, -- Very high speed
    jump_modifier = 1.3,
    
    -- Special abilities
    special_abilities = {
        "thunder_speed",
        "thunder_electricity",
        "thunder_precision"
    },
    
    -- Requirements
    requirements = {
        level = 1,
        previous_types = {},
        items = {},
        quests = {}
    }
}

-- Thunder Breathing Forms
local forms = {
    -- Form 1: Thunderclap and Flash
    {
        id = "thunder_clap_flash",
        name = "Thunderclap and Flash",
        description = "The basic thunder breathing form, creating a burst of speed",
        difficulty = 1,
        duration = 0,
        cooldown = 0,
        
        stamina_drain = 2,
        concentration_bonus = 1,
        damage_modifier = 1.1,
        speed_modifier = 1.2,
        
        instructions = {
            "Breathe in quickly, feeling the electricity build",
            "Exhale sharply while moving at lightning speed",
            "Focus on speed and precision",
            "Channel the power of thunder"
        },
        
        effects = {
            particle_effect = "thunder_clap_particles",
            sound_effect = "thunder_clap_sound",
            screen_effect = "thunder_flash_screen"
        },
        
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Rice Spirit
    {
        id = "thunder_rice_spirit",
        name = "Rice Spirit",
        description = "A rapid series of strikes that mimic rice being threshed",
        difficulty = 2,
        duration = 20,
        cooldown = 10,
        
        stamina_drain = 3,
        concentration_bonus = 2,
        damage_modifier = 1.2,
        speed_modifier = 1.3,
        
        instructions = {
            "Breathe rapidly in rhythm with your strikes",
            "Move like lightning through rice fields",
            "Create a rapid series of electrical attacks",
            "Focus on the precision of each strike"
        },
        
        effects = {
            particle_effect = "rice_spirit_particles",
            sound_effect = "thunder_rapid_sound",
            screen_effect = "rice_spirit_screen"
        },
        
        requirements = {
            level = 3,
            previous_forms = {"thunder_clap_flash"}
        }
    },
    
    -- Form 3: Thunder Swarm
    {
        id = "thunder_swarm",
        name = "Thunder Swarm",
        description = "Multiple lightning strikes that swarm the target",
        difficulty = 3,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 4,
        concentration_bonus = 3,
        damage_modifier = 1.3,
        speed_modifier = 1.35,
        
        instructions = {
            "Breathe in while channeling multiple lightning bolts",
            "Exhale as you release the swarm",
            "Control multiple electrical attacks simultaneously",
            "Focus on overwhelming the target"
        },
        
        effects = {
            particle_effect = "thunder_swarm_particles",
            sound_effect = "thunder_swarm_sound",
            screen_effect = "thunder_swarm_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit"}
        }
    },
    
    -- Form 4: Heat Lightning
    {
        id = "thunder_heat_lightning",
        name = "Heat Lightning",
        description = "A powerful electrical attack that generates intense heat",
        difficulty = 3,
        duration = 25,
        cooldown = 12,
        
        stamina_drain = 3,
        concentration_bonus = 2,
        damage_modifier = 1.4,
        speed_modifier = 1.25,
        
        instructions = {
            "Breathe in deeply, feeling the heat build",
            "Hold your breath as you channel electrical energy",
            "Exhale explosively, releasing heat lightning",
            "Focus on the combination of heat and electricity"
        },
        
        effects = {
            particle_effect = "heat_lightning_particles",
            sound_effect = "heat_lightning_sound",
            screen_effect = "heat_lightning_screen"
        },
        
        requirements = {
            level = 6,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit"}
        }
    },
    
    -- Form 5: Thunder Breathing First Form: Thunderclap and Flash (Sixfold)
    {
        id = "thunder_clap_flash_sixfold",
        name = "Thunderclap and Flash (Sixfold)",
        description = "An advanced version of the basic form with six rapid strikes",
        difficulty = 4,
        duration = 35,
        cooldown = 18,
        
        stamina_drain = 5,
        concentration_bonus = 4,
        damage_modifier = 1.5,
        speed_modifier = 1.4,
        
        instructions = {
            "Breathe in six quick breaths",
            "Channel six lightning bolts simultaneously",
            "Exhale as you release all six strikes",
            "Focus on perfect timing and coordination"
        },
        
        effects = {
            particle_effect = "thunder_sixfold_particles",
            sound_effect = "thunder_sixfold_sound",
            screen_effect = "thunder_sixfold_screen"
        },
        
        requirements = {
            level = 8,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit", "thunder_swarm"}
        }
    },
    
    -- Form 6: Thunder Breathing Seventh Form: Honoikazuchi no Kami
    {
        id = "thunder_honoikazuchi_no_kami",
        name = "Honoikazuchi no Kami",
        description = "The ultimate thunder breathing form, channeling the god of thunder",
        difficulty = 5,
        duration = 60,
        cooldown = 30,
        
        stamina_drain = 6,
        concentration_bonus = 5,
        damage_modifier = 1.7,
        speed_modifier = 1.5,
        
        instructions = {
            "Breathe in the power of the thunder god",
            "Channel the ultimate electrical energy",
            "Exhale as you become one with lightning",
            "Release the power of the storm itself"
        },
        
        effects = {
            particle_effect = "honoikazuchi_particles",
            sound_effect = "thunder_god_sound",
            screen_effect = "honoikazuchi_screen"
        },
        
        requirements = {
            level = 12,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit", "thunder_swarm", "thunder_heat_lightning", "thunder_clap_flash_sixfold"}
        }
    }
}

-- Thunder Breathing Variants
local variants = {
    -- Variant 1: Thunder Breathing First Form: Thunderclap and Flash (Eightfold)
    {
        id = "thunder_clap_flash_eightfold",
        name = "Thunderclap and Flash (Eightfold)",
        description = "An even more advanced version with eight rapid strikes",
        difficulty = 5,
        duration = 40,
        cooldown = 20,
        
        stamina_drain = 6,
        concentration_bonus = 4,
        damage_modifier = 1.6,
        speed_modifier = 1.45,
        
        instructions = {
            "Breathe in eight quick breaths",
            "Channel eight lightning bolts simultaneously",
            "Exhale as you release all eight strikes",
            "Focus on perfect timing and coordination"
        },
        
        effects = {
            particle_effect = "thunder_eightfold_particles",
            sound_effect = "thunder_eightfold_sound",
            screen_effect = "thunder_eightfold_screen"
        },
        
        requirements = {
            level = 10,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit", "thunder_swarm", "thunder_clap_flash_sixfold"}
        }
    },
    
    -- Variant 2: Thunder Breathing First Form: Thunderclap and Flash (God Speed)
    {
        id = "thunder_clap_flash_god_speed",
        name = "Thunderclap and Flash (God Speed)",
        description = "The ultimate speed variant, moving at god-like speed",
        difficulty = 5,
        duration = 50,
        cooldown = 25,
        
        stamina_drain = 7,
        concentration_bonus = 5,
        damage_modifier = 1.8,
        speed_modifier = 1.6,
        
        instructions = {
            "Breathe in the speed of the gods",
            "Channel ultimate electrical velocity",
            "Exhale as you move at god speed",
            "Become one with the lightning itself"
        },
        
        effects = {
            particle_effect = "thunder_god_speed_particles",
            sound_effect = "thunder_god_speed_sound",
            screen_effect = "thunder_god_speed_screen"
        },
        
        requirements = {
            level = 15,
            previous_forms = {"thunder_clap_flash", "thunder_rice_spirit", "thunder_swarm", "thunder_clap_flash_sixfold", "thunder_clap_flash_eightfold"}
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
    
    -- Register variants as additional forms
    for _, variant in ipairs(variants) do
        BreathingSystem.Forms.RegisterForm(variant.id, variant)
    end
    
    print("[BreathingSystem] Registered Thunder Breathing with " .. #forms .. " forms and " .. #variants .. " variants")
end

-- Return the breathing type data
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms,
    variants = variants
}
