--[[
    BreathingSystem - Balance Tools
    ==============================
    
    This module handles real-time tuning commands and balance management.
    Provides tools for admins to adjust game balance on the fly.
    
    Responsibilities:
    - Handle real-time balance adjustments
    - Provide balance testing commands
    - Manage balance presets
    - Monitor balance metrics
    
    Public API:
    - BreathingSystem.Balance.SetValue(category, key, value) - Set balance value
    - BreathingSystem.Balance.GetValue(category, key) - Get balance value
    - BreathingSystem.Balance.ResetCategory(category) - Reset category to default
    - BreathingSystem.Balance.GetBalanceReport() - Get balance report
]]

-- Initialize balance tools
BreathingSystem.Balance = BreathingSystem.Balance or {}

-- Balance configuration
BreathingSystem.Balance.Config = {
    -- Balance categories
    categories = {
        "damage",
        "stamina",
        "cooldowns",
        "xp",
        "effects",
        "combat"
    },
    
    -- Default balance values
    defaults = {
        damage = {
            base_damage = 10,
            pvp_multiplier = 0.8,
            level_multiplier = 1.0
        },
        stamina = {
            max_stamina = 100,
            regen_rate = 1.0,
            drain_rate = 1.0
        },
        cooldowns = {
            global_multiplier = 1.0,
            difficulty_multiplier = 1.0
        },
        xp = {
            gain_rate = 1.0,
            training_multiplier = 1.0,
            form_usage_multiplier = 1.0
        },
        effects = {
            particle_intensity = 1.0,
            sound_volume = 1.0,
            animation_speed = 1.0
        },
        combat = {
            pvp_enabled = true,
            status_effect_duration = 1.0,
            counter_multiplier = 1.0
        }
    }
}

-- Current balance values
BreathingSystem.Balance.Values = BreathingSystem.Balance.Values or {}

-- Initialize balance values
function BreathingSystem.Balance.Initialize()
    for category, values in pairs(BreathingSystem.Balance.Config.defaults) do
        if not BreathingSystem.Balance.Values[category] then
            BreathingSystem.Balance.Values[category] = {}
        end
        
        for key, value in pairs(values) do
            if BreathingSystem.Balance.Values[category][key] == nil then
                BreathingSystem.Balance.Values[category][key] = value
            end
        end
    end
end

-- Set balance value
function BreathingSystem.Balance.SetValue(category, key, value)
    if not category or not key then return false end
    
    if not BreathingSystem.Balance.Values[category] then
        BreathingSystem.Balance.Values[category] = {}
    end
    
    BreathingSystem.Balance.Values[category][key] = value
    
    print("[BreathingSystem.Balance] Set " .. category .. "." .. key .. " = " .. tostring(value))
    
    -- Trigger balance update event
    hook.Run("BreathingSystem_BalanceUpdated", category, key, value)
    
    return true
end

-- Get balance value
function BreathingSystem.Balance.GetValue(category, key)
    if not category or not key then return nil end
    
    if BreathingSystem.Balance.Values[category] and BreathingSystem.Balance.Values[category][key] ~= nil then
        return BreathingSystem.Balance.Values[category][key]
    end
    
    -- Return default value
    if BreathingSystem.Balance.Config.defaults[category] and BreathingSystem.Balance.Config.defaults[category][key] then
        return BreathingSystem.Balance.Config.defaults[category][key]
    end
    
    return nil
end

-- Reset category to default
function BreathingSystem.Balance.ResetCategory(category)
    if not category then return false end
    
    if BreathingSystem.Balance.Config.defaults[category] then
        BreathingSystem.Balance.Values[category] = {}
        
        for key, value in pairs(BreathingSystem.Balance.Config.defaults[category]) do
            BreathingSystem.Balance.Values[category][key] = value
        end
        
        print("[BreathingSystem.Balance] Reset category " .. category .. " to default")
        
        -- Trigger balance update event
        hook.Run("BreathingSystem_BalanceCategoryReset", category)
        
        return true
    end
    
    return false
end

-- Reset all balance values
function BreathingSystem.Balance.ResetAll()
    BreathingSystem.Balance.Values = {}
    BreathingSystem.Balance.Initialize()
    
    print("[BreathingSystem.Balance] Reset all balance values to default")
    
    -- Trigger balance update event
    hook.Run("BreathingSystem_BalanceReset")
    
    return true
end

