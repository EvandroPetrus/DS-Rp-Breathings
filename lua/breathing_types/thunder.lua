--[[
    BreathingSystem - Thunder Breathing Type
    ========================================
]]

-- Only run on server
if not SERVER then return end

-- Thunder Breathing Type Configuration
local typeID = "thunder"
local typeData = {
    name = "Thunder Breathing",
    description = "Lightning-fast breathing style focused on speed and precision",
    category = "elemental",
    color = Color(255, 255, 0), -- Yellow color
    icon = "breathingsystem/thunder.png",
    
    -- Thunder breathing properties
    stamina_drain = 3,
    concentration_bonus = 1,
    damage_modifier = 1.2,
    speed_modifier = 1.5, -- Very fast
    jump_modifier = 1.2,
    
    -- Special abilities
    special_abilities = {
        "thunder_speed",
        "thunder_stun",
        "thunder_dash"
    }
}

-- Thunder Breathing Forms
local forms = {
    {
        id = "thunder_clap_flash",
        name = "Thunderclap and Flash",
        description = "Dash forward at lightning speed",
        breathing_type = typeID,
        form_number = 1,
        
        damage = 35,
        stamina_cost = 20,
        concentration_cost = 10,
        cooldown = 3,
        range = 300,
        
        effects = {
            particle = "thunder_dash",
            sound = "thunder_crack",
            animation = "dash_forward"
        }
    },
    {
        id = "thunder_rice_spirit",
        name = "Rice Spirit",
        description = "Five-fold lightning slashes",
        breathing_type = typeID,
        form_number = 2,
        
        damage = 45,
        stamina_cost = 25,
        concentration_cost = 12,
        cooldown = 5,
        range = 150,
        
        effects = {
            particle = "thunder_multi",
            sound = "thunder_rapid",
            animation = "multi_slash"
        }
    },
    {
        id = "thunder_swarm",
        name = "Thunder Swarm",
        description = "Creates multiple lightning projectiles",
        breathing_type = typeID,
        form_number = 3,
        
        damage = 30,
        stamina_cost = 30,
        concentration_cost = 15,
        cooldown = 6,
        range = 250,
        
        effects = {
            particle = "thunder_swarm",
            sound = "thunder_buzz",
            animation = "projectile_attack"
        }
    },
    {
        id = "thunder_distant",
        name = "Distant Thunder",
        description = "Long-range lightning strike",
        breathing_type = typeID,
        form_number = 4,
        
        damage = 70,
        stamina_cost = 35,
        concentration_cost = 20,
        cooldown = 8,
        range = 500,
        
        effects = {
            particle = "thunder_strike",
            sound = "thunder_boom",
            animation = "ranged_attack"
        }
    },
    {
        id = "thunder_god_speed",
        name = "God Speed",
        description = "Ultimate speed enhancement with lightning aura",
        breathing_type = typeID,
        form_number = 7,
        
        damage = 100,
        stamina_cost = 50,
        concentration_cost = 25,
        cooldown = 15,
        range = 400,
        
        effects = {
            particle = "thunder_godspeed",
            sound = "thunder_ultimate",
            animation = "ultimate_thunder"
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
    
    print("[BreathingSystem] Registered Thunder Breathing with " .. #forms .. " forms")
end
