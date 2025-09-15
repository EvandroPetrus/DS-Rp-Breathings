--[[
    BreathingSystem - Water Breathing Type
    =====================================
    
    Water breathing focuses on fluidity, adaptability, and healing.
]]

-- Only run on server
if not SERVER then return end

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
        description = "A horizontal slash that creates a blade of water",
        breathing_type = typeID,
        form_number = 1,
        
        -- Form properties
        damage = 25,
        stamina_cost = 10,
        concentration_cost = 5,
        cooldown = 3,
        range = 150,
        
        -- Requirements
        requirements = {
            level = 1,
            forms = {}
        },
        
        -- Visual effects
        effects = {
            particle = "water_slash",
            sound = "water_swoosh",
            animation = "slash_horizontal"
        }
    },
    
    -- Form 2: Water Wheel
    {
        id = "water_water_wheel",
        name = "Water Wheel",
        description = "A spinning attack that creates a wheel of water",
        breathing_type = typeID,
        form_number = 2,
        
        damage = 35,
        stamina_cost = 15,
        concentration_cost = 8,
        cooldown = 5,
        range = 100,
        
        requirements = {
            level = 3,
            forms = {"water_surface_slash"}
        },
        
        effects = {
            particle = "water_wheel",
            sound = "water_spin",
            animation = "spin_attack"
        }
    },
    
    -- Form 3: Flowing Dance
    {
        id = "water_flowing_dance",
        name = "Flowing Dance",
        description = "A graceful series of movements that flow like water",
        breathing_type = typeID,
        form_number = 3,
        
        damage = 40,
        stamina_cost = 20,
        concentration_cost = 10,
        cooldown = 6,
        range = 120,
        
        requirements = {
            level = 5,
            forms = {"water_water_wheel"}
        },
        
        effects = {
            particle = "water_flow",
            sound = "water_dance",
            animation = "flowing_combo"
        }
    },
    
    -- Form 4: Waterfall Basin
    {
        id = "water_waterfall_basin",
        name = "Waterfall Basin",
        description = "Creates a protective basin of water that heals allies",
        breathing_type = typeID,
        form_number = 4,
        
        damage = 0,
        healing = 30,
        stamina_cost = 25,
        concentration_cost = 15,
        cooldown = 10,
        range = 200,
        
        requirements = {
            level = 7,
            forms = {"water_flowing_dance"}
        },
        
        effects = {
            particle = "water_basin",
            sound = "waterfall",
            animation = "defensive_stance"
        }
    },
    
    -- Form 5: Constant Flux
    {
        id = "water_constant_flux",
        name = "Constant Flux",
        description = "The ultimate water breathing technique - unpredictable and powerful",
        breathing_type = typeID,
        form_number = 10,
        
        damage = 80,
        stamina_cost = 40,
        concentration_cost = 25,
        cooldown = 15,
        range = 250,
        
        requirements = {
            level = 10,
            forms = {"water_waterfall_basin"}
        },
        
        effects = {
            particle = "water_flux",
            sound = "water_ultimate",
            animation = "ultimate_water"
        }
    }
}

-- Register the breathing type
if BreathingSystem and BreathingSystem.BreathingTypes then
    BreathingSystem.BreathingTypes.RegisterType(typeID, typeData)
    
    -- Register all forms
    for _, form in ipairs(forms) do
        BreathingSystem.BreathingTypes.RegisterForm(typeID, form)
    end
    
    print("[BreathingSystem] Registered Water Breathing with " .. #forms .. " forms")
end
