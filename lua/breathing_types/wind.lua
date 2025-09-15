--[[
    BreathingSystem - Wind Breathing Type
    =====================================
]]

-- Only run on server
if not SERVER then return end

-- Wind Breathing Type Configuration
local typeID = "wind"
local typeData = {
    name = "Wind Breathing",
    description = "Swift and unpredictable breathing style using wind currents",
    category = "elemental",
    color = Color(200, 200, 255), -- Light blue color
    icon = "breathingsystem/wind.png",
    
    -- Wind breathing properties
    stamina_drain = 1,
    concentration_bonus = 2,
    damage_modifier = 1.1,
    speed_modifier = 1.3,
    jump_modifier = 1.5, -- High mobility
    
    -- Special abilities
    special_abilities = {
        "wind_mobility",
        "wind_push",
        "wind_flight"
    }
}

-- Wind Breathing Forms
local forms = {
    {
        id = "wind_dust_cutter",
        name = "Dust Whirlwind Cutter",
        description = "Creates cutting whirlwinds",
        breathing_type = typeID,
        form_number = 1,
        
        damage = 30,
        stamina_cost = 12,
        concentration_cost = 6,
        cooldown = 3,
        range = 180,
        
        effects = {
            particle = "wind_whirlwind",
            sound = "wind_howl",
            animation = "spin_slash"
        }
    },
    {
        id = "wind_claws",
        name = "Claws-Purifying Wind",
        description = "Claw-like wind slashes",
        breathing_type = typeID,
        form_number = 2,
        
        damage = 40,
        stamina_cost = 18,
        concentration_cost = 9,
        cooldown = 4,
        range = 150,
        
        effects = {
            particle = "wind_claws",
            sound = "wind_slash",
            animation = "claw_attack"
        }
    },
    {
        id = "wind_storm_tree",
        name = "Clean Storm Wind Tree",
        description = "Defensive wind barrier",
        breathing_type = typeID,
        form_number = 3,
        
        damage = 25,
        defense_boost = 30,
        stamina_cost = 22,
        concentration_cost = 12,
        cooldown = 6,
        range = 100,
        
        effects = {
            particle = "wind_barrier",
            sound = "wind_gust",
            animation = "defensive_spin"
        }
    },
    {
        id = "wind_rising_dust",
        name = "Rising Dust Storm",
        description = "Launches enemies upward with wind",
        breathing_type = typeID,
        form_number = 4,
        
        damage = 50,
        stamina_cost = 28,
        concentration_cost = 15,
        cooldown = 7,
        range = 200,
        
        effects = {
            particle = "wind_tornado",
            sound = "wind_storm",
            animation = "upward_slash"
        }
    },
    {
        id = "wind_typhoon",
        name = "Idaten Typhoon",
        description = "Ultimate wind technique - massive typhoon",
        breathing_type = typeID,
        form_number = 9,
        
        damage = 85,
        stamina_cost = 40,
        concentration_cost = 22,
        cooldown = 12,
        range = 350,
        
        effects = {
            particle = "wind_typhoon",
            sound = "wind_ultimate",
            animation = "ultimate_wind"
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
    
    print("[BreathingSystem] Registered Wind Breathing with " .. #forms .. " forms")
end
