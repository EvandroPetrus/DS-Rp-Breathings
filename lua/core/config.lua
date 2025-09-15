--[[
    BreathingSystem Core - Configuration Module
    ==========================================
    
    This module handles all configuration settings and breathing type registration.
    
    Responsibilities:
    - Store global configuration settings
    - Register and manage breathing types
    - Provide configuration API functions
    - Handle breathing type validation
    
    Public API:
    - BreathingSystem.Config.BreathingTypes - Table of registered breathing types
    - BreathingSystem.Config.RegisterBreathingType(id, data) - Register new breathing type
    - BreathingSystem.Config.GetBreathingType(id) - Get breathing type data
    - BreathingSystem.Config.ValidateBreathingType(data) - Validate breathing type data
    
    Example Usage:
    - BreathingSystem.Config.RegisterBreathingType("meditation", {name = "Meditation", ...})
    - local typeData = BreathingSystem.Config.GetBreathingType("normal")
]]

-- Initialize config module
BreathingSystem.Config = BreathingSystem.Config or {}

-- Default configuration settings
BreathingSystem.Config.Settings = {
    -- General settings
    enabled = true,
    debug_mode = true,
    
    -- Player settings
    default_breathing_type = "normal",
    max_stamina = 100,
    max_concentration = 100,
    
    -- Breathing system settings
    stamina_regen_rate = 1, -- per second
    concentration_decay_rate = 0.5, -- per second
    
    -- UI settings
    show_hud = true,
    hud_position = {x = 10, y = 10},
    
    -- Network settings
    update_interval = 0.1, -- seconds
}

-- Breathing types registry
BreathingSystem.Config.BreathingTypes = BreathingSystem.Config.BreathingTypes or {}

-- Register a new breathing type
function BreathingSystem.Config.RegisterBreathingType(id, data)
    if not id or type(id) ~= "string" then
        print("[BreathingSystem.Config] Error: Invalid breathing type ID")
        return false
    end
    
    if not data or type(data) ~= "table" then
        print("[BreathingSystem.Config] Error: Invalid breathing type data")
        return false
    end
    
    -- Validate the breathing type data
    if not BreathingSystem.Config.ValidateBreathingType(data) then
        print("[BreathingSystem.Config] Error: Invalid breathing type data for '" .. id .. "'")
        return false
    end
    
    -- Set default values
    data.id = id
    data.name = data.name or "Unnamed Breathing Type"
    data.description = data.description or "No description available"
    data.stamina_drain = data.stamina_drain or 0
    data.concentration_bonus = data.concentration_bonus or 0
    data.duration = data.duration or 0 -- 0 = indefinite
    data.cooldown = data.cooldown or 0
    
    -- Register the breathing type
    BreathingSystem.Config.BreathingTypes[id] = data
    
    print("[BreathingSystem.Config] Registered breathing type: " .. id .. " (" .. data.name .. ")")
    return true
end

-- Get breathing type data
function BreathingSystem.Config.GetBreathingType(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    
    return BreathingSystem.Config.BreathingTypes[id]
end

-- Validate breathing type data
function BreathingSystem.Config.ValidateBreathingType(data)
    if not data or type(data) ~= "table" then
        return false
    end
    
    -- Check required fields (name is optional, will be set to default)
    -- All other fields are optional and will get default values
    
    -- Validate numeric fields
    if data.stamina_drain and type(data.stamina_drain) ~= "number" then
        return false
    end
    
    if data.concentration_bonus and type(data.concentration_bonus) ~= "number" then
        return false
    end
    
    if data.duration and (type(data.duration) ~= "number" or data.duration < 0) then
        return false
    end
    
    if data.cooldown and (type(data.cooldown) ~= "number" or data.cooldown < 0) then
        return false
    end
    
    return true
end

-- Get all breathing types
function BreathingSystem.Config.GetAllBreathingTypes()
    return BreathingSystem.Config.BreathingTypes
end

-- Check if breathing type exists
function BreathingSystem.Config.BreathingTypeExists(id)
    return BreathingSystem.Config.BreathingTypes[id] ~= nil
end

-- Get configuration setting
function BreathingSystem.Config.GetSetting(key)
    return BreathingSystem.Config.Settings[key]
end

-- Set configuration setting
function BreathingSystem.Config.SetSetting(key, value)
    if BreathingSystem.Config.Settings[key] ~= nil then
        BreathingSystem.Config.Settings[key] = value
        print("[BreathingSystem.Config] Setting '" .. key .. "' changed to: " .. tostring(value))
        return true
    else
        print("[BreathingSystem.Config] Warning: Unknown setting '" .. key .. "'")
        return false
    end
end

print("[BreathingSystem.Config] Configuration module loaded")
