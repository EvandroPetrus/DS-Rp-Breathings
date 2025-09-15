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
    
    -- AddCSLuaFile for client modules (when we add them in future phases)
    -- AddCSLuaFile("breathingsystem/client/...")
    
    print("[BreathingSystem] Core modules, breathing types, and mechanics loaded successfully")
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
        print("  - Level: " .. BreathingSystem.Prerequisites.GetLevel(ply))
        
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
    
    print("[BreathingSystem] Commands registered: breathingsystem_test, breathingsystem_set, breathingsystem_list_types, breathingsystem_list_forms, breathingsystem_test_damage")
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
