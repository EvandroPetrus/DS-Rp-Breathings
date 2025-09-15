--[[
    BreathingSystem - Stone Breathing Type
    ======================================
]]

-- Only run on server
if not SERVER then return end

-- Stone Breathing Type Configuration
local typeID = "stone"
local typeData = {
    name = "Stone Breathing",
    description = "Defensive breathing style with incredible durability",
    category = "elemental",
    color = Color(128, 128, 128), -- Gray color
    icon = "breathingsystem/stone.png",
    
    -- Stone breathing properties
    stamina_drain = 1,
    concentration_bonus = 3,
    damage_modifier = 1.0,
    speed_modifier = 0.8, -- Slower but tankier
    jump_modifier = 0.9,
    defense_modifier = 2.0, -- Double defense
    
    -- Special abilities
    special_abilities = {
        "stone_armor",
        "stone_wall",
        "stone_endurance"
    }
}

-- Stone Breathing Forms
local forms = {
    {
        id = "stone_surface",
        name = "Stone Surface Slash",
        description = "A heavy slash that cracks the ground",
        breathing_type = typeID,
        form_number = 1,
        
        damage = 45,
        stamina_cost = 10,
        concentration_cost = 5,
        cooldown = 5,
        range = 100,
        
        effects = {
            particle = "stone_crack",
            sound = "stone_impact",
            animation = "heavy_slash"
        }
    },
    {
        id = "stone_upper",
        name = "Upper Smash",
        description = "Uppercut that sends rocks flying",
        breathing_type = typeID,
        form_number = 2,
        
        damage = 55,
        stamina_cost = 15,
        concentration_cost = 8,
        cooldown = 6,
        range = 120,
        
        effects = {
            particle = "stone_debris",
            sound = "stone_crush",
            animation = "uppercut"
        }
    },
    {
        id = "stone_skin",
        name = "Stone Skin",
        description = "Hardens skin to reduce damage",
        breathing_type = typeID,
        form_number = 3,
        
        damage = 0,
        defense_boost = 50,
        stamina_cost = 20,
        concentration_cost = 15,
        cooldown = 10,
        range = 0,
        
        effects = {
            particle = "stone_armor",
            sound = "stone_harden",
            animation = "defensive_stance"
        }
    },
    {
        id = "stone_volcanic",
        name = "Volcanic Rock",
        description = "Launches molten rocks at enemies",
        breathing_type = typeID,
        form_number = 4,
        
        damage = 70,
        stamina_cost = 30,
        concentration_cost = 20,
        cooldown = 8,
        range = 200,
        
        effects = {
            particle = "stone_lava",
            sound = "stone_eruption",
            animation = "throw_projectile"
        }
    },
    {
        id = "stone_fortress",
        name = "Stone Fortress",
        description = "Ultimate defense - become immovable",
        breathing_type = typeID,
        form_number = 5,
        
        damage = 90,
        defense_boost = 100,
        stamina_cost = 45,
        concentration_cost = 25,
        cooldown = 15,
        range = 150,
        
        effects = {
            particle = "stone_fortress",
            sound = "stone_ultimate",
            animation = "ultimate_stone"
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
    
    print("[BreathingSystem] Registered Stone Breathing with " .. #forms .. " forms")
end
