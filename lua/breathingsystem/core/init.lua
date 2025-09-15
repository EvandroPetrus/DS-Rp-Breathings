--[[
    BreathingSystem Core - Main Entry Point
    ======================================
    
    This is the main entry point for the BreathingSystem addon.
    Handles initialization, module loading, and provides the global API.
    
    Responsibilities:
    - Initialize the global BreathingSystem table
    - Load core modules (server-side)
    - AddCSLuaFile client modules
    - Set up basic permissions system
    - Provide test commands for debugging
    
    Example Usage:
    - BreathingSystem.GetPlayerData(ply) - Get player breathing data
    - BreathingSystem.SetPlayerBreathing(ply, "normal") - Set breathing type
    - BreathingSystem.RegisterBreathingType("meditation", {...}) - Register new type
]]

-- Global table initialization
BreathingSystem = BreathingSystem or {}

-- Version info
BreathingSystem.Version = "1.0.0"
BreathingSystem.Author = "Your Name"

print("[BreathingSystem] Initializing core system...")

-- Load core modules (server-side only)
if SERVER then
    include("breathingsystem/core/config.lua")
    include("breathingsystem/core/player_registry.lua")
    include("breathingsystem/core/forms.lua")
    
    -- Load breathing types
    include("breathingsystem/breathing_types/template.lua")
    include("breathingsystem/breathing_types/water.lua")
    include("breathingsystem/breathing_types/fire.lua")
    include("breathingsystem/breathing_types/thunder.lua")
    include("breathingsystem/breathing_types/stone.lua")
    include("breathingsystem/breathing_types/wind.lua")
    
    -- Load mechanics modules
    include("breathingsystem/mechanics/stamina.lua")
    include("breathingsystem/mechanics/cooldowns.lua")
    include("breathingsystem/mechanics/prerequisites.lua")
    include("breathingsystem/mechanics/damage.lua")
    
    -- Load progression modules
    include("breathingsystem/progression/unlocks.lua")
    include("breathingsystem/progression/training.lua")
    include("breathingsystem/progression/concentration.lua")
    
    -- Load effects modules
    include("breathingsystem/effects/particles.lua")
    include("breathingsystem/effects/animations.lua")
    include("breathingsystem/effects/sounds.lua")
    
    -- Load combat modules
    include("breathingsystem/combat/pvp_integration.lua")
    include("breathingsystem/combat/status_effects.lua")
    include("breathingsystem/combat/counters.lua")
    
    -- Load UI modules
    include("breathingsystem/ui/hud.lua")
    include("breathingsystem/ui/menus.lua")
    include("breathingsystem/ui/keybinds.lua")
    
    -- Load admin modules
    include("breathingsystem/admin/config_manager.lua")
    include("breathingsystem/admin/logging.lua")
    include("breathingsystem/admin/balance_tools.lua")
    
    -- AddCSLuaFile for client modules (when we add them in future phases)
    -- AddCSLuaFile("breathingsystem/client/...")
    
    print("[BreathingSystem] Core modules, breathing types, mechanics, progression, effects, combat, UI, and admin loaded successfully")
end

-- Basic permissions system
BreathingSystem.Permissions = {
    -- Check if player is admin
    IsAdmin = function(ply)
        if not IsValid(ply) then return false end
        return ply:IsAdmin() or ply:IsSuperAdmin()
    end,
    
    -- Check if player can use breathing system
    CanUseBreathing = function(ply)
        if not IsValid(ply) then return false end
        return true -- For now, all players can use it
    end,
    
    -- Check if player can manage breathing types
    CanManageBreathing = function(ply)
        if not IsValid(ply) then return false end
        return BreathingSystem.Permissions.IsAdmin(ply)
    end
}

