--[[
    BreathingSystem - Admin Test Commands
    =====================================
    
    Direct server commands for testing admin functionality
]]

-- Test form command for admins
concommand.Add("bs_admin_test_form", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[BreathingSystem] Admin only command!")
        return
    end
    
    local targetName = args[1]
    local formNum = tonumber(args[2]) or 1
    
    -- Find target player
    local target = nil
    if targetName then
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Name()), string.lower(targetName)) then
                target = p
                break
            end
        end
    else
        target = ply -- Test on self if no target specified
    end
    
    if not IsValid(target) then
        ply:ChatPrint("[Admin] Player not found: " .. (targetName or "none"))
        return
    end
    
    -- Get player data
    local playerData = BreathingSystem and BreathingSystem.PlayerRegistry and 
                      BreathingSystem.PlayerRegistry.GetPlayerData and
                      BreathingSystem.PlayerRegistry.GetPlayerData(target)
    
    if not playerData then
        ply:ChatPrint("[Admin] No player data for: " .. target:Name())
        return
    end
    
    local breathingType = playerData.breathing_type
    if not breathingType or breathingType == "none" then
        ply:ChatPrint("[Admin] " .. target:Name() .. " needs a breathing type first!")
        return
    end
    
    -- Force use the form
    ply:ChatPrint("[Admin] Making " .. target:Name() .. " use " .. breathingType .. " form " .. formNum)
    
    -- Trigger the form directly
    if BreathingSystem.CreateFormEffect then
        BreathingSystem.CreateFormEffect(target, breathingType, breathingType .. "_form_" .. formNum)
    end
    
    -- Apply gameplay effects
    if ApplyFormGameplayEffects then
        ApplyFormGameplayEffects(target, breathingType, formNum)
    end
    
    -- Notify the target
    target:ChatPrint("[" .. breathingType:upper() .. "] Form " .. formNum .. " activated by admin!")
end, nil, "Test a form on a player: bs_admin_test_form [player_name] [form_number]")

-- Direct balance set command
concommand.Add("bs_admin_balance", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[BreathingSystem] Admin only command!")
        return
    end
    
    local category = args[1]
    local key = args[2]
    local value = tonumber(args[3]) or args[3]
    
    if not category or not key or not value then
        ply:ChatPrint("[Admin] Usage: bs_admin_balance <category> <key> <value>")
        ply:ChatPrint("[Admin] Categories: damage, stamina, cooldowns, xp, effects, combat")
        return
    end
    
    -- Initialize balance if needed
    if not BreathingSystem then
        BreathingSystem = {}
    end
    
    if not BreathingSystem.Balance then
        ply:ChatPrint("[Admin] Balance system not loaded! Attempting to load...")
        include("admin/balance_tools.lua")
        
        if not BreathingSystem.Balance then
            ply:ChatPrint("[Admin] Failed to load balance system!")
            return
        end
    end
    
    -- Set the value
    local success = BreathingSystem.Balance.SetValue(category, key, value)
    if success then
        BreathingSystem.Balance.ApplyBalance()
        ply:ChatPrint("[Admin] Set " .. category .. "." .. key .. " = " .. tostring(value))
    else
        ply:ChatPrint("[Admin] Failed to set balance value!")
    end
end, nil, "Set balance value: bs_admin_balance <category> <key> <value>")

-- Module status command
concommand.Add("bs_admin_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[BreathingSystem] Admin only command!")
        return
    end
    
    ply:ChatPrint("=== BreathingSystem Module Status ===")
    ply:ChatPrint("Main System: " .. (BreathingSystem and "LOADED" or "NOT LOADED"))
    
    if BreathingSystem then
        ply:ChatPrint("- PlayerRegistry: " .. (BreathingSystem.PlayerRegistry and "YES" or "NO"))
        ply:ChatPrint("- Balance: " .. (BreathingSystem.Balance and "YES" or "NO"))
        ply:ChatPrint("- Logging: " .. (BreathingSystem.Logging and "YES" or "NO"))
        ply:ChatPrint("- Forms: " .. (BreathingSystem.Forms and "YES" or "NO"))
        ply:ChatPrint("- CreateFormEffect: " .. (BreathingSystem.CreateFormEffect and "YES (function)" or "NO"))
        
        -- Check player count
        if BreathingSystem.PlayerRegistry then
            local count = 0
            for _, data in pairs(BreathingSystem.PlayerRegistry.PlayerData or {}) do
                count = count + 1
            end
            ply:ChatPrint("- Registered Players: " .. count)
        end
        
        -- Check balance values
        if BreathingSystem.Balance and BreathingSystem.Balance.Values then
            local balanceCount = 0
            for cat, vals in pairs(BreathingSystem.Balance.Values) do
                for k, v in pairs(vals) do
                    balanceCount = balanceCount + 1
                end
            end
            ply:ChatPrint("- Balance Values: " .. balanceCount)
        end
    end
    
    ply:ChatPrint("=====================================")
end, nil, "Check breathing system status")

-- Force unlock all forms
concommand.Add("bs_admin_unlock_all", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[BreathingSystem] Admin only command!")
        return
    end
    
    local targetName = args[1]
    local target = nil
    
    if targetName then
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Name()), string.lower(targetName)) then
                target = p
                break
            end
        end
    else
        target = ply
    end
    
    if not IsValid(target) then
        ply:ChatPrint("[Admin] Player not found!")
        return
    end
    
    local playerData = BreathingSystem and BreathingSystem.PlayerRegistry and 
                      BreathingSystem.PlayerRegistry.GetPlayerData and
                      BreathingSystem.PlayerRegistry.GetPlayerData(target)
    
    if not playerData then
        ply:ChatPrint("[Admin] No player data!")
        return
    end
    
    playerData.forms_unlocked = playerData.forms_unlocked or {}
    
    -- Unlock all forms for all types
    local types = {"water", "fire", "thunder", "stone", "wind"}
    for _, bType in ipairs(types) do
        for i = 1, 5 do
            local formId = bType .. "_form_" .. i
            if not table.HasValue(playerData.forms_unlocked, formId) then
                table.insert(playerData.forms_unlocked, formId)
            end
        end
    end
    
    ply:ChatPrint("[Admin] Unlocked all forms for " .. target:Name())
    target:ChatPrint("[BreathingSystem] All forms have been unlocked by an admin!")
end, nil, "Unlock all forms: bs_admin_unlock_all [player_name]")

print("[BreathingSystem] Admin test commands loaded")
print("[BreathingSystem] Commands: bs_admin_test_form, bs_admin_balance, bs_admin_status, bs_admin_unlock_all") 