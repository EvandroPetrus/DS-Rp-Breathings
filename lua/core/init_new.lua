    
    print("[BreathingSystem] All modules loaded successfully!")
end
--[[
    BreathingSystem Core - Main Entry Point
]]

-- Global table initialization
BreathingSystem = BreathingSystem or {}

-- Version info
BreathingSystem.Version = "1.0.0"
BreathingSystem.Author = "Your Name"

print("[BreathingSystem] Initializing core system...")

-- Load core modules (server-side only)
if SERVER then
    -- Core modules first
    include("core/config.lua")
    include("core/breathing_types_manager.lua")
    include("core/player_registry.lua")
    include("core/forms.lua")
    
    -- Load breathing types (they will self-register)
    include("breathing_types/water.lua")
    
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
    
    -- Load testing modules AFTER everything else
    include("core/autotest.lua")
    include("core/quickmenu.lua")
    
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

-- Global API functions
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

-- Helper function to find player by partial name
function BreathingSystem.FindPlayer(name)
    name = string.lower(name)
    for _, ply in ipairs(player.GetAll()) do
        if string.find(string.lower(ply:Name()), name, 1, true) then
            return ply
        end
    end
    return nil
end

-- Test commands (server-side only)
if SERVER then
    concommand.Add("breathingsystem_test", function(ply, cmd, args)
        if not IsValid(ply) and not game.IsDedicated() then 
            ply = player.GetAll()[1]
            if not IsValid(ply) then
                print("[BreathingSystem] No players connected!")
                return
            end
        end
        
        local playerData = BreathingSystem.GetPlayerData(ply)
        if not playerData then
            if BreathingSystem.PlayerRegistry and BreathingSystem.PlayerRegistry.RegisterPlayer then
                BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
                playerData = BreathingSystem.GetPlayerData(ply)
            end
            
            if not playerData then
                if IsValid(ply) then
                    ply:ChatPrint("[BreathingSystem] No player data found! Initializing...")
                else
                    print("[BreathingSystem] No player data found! Initializing...")
                end
                return
            end
        end
        
        local output = {
            "=== BreathingSystem Test ===",
            "Player: " .. ply:Name(),
            "Breathing Type: " .. (playerData.breathing_type or "None"),
            "Level: " .. (playerData.level or 1),
            "XP: " .. (playerData.xp or 0),
            "Stamina: " .. (playerData.stamina or 100),
            "Concentration: " .. (playerData.concentration or 0)
        }
        
        if BreathingSystem.Particles and BreathingSystem.Particles.GetActiveEffects then
            table.insert(output, "Active particles: " .. table.Count(BreathingSystem.Particles.GetActiveEffects(ply)))
        else
            table.insert(output, "Active particles: 0")
        end
        
        table.insert(output, "========================")
        
        for _, line in ipairs(output) do
            if IsValid(ply) then
                ply:ChatPrint(line)
            else
                print(line)
            end
        end
    end)
    
    concommand.Add("breathingsystem_set", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        if #args < 2 then
            local msg = "Usage: breathingsystem_set <player_name> <breathing_type>"
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            return
        end
        
        local targetName = args[1]
        local breathingType = args[2]
        
        local target = BreathingSystem.FindPlayer(targetName)
        
        if not target then
            for _, p in ipairs(player.GetAll()) do
                if p:Name() == targetName then
                    target = p
                    break
                end
            end
        end
        
        if not target and not isConsole and (targetName == "me" or targetName == "self") then
            target = ply
        end
        
        if not IsValid(target) then
            local msg = "Player not found: " .. targetName .. ". Try using a partial name or 'me' for yourself."
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            return
        end
        
        if BreathingSystem.PlayerRegistry and BreathingSystem.PlayerRegistry.RegisterPlayer then
            BreathingSystem.PlayerRegistry.RegisterPlayer(target)
        end
        
        local success = BreathingSystem.SetPlayerBreathing(target, breathingType)
        if success then
            local msg = "Set " .. target:Name() .. " breathing type to: " .. breathingType
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            target:ChatPrint("Your breathing type has been set to: " .. breathingType)
        else
            local msg = "Failed to set breathing type! Valid types: water, fire, thunder, stone, wind"
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
        end
    end)
    
    concommand.Add("breathingsystem_list_types", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        local types = BreathingSystem.GetBreathingTypes()
        local output = {"=== Available Breathing Types ==="}
        
        for name, data in pairs(types) do
            table.insert(output, "- " .. name .. ": " .. (data.description or "No description"))
        end
        table.insert(output, "================================")
        
        for _, line in ipairs(output) do
            if isConsole then
                print(line)
            else
                ply:ChatPrint(line)
            end
        end
    end)
    
    concommand.Add("breathingsystem_list_forms", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        if #args < 1 then
            local msg = "Usage: breathingsystem_list_forms <breathing_type>"
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            return
        end
        
        local breathingType = args[1]
        local forms = BreathingSystem.GetForms(breathingType)
        
        if not forms or table.Count(forms) == 0 then
            local msg = "Breathing type not found or has no forms: " .. breathingType
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            return
        end
        
        local output = {"=== " .. breathingType .. " Forms ==="}
        for id, form in pairs(forms) do
            table.insert(output, "- " .. id .. ": " .. (form.name or "Unnamed"))
        end
        table.insert(output, "================================")
        
        for _, line in ipairs(output) do
            if isConsole then
                print(line)
            else
                ply:ChatPrint(line)
            end
        end
    end)
    
    concommand.Add("breathingsystem_test_damage", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        if #args < 1 then
            local msg = "Usage: breathingsystem_test_damage <form_id>"
            if isConsole then
                print(msg)
            else
                ply:ChatPrint(msg)
            end
            return
        end
        
        local formID = args[1]
        local damage = "Cannot calculate"
        
        if BreathingSystem.Mechanics and BreathingSystem.Mechanics.CalculateDamage then
            if not isConsole then
                damage = BreathingSystem.Mechanics.CalculateDamage(ply, formID) or "Cannot calculate"
            end
        end
        
        local output = {
            "Form: " .. formID,
            "Damage: " .. tostring(damage)
        }
        
        for _, line in ipairs(output) do
            if isConsole then
                print(line)
            else
                ply:ChatPrint(line)
            end
        end
    end)
    
    concommand.Add("breathingsystem_test_effects", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        if isConsole then
            print("Effects testing requires a player")
            return
        end
        
        if #args < 1 then
            ply:ChatPrint("Usage: breathingsystem_test_effects <effect_type> [form_id]")
            ply:ChatPrint("Effect types: particles, sounds, animations")
            return
        end
        
        local effectType = args[1]
        local formID = args[2]
        