-- Test command for debugging
if SERVER then
    concommand.Add("breathingsystem_test", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        print("[BreathingSystem] Test command executed by " .. ply:Name())
        
        -- Test player registry
        local playerData = BreathingSystem.GetPlayerData(ply)
        print("[BreathingSystem] Player data for " .. ply:Name() .. ":")
        PrintTable(playerData)
        
        -- Test config
        print("[BreathingSystem] Available breathing types:")
        for typeID, data in pairs(BreathingSystem.Config.BreathingTypes) do
            print("  - " .. typeID .. ": " .. (data.name or "Unnamed"))
        end
        
        -- Test forms
        print("[BreathingSystem] Available forms:")
        for formID, form in pairs(BreathingSystem.Forms.GetAll()) do
            print("  - " .. formID .. ": " .. (form.name or "Unnamed"))
        end
        
        -- Test mechanics
        print("[BreathingSystem] Mechanics status:")
        print("  - Stamina: " .. BreathingSystem.Stamina.GetStamina(ply) .. "/" .. BreathingSystem.Stamina.GetMaxStamina(ply))
        print("  - Concentration: " .. BreathingSystem.Stamina.GetConcentration(ply) .. "/" .. BreathingSystem.Stamina.GetMaxConcentration(ply))
        print("  - Level: " .. BreathingSystem.Training.GetLevel(ply))
        print("  - XP: " .. BreathingSystem.Training.GetXP(ply))
        
        -- Test progression
        print("[BreathingSystem] Progression status:")
        print("  - Unlocked forms: " .. table.Count(BreathingSystem.Unlocks.GetUnlockedForms(ply)))
        print("  - Training status: " .. (BreathingSystem.Training.GetTrainingStatus(ply).isTraining and "Training" or "Not training"))
        print("  - Total concentration: " .. (BreathingSystem.Concentration.IsInTotalConcentration(ply) and "Active" or "Inactive"))
        
        -- Test effects
        print("[BreathingSystem] Effects status:")
        print("  - Active particles: " .. table.Count(BreathingSystem.Particles.GetActiveEffects(ply)))
        print("  - Active animations: " .. table.Count(BreathingSystem.Animations.GetActiveAnimations(ply)))
        print("  - Active sounds: " .. table.Count(BreathingSystem.Sounds.GetActiveSounds(ply)))
        
        -- Test combat
        print("[BreathingSystem] Combat status:")
        print("  - In combat: " .. (BreathingSystem.Combat.IsInCombat(ply) and "Yes" or "No"))
        print("  - Active effects: " .. table.Count(BreathingSystem.StatusEffects.GetActiveEffects(ply)))
        
        -- Test UI
        print("[BreathingSystem] UI status:")
        print("  - HUD enabled: " .. (playerData.hud_enabled ~= false and "Yes" or "No"))
        print("  - Keybinds: " .. table.Count(BreathingSystem.Keybinds.GetAllKeybinds(ply)))
        
        -- Test admin
        print("[BreathingSystem] Admin status:")
        print("  - Config loaded: " .. (BreathingSystem.ConfigManager and "Yes" or "No"))
        print("  - Logging level: " .. (BreathingSystem.Logging and BreathingSystem.Logging.GetLevel() or "Unknown"))
        print("  - Balance categories: " .. (BreathingSystem.Balance and table.Count(BreathingSystem.Balance.Values) or "Unknown"))
        
        ply:ChatPrint("[BreathingSystem] Test completed! Check console for details.")
    end)
    
    -- Admin command to set player breathing type
    concommand.Add("breathingsystem_set", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.CanManageBreathing(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        if #args < 2 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_set <player_name> <breathing_type>")
            return
        end
        
        local targetName = args[1]
        local breathingType = args[2]
        
        local target = player.GetByName(targetName)
        if not IsValid(target) then
            ply:ChatPrint("[BreathingSystem] Player '" .. targetName .. "' not found!")
            return
        end
        
        if not BreathingSystem.Config.BreathingTypes[breathingType] then
            ply:ChatPrint("[BreathingSystem] Invalid breathing type: " .. breathingType)
            return
        end
        
        BreathingSystem.SetPlayerBreathing(target, breathingType)
        ply:ChatPrint("[BreathingSystem] Set " .. target:Name() .. "'s breathing type to: " .. breathingType)
        target:ChatPrint("[BreathingSystem] Your breathing type has been set to: " .. breathingType)
    end)
    
    -- Command to list all breathing types
    concommand.Add("breathingsystem_list_types", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        print("[BreathingSystem] Available breathing types:")
        for typeID, data in pairs(BreathingSystem.Config.BreathingTypes) do
            print("  - " .. typeID .. ": " .. (data.name or "Unnamed") .. " (" .. (data.description or "No description") .. ")")
        end
        
        ply:ChatPrint("[BreathingSystem] Breathing types listed in console!")
    end)
    
    -- Command to list forms for a specific breathing type
    concommand.Add("breathingsystem_list_forms", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_list_forms <breathing_type>")
            return
        end
        
        local breathingType = args[1]
        
        if not BreathingSystem.Config.BreathingTypes[breathingType] then
            ply:ChatPrint("[BreathingSystem] Invalid breathing type: " .. breathingType)
            return
        end
        
        print("[BreathingSystem] Forms for " .. breathingType .. " breathing:")
        for formID, form in pairs(BreathingSystem.Forms.GetAll()) do
            if string.find(formID, breathingType) then
                print("  - " .. formID .. ": " .. (form.name or "Unnamed") .. " (" .. (form.description or "No description") .. ")")
            end
        end
        
        ply:ChatPrint("[BreathingSystem] Forms for " .. breathingType .. " listed in console!")
    end)
    
    -- Command to test damage
    concommand.Add("breathingsystem_test_damage", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_test_damage <form_id>")
            return
        end
        
        local formID = args[1]
        local damageInfo = BreathingSystem.Damage.GetDamageInfo(ply, formID)
        
        if damageInfo then
            print("[BreathingSystem] Damage info for " .. formID .. ":")
            PrintTable(damageInfo)
            ply:ChatPrint("[BreathingSystem] Damage info for " .. formID .. " displayed in console!")
        else
            ply:ChatPrint("[BreathingSystem] Invalid form ID: " .. formID)
        end
    end)
    
    -- Command to start training
    concommand.Add("breathingsystem_train", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 2 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_train <student_name> <form_id>")
            return
        end
        
        local studentName = args[1]
        local formID = args[2]
        
        local student = player.GetByName(studentName)
        if not IsValid(student) then
            ply:ChatPrint("[BreathingSystem] Player '" .. studentName .. "' not found!")
            return
        end
        
        if BreathingSystem.Training.StartTraining(ply, student, formID) then
            ply:ChatPrint("[BreathingSystem] Training session started with " .. student:Name())
        else
            ply:ChatPrint("[BreathingSystem] Failed to start training session!")
        end
    end)
    
    -- Command to enter total concentration
    concommand.Add("breathingsystem_total_concentration", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if BreathingSystem.Concentration.EnterTotalConcentration(ply) then
            ply:ChatPrint("[BreathingSystem] Entered total concentration!")
        else
            ply:ChatPrint("[BreathingSystem] Cannot enter total concentration right now!")
        end
    end)
    
    -- Command to test effects
    concommand.Add("breathingsystem_test_effects", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_test_effects <effect_type> [form_id]")
            return
        end
        
        local effectType = args[1]
        local formID = args[2]
        
        -- Test particle effects
        if effectType == "particles" then
            if formID then
                BreathingSystem.Particles.CreateFormEffect(ply, formID)
            else
                BreathingSystem.Particles.CreateBreathingTypeEffect(ply, "water")
            end
            ply:ChatPrint("[BreathingSystem] Particle effect test started!")
        end
        
        -- Test animations
        if effectType == "animations" then
            if formID then
                BreathingSystem.Animations.PlayFormAnimation(ply, formID)
            else
                BreathingSystem.Animations.PlayBreathingTypeAnimation(ply, "water")
            end
            ply:ChatPrint("[BreathingSystem] Animation test started!")
        end
        
        -- Test sounds
        if effectType == "sounds" then
            if formID then
                BreathingSystem.Sounds.PlayFormSound(ply, formID)
            else
                BreathingSystem.Sounds.PlayBreathingTypeSound(ply, "water")
            end
            ply:ChatPrint("[BreathingSystem] Sound test started!")
        end
    end)
    
    -- Command to test combat
    concommand.Add("breathingsystem_test_combat", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 2 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_test_combat <target_name> <form_id>")
            return
        end
        
        local targetName = args[1]
        local formID = args[2]
        
        local target = player.GetByName(targetName)
        if not IsValid(target) then
            ply:ChatPrint("[BreathingSystem] Player '" .. targetName .. "' not found!")
            return
        end
        
        if BreathingSystem.Combat.ApplyDamage(ply, target, formID) then
            ply:ChatPrint("[BreathingSystem] Combat test successful!")
        else
            ply:ChatPrint("[BreathingSystem] Combat test failed!")
        end
    end)
    
    -- Command to test status effects
    concommand.Add("breathingsystem_test_status", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_test_status <effect_type>")
            return
        end
        
        local effectType = args[1]
        
        if BreathingSystem.StatusEffects.ApplyEffect(ply, effectType, 10.0) then
            ply:ChatPrint("[BreathingSystem] Applied " .. effectType .. " effect!")
        else
            ply:ChatPrint("[BreathingSystem] Failed to apply " .. effectType .. " effect!")
        end
    end)
    
    -- Command to show menus
    concommand.Add("breathingsystem_menu", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_menu <menu_type>")
            return
        end
        
        local menuType = args[1]
        
        if menuType == "breathing" then
            BreathingSystem.Menus.ShowBreathingMenu(ply)
        elseif menuType == "forms" then
            BreathingSystem.Menus.ShowFormsMenu(ply)
        elseif menuType == "training" then
            BreathingSystem.Menus.ShowTrainingMenu(ply)
        elseif menuType == "progression" then
            BreathingSystem.Menus.ShowProgressionMenu(ply)
        else
            ply:ChatPrint("[BreathingSystem] Invalid menu type: " .. menuType)
        end
    end)
    
    -- Admin command to set balance value
    concommand.Add("breathingsystem_balance", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.IsAdmin(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        if #args < 3 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_balance <category> <key> <value>")
            return
        end
        
        local category = args[1]
        local key = args[2]
        local value = args[3]
        
        -- Convert value to appropriate type
        if value == "true" then
            value = true
        elseif value == "false" then
            value = false
        elseif tonumber(value) then
            value = tonumber(value)
        end
        
        if BreathingSystem.Balance.SetValue(category, key, value) then
            ply:ChatPrint("[BreathingSystem] Set balance value: " .. category .. "." .. key .. " = " .. tostring(value))
        else
            ply:ChatPrint("[BreathingSystem] Failed to set balance value!")
        end
    end)
    
    -- Admin command to get balance report
    concommand.Add("breathingsystem_balance_report", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.IsAdmin(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        local report = BreathingSystem.Balance.GetBalanceReport()
        print("[BreathingSystem] Balance Report:")
        PrintTable(report)
        
        ply:ChatPrint("[BreathingSystem] Balance report displayed in console!")
    end)
    
    -- Admin command to reset balance
    concommand.Add("breathingsystem_balance_reset", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.IsAdmin(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_balance_reset <category|all>")
            return
        end
        
        local category = args[1]
        
        if category == "all" then
            BreathingSystem.Balance.ResetAll()
            ply:ChatPrint("[BreathingSystem] Reset all balance values to default!")
        else
            if BreathingSystem.Balance.ResetCategory(category) then
                ply:ChatPrint("[BreathingSystem] Reset category " .. category .. " to default!")
            else
                ply:ChatPrint("[BreathingSystem] Failed to reset category " .. category .. "!")
            end
        end
    end)
    
    -- Admin command to set logging level
    concommand.Add("breathingsystem_log_level", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.IsAdmin(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        if #args < 1 then
            ply:ChatPrint("[BreathingSystem] Usage: breathingsystem_log_level <level>")
            return
        end
        
        local level = args[1]
        
        if BreathingSystem.Logging.SetLevel(level) then
            ply:ChatPrint("[BreathingSystem] Logging level set to " .. level .. "!")
        else
            ply:ChatPrint("[BreathingSystem] Invalid logging level: " .. level .. "!")
        end
    end)
    
    -- Admin command to get logs
    concommand.Add("breathingsystem_logs", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        if not BreathingSystem.Permissions.IsAdmin(ply) then
            ply:ChatPrint("[BreathingSystem] You don't have permission to use this command!")
            return
        end
        
        local count = tonumber(args[1]) or 50
        local level = args[2]
        
        local logs = BreathingSystem.Logging.GetLogs(count, level)
        
        print("[BreathingSystem] Recent logs:")
        for _, log in ipairs(logs) do
            print("[" .. log.timestamp .. "] [" .. log.level .. "] [" .. log.category .. "] " .. log.message)
        end
        
        ply:ChatPrint("[BreathingSystem] Logs displayed in console!")
    end)
    
    print("[BreathingSystem] Commands registered: breathingsystem_test, breathingsystem_set, breathingsystem_list_types, breathingsystem_list_forms, breathingsystem_test_damage, breathingsystem_train, breathingsystem_total_concentration, breathingsystem_test_effects, breathingsystem_test_combat, breathingsystem_test_status, breathingsystem_menu, breathingsystem_balance, breathingsystem_balance_report, breathingsystem_balance_reset, breathingsystem_log_level, breathingsystem_logs")
end

-- Initialize default breathing types
if SERVER then
    -- This will be called after config.lua is loaded
    timer.Simple(0, function()
        BreathingSystem.Config.RegisterBreathingType("normal", {
            name = "Normal Breathing",
            description = "Standard breathing pattern",
            stamina_drain = 0,
            concentration_bonus = 0
        })
        
        BreathingSystem.Config.RegisterBreathingType("deep", {
            name = "Deep Breathing",
            description = "Slow, deep breathing for relaxation",
            stamina_drain = -1, -- Actually restores stamina
            concentration_bonus = 2
        })
        
        BreathingSystem.Config.RegisterBreathingType("combat", {
            name = "Combat Breathing",
            description = "Fast, controlled breathing for combat situations",
            stamina_drain = 2,
            concentration_bonus = 1
        })
        
        print("[BreathingSystem] Default breathing types registered")
    end)
end

print("[BreathingSystem] Core initialization complete!")
