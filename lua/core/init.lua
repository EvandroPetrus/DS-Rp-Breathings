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
    include("core/config.lua")
    include("core/player_registry.lua")
    include("core/forms.lua")
    
    -- Load breathing types
    include("breathing_types/template.lua")
    include("breathing_types/water.lua")
    include("breathing_types/fire.lua")
    include("breathing_types/thunder.lua")
    include("breathing_types/stone.lua")
    include("breathing_types/wind.lua")
    
    -- Load mechanics modules
    include("mechanics/stamina.lua")
    include("mechanics/cooldowns.lua")
    include("mechanics/prerequisites.lua")
    include("mechanics/damage.lua")
    
    -- Load progression modules
    include("progression/training.lua")
    include("progression/levels.lua")
    include("progression/concentration.lua")
    
    -- Load effects modules
    include("effects/particles.lua")
    include("effects/sounds.lua")
    include("effects/animations.lua")
    
    -- Load combat modules
    include("combat/pvp_integration.lua")
    include("combat/status_effects.lua")
    
    -- Load admin modules
    include("admin/balance_tools.lua")
    include("admin/logging.lua")
    
    -- Load UI modules (client-side)
    AddCSLuaFile("ui/hud.lua")
    AddCSLuaFile("ui/menus.lua")
    
    print("[BreathingSystem] All modules loaded successfully!")
end

-- Client-side initialization
if CLIENT then
    include("ui/hud.lua")
    include("ui/menus.lua")
end

-- Global API functions with error handling
function BreathingSystem.GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    if not BreathingSystem.PlayerRegistry or not BreathingSystem.PlayerRegistry.GetPlayerData then
        return nil
    end
    return BreathingSystem.PlayerRegistry.GetPlayerData(ply)
end

function BreathingSystem.SetPlayerBreathing(ply, breathingType)
    if not IsValid(ply) then return false end
    if not BreathingSystem.PlayerRegistry or not BreathingSystem.PlayerRegistry.SetPlayerBreathing then
        return false
    end
    return BreathingSystem.PlayerRegistry.SetPlayerBreathing(ply, breathingType)
end

function BreathingSystem.RegisterBreathingType(name, config)
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.RegisterType then
        return false
    end
    return BreathingSystem.BreathingTypes.RegisterType(name, config)
end

function BreathingSystem.GetBreathingTypes()
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.GetAllTypes then
        return {}
    end
    return BreathingSystem.BreathingTypes.GetAllTypes()
end

function BreathingSystem.GetForms(breathingType)
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.GetForms then
        return {}
    end
    return BreathingSystem.BreathingTypes.GetForms(breathingType)
end

