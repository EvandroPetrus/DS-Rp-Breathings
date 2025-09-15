--[[
    BreathingSystem - Forms Console Commands
    ========================================
    
    Server-side console commands for using forms
]]

-- Console command version of useform
concommand.Add("bs_form", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local formNum = tonumber(args[1]) or 1
    formNum = math.Clamp(formNum, 1, 5)
    
    -- Get player data
    local playerData = BreathingSystem and BreathingSystem.PlayerRegistry and 
                      BreathingSystem.PlayerRegistry.GetPlayerData and
                      BreathingSystem.PlayerRegistry.GetPlayerData(ply)
    
    if not playerData then
        ply:ChatPrint("[BreathingSystem] No player data found! Switch to a breathing type first.")
        return
    end
    
    local breathingType = playerData.breathing_type
    if not breathingType or breathingType == "none" then
        ply:ChatPrint("[BreathingSystem] You need to select a breathing type first! Use bs_switch")
        return
    end
    
    -- Check stamina
    local stamina = playerData.stamina or 100
    local staminaCost = 15 + (formNum * 5)
    
    if stamina < staminaCost then
        ply:ChatPrint("[BreathingSystem] Not enough stamina! Need " .. staminaCost .. " (Current: " .. stamina .. ")")
        ply:EmitSound("buttons/button10.wav", 75, 100)
        return
    end
    
    -- Use stamina
    playerData.stamina = math.max(0, stamina - staminaCost)
    ply:SetNWInt("BreathingStamina", playerData.stamina)
    
    -- Announce form usage
    ply:ChatPrint("[" .. breathingType:upper() .. "] Form " .. formNum .. " activated!")
    
    -- Create effects if the function exists
    if BreathingSystem and BreathingSystem.CreateFormEffect then
        BreathingSystem.CreateFormEffect(ply, breathingType, breathingType .. "_form_" .. formNum)
    else
        -- Fallback effects if main system isn't loaded
        ply:EmitSound("ambient/energy/weld1.wav", 85, 100)
        
        local effectData = EffectData()
        effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
        effectData:SetScale(2)
        util.Effect("ManhackSparks", effectData, true, true)
    end
    
    -- Apply gameplay effects
    if ApplyFormGameplayEffects then
        ApplyFormGameplayEffects(ply, breathingType, formNum)
    end
end, nil, "Use a breathing form (1-5)")

-- Test effects command
concommand.Add("bs_test_effect", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then
        ply:ChatPrint("[BreathingSystem] Admin only command!")
        return
    end
    
    local effectType = args[1] or "water"
    
    ply:ChatPrint("[BreathingSystem] Testing " .. effectType .. " effects...")
    
    -- Force create effect
    if BreathingSystem and BreathingSystem.CreateFormEffect then
        BreathingSystem.CreateFormEffect(ply, effectType, effectType .. "_test")
    end
end, nil, "Test breathing effects (admin only)")

-- Quick form bind commands
for i = 1, 5 do
    concommand.Add("bs_form" .. i, function(ply, cmd, args)
        if not IsValid(ply) then return end
        RunConsoleCommand("bs_form", tostring(i))
    end, nil, "Quick bind for form " .. i)
end

print("[BreathingSystem] Forms commands loaded")
print("[BreathingSystem] Commands: bs_form [1-5], bs_form1-5, bs_test_effect [type]") 