--[[
    BreathingSystem - Stone Breathing Type
    =====================================
    
    Stone breathing focuses on defense, endurance, and unbreakable strength.
    Forms are inspired by stone's properties: durability, stability, and unyielding nature.
    
    Characteristics:
    - High defense and damage resistance
    - Slow but powerful attacks
    - Earth/stone-based visual effects
    - Focus on defense and endurance
]]

-- Stone Breathing Type Configuration
local typeID = "stone"
local typeData = {
    name = "Stone Breathing",
    description = "A breathing style that channels the strength and endurance of stone",
    category = "elemental",
    color = Color(128, 128, 128), -- Gray color
    icon = "breathingsystem/stone.png",
    
    -- Stone breathing properties
    stamina_drain = 1,
    concentration_bonus = 3,
    damage_modifier = 1.1,
    speed_modifier = 0.8, -- Slower but more powerful
    jump_modifier = 0.9,
    
    -- Special abilities
    special_abilities = {
        "stone_endurance",
        "stone_defense",
        "stone_stability"
    },
    
    -- Requirements
    requirements = {
        level = 1,
        previous_types = {},
        items = {},
        quests = {}
    }
}

-- Stone Breathing Forms
local forms = {
    -- Form 1: Surface Slash
    {
        id = "stone_surface_slash",
        name = "Surface Slash",
        description = "A basic stone breathing form that mimics the cutting of stone",
        difficulty = 1,
        duration = 0,
        cooldown = 0,
        
        stamina_drain = 0,
        concentration_bonus = 2,
        damage_modifier = 1.0,
        speed_modifier = 0.9,
        
        instructions = {
            "Breathe in slowly, feeling the weight of stone",
            "Exhale steadily while making a cutting motion",
            "Focus on the strength and stability of stone",
            "Channel the unyielding nature of rock"
        },
        
        effects = {
            particle_effect = "stone_surface_particles",
            sound_effect = "stone_cut_sound",
            screen_effect = "stone_surface_screen"
        },
        
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Stone Skin
    {
        id = "stone_skin",
        name = "Stone Skin",
        description = "A defensive form that hardens the user's skin like stone",
        difficulty = 2,
        duration = 60,
        cooldown = 30,
        
        stamina_drain = 1,
        concentration_bonus = 3,
        damage_modifier = 0.8,
        speed_modifier = 0.7,
        
        instructions = {
            "Breathe in deeply, feeling your skin harden",
            "Hold your breath as you channel stone energy",
            "Exhale slowly, maintaining the stone skin",
            "Focus on becoming as hard as stone"
        },
        
        effects = {
            particle_effect = "stone_skin_particles",
            sound_effect = "stone_harden_sound",
            screen_effect = "stone_skin_screen"
        },
        
        requirements = {
            level = 3,
            previous_forms = {"stone_surface_slash"}
        }
    },
    
    -- Form 3: Volcanic Rock
    {
        id = "stone_volcanic_rock",
        name = "Volcanic Rock",
        description = "A powerful form that combines stone strength with volcanic heat",
        difficulty = 3,
        duration = 45,
        cooldown = 20,
        
        stamina_drain = 2,
        concentration_bonus = 4,
        damage_modifier = 1.3,
        speed_modifier = 0.85,
        
        instructions = {
            "Breathe in the heat of volcanic rock",
            "Channel both stone strength and volcanic energy",
            "Exhale with explosive power",
            "Focus on the combination of earth and fire"
        },
        
        effects = {
            particle_effect = "volcanic_rock_particles",
            sound_effect = "volcanic_rock_sound",
            screen_effect = "volcanic_rock_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"stone_surface_slash", "stone_skin"}
        }
    },
    
    -- Form 4: Upper Smash
    {
        id = "stone_upper_smash",
        name = "Upper Smash",
        description = "A powerful upward strike that mimics a stone pillar rising",
        difficulty = 4,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 3,
        concentration_bonus = 4,
        damage_modifier = 1.4,
        speed_modifier = 0.8,
        
        instructions = {
            "Breathe in while crouching low like a stone foundation",
            "Hold your breath as you prepare to rise",
            "Exhale explosively while striking upward",
            "Channel the power of a rising stone pillar"
        },
        
        effects = {
            particle_effect = "upper_smash_particles",
            sound_effect = "stone_rise_sound",
            screen_effect = "upper_smash_screen"
        },
        
        requirements = {
            level = 7,
            previous_forms = {"stone_surface_slash", "stone_skin", "stone_volcanic_rock"}
        }
    },
    
    -- Form 5: Arcs of Justice
    {
        id = "stone_arcs_of_justice",
        name = "Arcs of Justice",
        description = "The ultimate stone breathing form, creating massive stone arcs",
        difficulty = 5,
        duration = 90,
        cooldown = 45,
        
        stamina_drain = 4,
        concentration_bonus = 5,
        damage_modifier = 1.6,
        speed_modifier = 0.75,
        
        instructions = {
            "Breathe in the power of the earth itself",
            "Channel the strength of mountains",
            "Exhale as you create massive stone arcs",
            "Focus on the unyielding justice of stone"
        },
        
        effects = {
            particle_effect = "arcs_of_justice_particles",
            sound_effect = "stone_justice_sound",
            screen_effect = "arcs_of_justice_screen"
        },
        
        requirements = {
            level = 10,
            previous_forms = {"stone_surface_slash", "stone_skin", "stone_volcanic_rock", "stone_upper_smash"}
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
    
    print("[BreathingSystem] Registered Stone Breathing with " .. #forms .. " forms")
end

-- Return the breathing type data
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms
}