-- Test commands (server-side only)
if SERVER then
    concommand.Add("breathingsystem_test", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local playerData = BreathingSystem.GetPlayerData(ply)
        if not playerData then
            ply:ChatPrint("[BreathingSystem] No player data found!")
            return
        end
        
        ply:ChatPrint("=== BreathingSystem Test ===")
        ply:ChatPrint("Player: " .. ply:Name())
        ply:ChatPrint("Breathing Type: " .. (playerData.breathing_type or "None"))
        ply:ChatPrint("Level: " .. (playerData.level or 1))
        ply:ChatPrint("XP: " .. (playerData.xp or 0))
        ply:ChatPrint("Stamina: " .. (playerData.stamina or 100))
        ply:ChatPrint("Concentration: " .. (playerData.concentration or 0))
        
        if BreathingSystem.Particles and BreathingSystem.Particles.GetActiveEffects then
            ply:ChatPrint("Active particles: " .. table.Count(BreathingSystem.Particles.GetActiveEffects(ply)))
        else
            ply:ChatPrint("Active particles: 0")
        end
        
        ply:ChatPrint("========================")
    end)
    
    concommand.Add("breathingsystem_set", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if #args < 2 then
            ply:ChatPrint("Usage: breathingsystem_set <player_name> <breathing_type>")
            return
        end
        
        local targetName = args[1]
        local breathingType = args[2]
        
        local target = player.GetByName(targetName)
        if not IsValid(target) then
            ply:ChatPrint("Player not found: " .. targetName)
            return
        end
        
        local success = BreathingSystem.SetPlayerBreathing(target, breathingType)
        if success then
            ply:ChatPrint("Set " .. target:Name() .. " breathing type to: " .. breathingType)
            target:ChatPrint("Your breathing type has been set to: " .. breathingType)
        else
            ply:ChatPrint("Failed to set breathing type!")
        end
    end)
    
    concommand.Add("breathingsystem_list_types", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local types = BreathingSystem.GetBreathingTypes()
        ply:ChatPrint("=== Available Breathing Types ===")
        for name, data in pairs(types) do
            ply:ChatPrint("- " .. name .. ": " .. (data.description or "No description"))
        end
        ply:ChatPrint("================================")
    end)
    
    concommand.Add("breathingsystem_list_forms", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if #args < 1 then
            ply:ChatPrint("Usage: breathingsystem_list_forms <breathing_type>")
            return
        end
        
        local breathingType = args[1]
        local forms = BreathingSystem.GetForms(breathingType)
        
        if not forms then
            ply:ChatPrint("Breathing type not found: " .. breathingType)
            return
        end
        
        ply:ChatPrint("=== " .. breathingType .. " Forms ===")
        for id, form in pairs(forms) do
            ply:ChatPrint("- " .. id .. ": " .. (form.name or "Unnamed"))
        end
        ply:ChatPrint("================================")
    end)
    
    concommand.Add("breathingsystem_test_damage", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if #args < 1 then
            ply:ChatPrint("Usage: breathingsystem_test_damage <form_id>")
            return
        end
        
        local formID = args[1]
        local damage = "Cannot calculate"
        
        if BreathingSystem.Mechanics and BreathingSystem.Mechanics.CalculateDamage then
            damage = BreathingSystem.Mechanics.CalculateDamage(ply, formID) or "Cannot calculate"
        end
        
        ply:ChatPrint("Form: " .. formID)
        ply:ChatPrint("Damage: " .. tostring(damage))
    end)
    
    concommand.Add("breathingsystem_test_effects", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if #args < 1 then
            ply:ChatPrint("Usage: breathingsystem_test_effects <effect_type> [form_id]")
            return
        end
        
        local effectType = args[1]
        local formID = args[2]
        
        if effectType == "particles" then
            if BreathingSystem.Particles then
                if formID then
                    BreathingSystem.Particles.CreateFormEffect(ply, formID)
                else
                    BreathingSystem.Particles.CreateBreathingTypeEffect(ply, "water")
                end
                ply:ChatPrint("[BreathingSystem] Particle effect test started!")
            else
                ply:ChatPrint("[BreathingSystem] Particle system not available!")
            end
        elseif effectType == "sounds" then
            if BreathingSystem.Sounds then
                BreathingSystem.Sounds.PlaySound(ply, "breathing_type", "water")
                ply:ChatPrint("[BreathingSystem] Sound effect test started!")
            else
                ply:ChatPrint("[BreathingSystem] Sound system not available!")
            end
        elseif effectType == "animations" then
            if BreathingSystem.Animations then
                BreathingSystem.Animations.PlayAnimation(ply, "breathing_type", "water")
                ply:ChatPrint("[BreathingSystem] Animation test started!")
            else
                ply:ChatPrint("[BreathingSystem] Animation system not available!")
            end
        else
            ply:ChatPrint("Unknown effect type: " .. effectType)
        end
    end)
    
    concommand.Add("breathingsystem_menu", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if #args < 1 then
            ply:ChatPrint("Usage: breathingsystem_menu <menu_type>")
            return
        end
        
        local menuType = args[1]
        ply:ChatPrint("Opening " .. menuType .. " menu...")
        -- Menu opening would be handled client-side
    end)
    
    concommand.Add("breathingsystem_balance_report", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        ply:ChatPrint("=== Balance Report ===")
        ply:ChatPrint("This would show balance configuration")
        ply:ChatPrint("=====================")
    end)
    
    concommand.Add("breathingsystem_logs", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        ply:ChatPrint("=== Recent Logs ===")
        ply:ChatPrint("This would show recent system logs")
        ply:ChatPrint("==================")
    end)
    
    print("[BreathingSystem] Test commands registered!")
end

print("[BreathingSystem] Core system initialized!")
