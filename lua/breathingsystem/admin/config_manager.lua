--[[
    BreathingSystem - Config Manager
    ===============================
    
    This module handles configuration loading/saving and management.
    Supports JSON/INI formats and provides real-time configuration updates.
    
    Responsibilities:
    - Load and save configuration files
    - Handle configuration validation
    - Provide real-time configuration updates
    - Manage configuration backups
    
    Public API:
    - BreathingSystem.ConfigManager.LoadConfig() - Load configuration
    - BreathingSystem.ConfigManager.SaveConfig() - Save configuration
    - BreathingSystem.ConfigManager.SetConfig(key, value) - Set config value
    - BreathingSystem.ConfigManager.GetConfig(key) - Get config value
]]

-- Initialize config manager
BreathingSystem.ConfigManager = BreathingSystem.ConfigManager or {}

-- Config manager configuration
BreathingSystem.ConfigManager.Config = {
    -- File paths
    config_file = "breathingsystem/config.json",
    backup_file = "breathingsystem/config_backup.json",
    
    -- File formats
    formats = {
        json = true,
        ini = true
    },
    
    -- Auto-save settings
    auto_save = true,
    auto_save_interval = 300, -- 5 minutes
    
    -- Backup settings
    backup_enabled = true,
    max_backups = 10
}

-- Configuration data
BreathingSystem.ConfigManager.Data = BreathingSystem.ConfigManager.Data or {}

-- Load configuration
function BreathingSystem.ConfigManager.LoadConfig()
    local configPath = BreathingSystem.ConfigManager.Config.config_file
    
    -- Try to load JSON first
    if file.Exists(configPath, "DATA") then
        local content = file.Read(configPath, "DATA")
        if content then
            local success, data = pcall(util.JSONToTable, content)
            if success and data then
                BreathingSystem.ConfigManager.Data = data
                print("[BreathingSystem.ConfigManager] Configuration loaded from " .. configPath)
                return true
            end
        end
    end
    
    -- Load default configuration
    BreathingSystem.ConfigManager.LoadDefaultConfig()
    print("[BreathingSystem.ConfigManager] Using default configuration")
    
    return false
end

-- Save configuration
function BreathingSystem.ConfigManager.SaveConfig()
    local configPath = BreathingSystem.ConfigManager.Config.config_file
    
    -- Create backup if enabled
    if BreathingSystem.ConfigManager.Config.backup_enabled then
        BreathingSystem.ConfigManager.CreateBackup()
    end
    
    -- Save configuration
    local content = util.TableToJSON(BreathingSystem.ConfigManager.Data, true)
    if content then
        file.Write(configPath, content)
        print("[BreathingSystem.ConfigManager] Configuration saved to " .. configPath)
        return true
    end
    
    print("[BreathingSystem.ConfigManager] Failed to save configuration")
    return false
end

-- Load default configuration
function BreathingSystem.ConfigManager.LoadDefaultConfig()
    BreathingSystem.ConfigManager.Data = {
        -- General settings
        enabled = true,
        debug_mode = true,
        
        -- Player settings
        default_breathing_type = "normal",
        max_stamina = 100,
        max_concentration = 100,
        
        -- Breathing system settings
        stamina_regen_rate = 1.0,
        concentration_decay_rate = 0.5,
        
        -- UI settings
        show_hud = true,
        hud_position = {x = 20, y = 20},
        
        -- Network settings
        update_interval = 0.1,
        
        -- Combat settings
        pvp_enabled = true,
        pvp_damage_multiplier = 0.8,
        
        -- Training settings
        xp_gain_rate = 1.0,
        training_duration = 300,
        
        -- Effects settings
        particles_enabled = true,
        sounds_enabled = true,
        animations_enabled = true
    }
end

-- Set configuration value
function BreathingSystem.ConfigManager.SetConfig(key, value)
    if not key then return false end
    
    BreathingSystem.ConfigManager.Data[key] = value
    
    print("[BreathingSystem.ConfigManager] Set " .. key .. " = " .. tostring(value))
    
    -- Auto-save if enabled
    if BreathingSystem.ConfigManager.Config.auto_save then
        BreathingSystem.ConfigManager.SaveConfig()
    end
    
    return true
end

-- Get configuration value
function BreathingSystem.ConfigManager.GetConfig(key)
    if not key then return nil end
    
    return BreathingSystem.ConfigManager.Data[key]
end

-- Get all configuration
function BreathingSystem.ConfigManager.GetAllConfig()
    return BreathingSystem.ConfigManager.Data
end

-- Create configuration backup
function BreathingSystem.ConfigManager.CreateBackup()
    if not BreathingSystem.ConfigManager.Config.backup_enabled then return false end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupPath = "breathingsystem/backups/config_" .. timestamp .. ".json"
    
    local content = util.TableToJSON(BreathingSystem.ConfigManager.Data, true)
    if content then
        file.Write(backupPath, content)
        print("[BreathingSystem.ConfigManager] Configuration backup created: " .. backupPath)
        
        -- Clean up old backups
        BreathingSystem.ConfigManager.CleanupBackups()
        
        return true
    end
    
    return false
