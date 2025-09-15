--[[
    BreathingSystem - Fire Breathing Type
    =====================================
]]

-- Only run on server
if not SERVER then return end

-- Fire Breathing Type Configuration
local typeID = "fire"
local typeData = {
    name = "Fire Breathing",
    description = "A fierce breathing style that embodies the destructive power of flames",
    category = "elemental",
    color = Color(255, 100, 0), -- Orange color
    icon = "breathingsystem/fire.png",
    
    -- Fire breathing properties
    stamina_drain = 2,
    concentration_bonus = 0,
    damage_modifier = 1.5, -- High damage
    speed_modifier = 1.1,
    jump_modifier = 1.0,
    
    -- Special abilities
    special_abilities = {
        "fire_burn",
        "fire_explosion",
        "fire_immunity"
    }
}

-- Fire Breathing Forms
local forms = {
    {
        id = "fire_unknowing",
        name = "Unknowing Fire",
        description = "A basic fire slash that ignites the air",
        breathing_type = typeID,
        form_number = 1,
        
        damage = 40,
        stamina_cost = 15,
        concentration_cost = 5,
        cooldown = 4,
        range = 200,
        
        effects = {
            particle = "fire_slash",
            sound = "fire_whoosh",
            animation = "slash_diagonal"
        }
    },
    {
        id = "fire_rising_sun",
        name = "Rising Scorching Sun",
        description = "An upward slash that creates a rising flame",
        breathing_type = typeID,
        form_number = 2,
        
        damage = 50,
        stamina_cost = 20,
        concentration_cost = 10,
        cooldown = 5,
        range = 150,
        
        effects = {
            particle = "fire_rising",
            sound = "fire_roar",
            animation = "slash_upward"
        }
    },
    {
        id = "fire_blazing_universe",
        name = "Blazing Universe",
        description = "A spinning attack that creates a vortex of flames",
        breathing_type = typeID,
        form_number = 3,
        
        damage = 60,
        stamina_cost = 30,
        concentration_cost = 15,
        cooldown = 8,
        range = 250,
        
        effects = {
            particle = "fire_vortex",
            sound = "fire_explosion",
            animation = "spin_attack"
        }
    },
    {
        id = "fire_flame_tiger",
        name = "Flame Tiger",
        description = "Manifests a flaming tiger that charges forward",
        breathing_type = typeID,
        form_number = 4,
        
        damage = 80,
        stamina_cost = 40,
        concentration_cost = 20,
        cooldown = 10,
        range = 300,
        
        effects = {
            particle = "fire_tiger",
            sound = "fire_roar_loud",
            animation = "charge_forward"
        }
    },
    {
        id = "fire_rengoku",
        name = "Rengoku",
        description = "The ultimate fire technique - creates a massive inferno",
        breathing_type = typeID,
        form_number = 9,
        
        damage = 120,
        stamina_cost = 60,
        concentration_cost = 30,
        cooldown = 20,
        range = 400,
        
        effects = {
            particle = "fire_ultimate",
            sound = "fire_inferno",
            animation = "ultimate_fire"
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
    
    print("[BreathingSystem] Registered Fire Breathing with " .. #forms .. " forms")
end
