--[[
    BreathingSystem - Breathing Type Template
    ========================================
    
    This is a template file for creating new breathing types.
    Copy this file and modify it to create your own breathing type.
    
    Instructions:
    1. Copy this file and rename it to your breathing type (e.g., "earth.lua")
    2. Replace "TEMPLATE" with your breathing type ID
    3. Replace "Template Breathing" with your breathing type name
    4. Add your forms to the forms table
    5. Modify the breathing type data as needed
    
    Example Usage:
    - Copy this file to "earth.lua"
    - Change typeID to "earth"
    - Add earth-based forms
    - The breathing type will be automatically registered
]]

-- Breathing Type Configuration
local typeID = "TEMPLATE"
local typeData = {
    name = "Template Breathing",
    description = "A template breathing type for developers to copy and modify",
    category = "elemental",
    color = Color(128, 128, 128), -- Gray color
    icon = "breathingsystem/template.png", -- Optional icon path
    
    -- Breathing type properties
    stamina_drain = 0,
    concentration_bonus = 0,
    damage_modifier = 1.0,
    speed_modifier = 1.0,
    jump_modifier = 1.0,
    
    -- Special properties
    special_abilities = {
        "template_ability_1",
        "template_ability_2"
    },
    
    -- Requirements to learn this breathing type
    requirements = {
        level = 1,
        previous_types = {}, -- Array of breathing type IDs that must be learned first
        items = {}, -- Array of required items
        quests = {} -- Array of required quest IDs
    }
}

-- Forms for this breathing type
local forms = {
    -- Form 1: Basic Form
    {
        id = "template_basic",
        name = "Template Basic Form",
        description = "The most basic form of template breathing",
        difficulty = 1,
        duration = 0, -- 0 = indefinite
        cooldown = 0,
        
        -- Form properties
        stamina_drain = 0,
        concentration_bonus = 1,
        damage_modifier = 1.0,
        speed_modifier = 1.0,
        
        -- Instructions for the player
        instructions = {
            "Breathe normally",
            "Focus on your breathing",
            "Maintain steady rhythm"
        },
        
        -- Visual/audio effects (client-side)
        effects = {
            particle_effect = "template_basic_particles",
            sound_effect = "template_basic_sound",
            screen_effect = "template_basic_screen"
        },
        
        -- Requirements to learn this form
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Intermediate Form
    {
        id = "template_intermediate",
        name = "Template Intermediate Form",
        description = "A more advanced form of template breathing",
        difficulty = 3,
        duration = 60, -- 1 minute
        cooldown = 30, -- 30 seconds
        
        stamina_drain = 1,
        concentration_bonus = 3,
        damage_modifier = 1.2,
        speed_modifier = 1.1,
        
        instructions = {
            "Inhale deeply for 4 counts",
            "Hold for 2 counts",
            "Exhale slowly for 6 counts",
            "Focus on the template energy"
        },
        
        effects = {
            particle_effect = "template_intermediate_particles",
            sound_effect = "template_intermediate_sound",
            screen_effect = "template_intermediate_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"template_basic"}
        }
    },
    
    -- Form 3: Advanced Form
    {
        id = "template_advanced",
        name = "Template Advanced Form",
        description = "The most powerful form of template breathing",
        difficulty = 5,
        duration = 120, -- 2 minutes
        cooldown = 60, -- 1 minute
        
        stamina_drain = 3,
        concentration_bonus = 5,
        damage_modifier = 1.5,
        speed_modifier = 1.3,
        
        instructions = {
            "Inhale for 6 counts",
            "Hold for 4 counts",
            "Exhale for 8 counts",
            "Channel template energy through your body",
            "Maintain perfect control"
        },
        
        effects = {
            particle_effect = "template_advanced_particles",
            sound_effect = "template_advanced_sound",
            screen_effect = "template_advanced_screen"
        },
        
        requirements = {
            level = 10,
            previous_forms = {"template_basic", "template_intermediate"}
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
    
    print("[BreathingSystem] Registered breathing type: " .. typeID .. " with " .. #forms .. " forms")
end

-- Return the breathing type data for external use
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms
}
