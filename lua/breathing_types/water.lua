--[[
    BreathingSystem - Water Breathing Type
    =====================================
    
    Water breathing focuses on fluidity, adaptability, and healing.
    Forms are inspired by water's properties: flow, pressure, and life-giving nature.
    
    Characteristics:
    - High healing and regeneration
    - Fluid, adaptable movements
    - Water-based visual effects
    - Focus on defense and support
]]

-- Water Breathing Type Configuration
local typeID = "water"
local typeData = {
    name = "Water Breathing",
    description = "A breathing style that mimics the flow and adaptability of water",
    category = "elemental",
    color = Color(0, 150, 255), -- Blue color
    icon = "breathingsystem/water.png",
    
    -- Water breathing properties
    stamina_drain = 0,
    concentration_bonus = 2,
    damage_modifier = 0.8, -- Lower damage, higher utility
    speed_modifier = 0.9,
    jump_modifier = 1.1,
    
    -- Special abilities
    special_abilities = {
        "water_healing",
        "water_flow",
        "water_adaptation"
    },
    
    -- Requirements
    requirements = {
        level = 1,
        previous_types = {},
        items = {},
        quests = {}
    }
}

-- Water Breathing Forms
local forms = {
    -- Form 1: Water Surface Slash
    {
        id = "water_surface_slash",
        name = "Water Surface Slash",
        description = "A basic water breathing form that mimics the gentle flow of water",
        difficulty = 1,
        duration = 0,
        cooldown = 0,
        
        stamina_drain = 0,
        concentration_bonus = 1,
        damage_modifier = 0.9,
        speed_modifier = 1.0,
        
        instructions = {
            "Breathe in slowly like drawing water",
            "Exhale smoothly like water flowing",
            "Move with fluid, gentle motions",
            "Focus on the water's calmness"
        },
        
        effects = {
            particle_effect = "water_surface_particles",
            sound_effect = "water_flow_sound",
            screen_effect = "water_ripple_screen"
        },
        
        requirements = {
            level = 1,
            previous_forms = {}
        }
    },
    
    -- Form 2: Water Wheel
    {
        id = "water_wheel",
        name = "Water Wheel",
        description = "A circular breathing form that creates a protective water barrier",
        difficulty = 2,
        duration = 30,
        cooldown = 15,
        
        stamina_drain = 1,
        concentration_bonus = 2,
        damage_modifier = 0.8,
        speed_modifier = 0.95,
        
        instructions = {
            "Inhale while raising your arms in a circle",
            "Hold your breath as you complete the circle",
            "Exhale while lowering your arms",
            "Visualize water flowing around you"
        },
        
        effects = {
            particle_effect = "water_wheel_particles",
            sound_effect = "water_wheel_sound",
            screen_effect = "water_wheel_screen"
        },
        
        requirements = {
            level = 3,
            previous_forms = {"water_surface_slash"}
        }
    },
    
    -- Form 3: Flowing Dance
    {
        id = "water_flowing_dance",
        name = "Flowing Dance",
        description = "A graceful form that enhances movement and healing",
        difficulty = 3,
        duration = 60,
        cooldown = 30,
        
        stamina_drain = 2,
        concentration_bonus = 3,
        damage_modifier = 0.7,
        speed_modifier = 1.1,
        
        instructions = {
            "Breathe in rhythm with your steps",
            "Move like water flowing around obstacles",
            "Maintain steady, flowing movements",
            "Focus on healing and regeneration"
        },
        
        effects = {
            particle_effect = "water_flowing_particles",
            sound_effect = "water_dance_sound",
            screen_effect = "water_flowing_screen"
        },
        
        requirements = {
            level = 5,
            previous_forms = {"water_surface_slash", "water_wheel"}
        }
    },
    
    -- Form 4: Waterfall Basin
    {
        id = "water_waterfall_basin",
        name = "Waterfall Basin",
        description = "A powerful defensive form that creates a healing aura",
        difficulty = 4,
        duration = 90,
        cooldown = 45,
        
        stamina_drain = 3,
        concentration_bonus = 4,
        damage_modifier = 0.6,
        speed_modifier = 0.8,
        
        instructions = {
            "Inhale deeply like water filling a basin",
            "Hold your breath as you channel energy",
            "Exhale slowly, releasing healing energy",
            "Create a protective water barrier around you"
        },
        
        effects = {
            particle_effect = "waterfall_basin_particles",
            sound_effect = "waterfall_sound",
            screen_effect = "waterfall_basin_screen"
        },
        
        requirements = {
            level = 8,
            previous_forms = {"water_surface_slash", "water_wheel", "water_flowing_dance"}
        }
    },
    
    -- Form 5: Constant Flux
    {
        id = "water_constant_flux",
        name = "Constant Flux",
        description = "The ultimate water breathing form, adapting to any situation",
        difficulty = 5,
        duration = 120,
        cooldown = 60,
        
        stamina_drain = 4,
        concentration_bonus = 5,
        damage_modifier = 0.9,
        speed_modifier = 1.2,
        
        instructions = {
            "Breathe in perfect rhythm with your surroundings",
            "Adapt your breathing to the situation",
            "Flow like water around all obstacles",
            "Channel the power of the ocean itself"
        },
        
        effects = {
            particle_effect = "constant_flux_particles",
            sound_effect = "ocean_waves_sound",
            screen_effect = "constant_flux_screen"
        },
        
        requirements = {
            level = 12,
            previous_forms = {"water_surface_slash", "water_wheel", "water_flowing_dance", "water_waterfall_basin"}
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
    
    print("[BreathingSystem] Registered Water Breathing with " .. #forms .. " forms")
end

-- Return the breathing type data
return {
    typeID = typeID,
    typeData = typeData,
    forms = forms
}