-- Get balance report
function BreathingSystem.Balance.GetBalanceReport()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        categories = {}
    }
    
    for category, values in pairs(BreathingSystem.Balance.Values) do
        report.categories[category] = {}
        
        for key, value in pairs(values) do
            local defaultValue = BreathingSystem.Balance.Config.defaults[category] and BreathingSystem.Balance.Config.defaults[category][key]
            local isModified = defaultValue and value ~= defaultValue
            
            report.categories[category][key] = {
                value = value,
                default = defaultValue,
                modified = isModified
            }
        end
    end
    
    return report
end

-- Apply balance values to systems
function BreathingSystem.Balance.ApplyBalance()
    -- Apply damage balance
    if BreathingSystem.Damage and BreathingSystem.Damage.Config then
        BreathingSystem.Damage.Config.base_damage = BreathingSystem.Balance.GetValue("damage", "base_damage")
        BreathingSystem.Damage.Config.pvp_damage_multiplier = BreathingSystem.Balance.GetValue("damage", "pvp_multiplier")
    end
    
    -- Apply stamina balance
    if BreathingSystem.Stamina and BreathingSystem.Stamina.Config then
        BreathingSystem.Stamina.Config.max_stamina = BreathingSystem.Balance.GetValue("stamina", "max_stamina")
        BreathingSystem.Stamina.Config.stamina_regen_rate = BreathingSystem.Balance.GetValue("stamina", "regen_rate")
    end
    
    -- Apply cooldowns balance
    if BreathingSystem.Cooldowns and BreathingSystem.Cooldowns.Config then
        BreathingSystem.Cooldowns.Config.global_cooldown_modifier = BreathingSystem.Balance.GetValue("cooldowns", "global_multiplier")
    end
    
    -- Apply XP balance
    if BreathingSystem.Training and BreathingSystem.Training.Config then
        BreathingSystem.Training.Config.xp_gain_rates.training_session = BreathingSystem.Balance.GetValue("xp", "training_multiplier") * 50
        BreathingSystem.Training.Config.xp_gain_rates.form_usage = BreathingSystem.Balance.GetValue("xp", "form_usage_multiplier") * 10
    end
    
    -- Apply effects balance
    if BreathingSystem.Particles and BreathingSystem.Particles.Config then
        -- Apply particle intensity
        for _, effect in pairs(BreathingSystem.Particles.Config.breathing_type_effects) do
            effect.size = effect.size * BreathingSystem.Balance.GetValue("effects", "particle_intensity")
        end
    end
    
    -- Apply combat balance
    if BreathingSystem.Combat and BreathingSystem.Combat.Config then
        BreathingSystem.Combat.Config.pvp_enabled = BreathingSystem.Balance.GetValue("combat", "pvp_enabled")
        BreathingSystem.Combat.Config.pvp_damage_multiplier = BreathingSystem.Balance.GetValue("combat", "pvp_enabled") and 0.8 or 1.0
    end
end

-- Save balance preset
function BreathingSystem.Balance.SavePreset(name)
    if not name then return false end
    
    local preset = {
        name = name,
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        values = table.Copy(BreathingSystem.Balance.Values)
    }
    
    local presetFile = "breathingsystem/presets/" .. name .. ".json"
    local content = util.TableToJSON(preset, true)
    
    if content then
        file.Write(presetFile, content)
        print("[BreathingSystem.Balance] Saved preset: " .. name)
        return true
    end
    
    return false
end

-- Load balance preset
function BreathingSystem.Balance.LoadPreset(name)
    if not name then return false end
    
    local presetFile = "breathingsystem/presets/" .. name .. ".json"
    
    if file.Exists(presetFile, "DATA") then
        local content = file.Read(presetFile, "DATA")
        if content then
            local success, preset = pcall(util.JSONToTable, content)
            if success and preset and preset.values then
                BreathingSystem.Balance.Values = preset.values
                BreathingSystem.Balance.ApplyBalance()
                
                print("[BreathingSystem.Balance] Loaded preset: " .. name)
                return true
            end
        end
    end
    
    return false
end

-- Get available presets
function BreathingSystem.Balance.GetPresets()
    local presets = {}
    local presetDir = "breathingsystem/presets/"
    
    if file.Exists(presetDir, "DATA") then
        local files = file.Find(presetDir .. "*.json", "DATA")
        if files then
            for _, file in ipairs(files) do
                local name = string.gsub(file, "%.json$", "")
                table.insert(presets, name)
            end
        end
    end
    
    return presets
end

-- Initialize balance tools
if SERVER then
    -- Initialize balance values
    BreathingSystem.Balance.Initialize()
    
    -- Apply balance on startup
    timer.Simple(1, function()
        BreathingSystem.Balance.ApplyBalance()
    end)
    
    print("[BreathingSystem.Balance] Balance tools loaded")
end