end

-- Clean up old backups
function BreathingSystem.ConfigManager.CleanupBackups()
    local backupDir = "breathingsystem/backups/"
    local files = file.Find(backupDir .. "config_*.json", "DATA")
    
    if files and #files > BreathingSystem.ConfigManager.Config.max_backups then
        -- Sort by modification time (oldest first)
        table.sort(files, function(a, b)
            local timeA = file.Time(backupDir .. a, "DATA")
            local timeB = file.Time(backupDir .. b, "DATA")
            return timeA < timeB
        end)
        
        -- Remove oldest files
        local toRemove = #files - BreathingSystem.ConfigManager.Config.max_backups
        for i = 1, toRemove do
            file.Delete(backupDir .. files[i])
        end
        
        print("[BreathingSystem.ConfigManager] Cleaned up " .. toRemove .. " old backup files")
    end
end

-- Reset configuration to default
function BreathingSystem.ConfigManager.ResetConfig()
    BreathingSystem.ConfigManager.LoadDefaultConfig()
    BreathingSystem.ConfigManager.SaveConfig()
    
    print("[BreathingSystem.ConfigManager] Configuration reset to default")
    
    return true
end

-- Validate configuration
function BreathingSystem.ConfigManager.ValidateConfig()
    local data = BreathingSystem.ConfigManager.Data
    local errors = {}
    
    -- Validate required fields
    local requiredFields = {
        "enabled", "max_stamina", "max_concentration", "stamina_regen_rate"
    }
    
    for _, field in ipairs(requiredFields) do
        if data[field] == nil then
            table.insert(errors, "Missing required field: " .. field)
        end
    end
    
    -- Validate numeric fields
    local numericFields = {
        "max_stamina", "max_concentration", "stamina_regen_rate", "concentration_decay_rate"
    }
    
    for _, field in ipairs(numericFields) do
        if data[field] and type(data[field]) ~= "number" then
            table.insert(errors, "Field " .. field .. " must be a number")
        end
    end
    
    -- Validate boolean fields
    local booleanFields = {
        "enabled", "debug_mode", "show_hud", "pvp_enabled", "particles_enabled", "sounds_enabled", "animations_enabled"
    }
    
    for _, field in ipairs(booleanFields) do
        if data[field] and type(data[field]) ~= "boolean" then
            table.insert(errors, "Field " .. field .. " must be a boolean")
        end
    end
    
    if #errors > 0 then
        print("[BreathingSystem.ConfigManager] Configuration validation errors:")
        for _, error in ipairs(errors) do
            print("  - " .. error)
        end
        return false
    end
    
    print("[BreathingSystem.ConfigManager] Configuration validation passed")
    return true
end

-- Export configuration
function BreathingSystem.ConfigManager.ExportConfig(format)
    format = format or "json"
    
    if format == "json" then
        return util.TableToJSON(BreathingSystem.ConfigManager.Data, true)
    elseif format == "ini" then
        return BreathingSystem.ConfigManager.ExportToINI()
    end
    
    return nil
end

-- Export to INI format
function BreathingSystem.ConfigManager.ExportToINI()
    local ini = {}
    
    -- General section
    table.insert(ini, "[General]")
    table.insert(ini, "enabled = " .. tostring(BreathingSystem.ConfigManager.Data.enabled))
    table.insert(ini, "debug_mode = " .. tostring(BreathingSystem.ConfigManager.Data.debug_mode))
    table.insert(ini, "")
    
    -- Player section
    table.insert(ini, "[Player]")
    table.insert(ini, "default_breathing_type = " .. BreathingSystem.ConfigManager.Data.default_breathing_type)
    table.insert(ini, "max_stamina = " .. BreathingSystem.ConfigManager.Data.max_stamina)
    table.insert(ini, "max_concentration = " .. BreathingSystem.ConfigManager.Data.max_concentration)
    table.insert(ini, "")
    
    -- Combat section
    table.insert(ini, "[Combat]")
    table.insert(ini, "pvp_enabled = " .. tostring(BreathingSystem.ConfigManager.Data.pvp_enabled))
    table.insert(ini, "pvp_damage_multiplier = " .. BreathingSystem.ConfigManager.Data.pvp_damage_multiplier)
    table.insert(ini, "")
    
    return table.concat(ini, "\n")
end

-- Initialize config manager
if SERVER then
    -- Load configuration on startup
    BreathingSystem.ConfigManager.LoadConfig()
    
    -- Auto-save timer
    if BreathingSystem.ConfigManager.Config.auto_save then
        timer.Create("BreathingSystem_ConfigAutoSave", BreathingSystem.ConfigManager.Config.auto_save_interval, 0, function()
            BreathingSystem.ConfigManager.SaveConfig()
        end)
    end
    
    print("[BreathingSystem.ConfigManager] Config manager loaded")
end
