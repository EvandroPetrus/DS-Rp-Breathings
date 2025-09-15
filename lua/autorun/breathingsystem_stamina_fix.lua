-- BreathingSystem Stamina Update Fix
-- This ensures stamina updates are synced to client for HUD

if SERVER then
    -- Update timer for stamina regeneration and syncing
    timer.Create("BreathingSystem_StaminaSync", 0.5, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end
            
            -- Get current stamina from network var
            local currentStamina = ply:GetNWInt("BreathingStamina", 100)
            local maxStamina = ply:GetNWInt("BreathingMaxStamina", 100)
            
            -- Regenerate stamina
            if currentStamina < maxStamina then
                currentStamina = math.min(maxStamina, currentStamina + 2) -- Regen 2 per 0.5 seconds
                ply:SetNWInt("BreathingStamina", currentStamina)
            end
            
            -- Also update from player data if it exists
            if BreathingSystem and BreathingSystem.GetPlayerData then
                local data = BreathingSystem.GetPlayerData(ply)
                if data then
                    -- Sync any changes from the system
                    if data.stamina ~= currentStamina then
                        ply:SetNWInt("BreathingStamina", data.stamina or 100)
                    end
                    if data.max_stamina and data.max_stamina ~= maxStamina then
                        ply:SetNWInt("BreathingMaxStamina", data.max_stamina)
                    end
                end
            end
        end
    end)
    
    -- Command to test stamina changes
    concommand.Add("bs_stamina", function(ply, cmd, args)
        if not IsValid(ply) then
            print("This command must be run by a player")
            return
        end
        
        local amount = tonumber(args[1]) or 50
        
        -- Set stamina
        ply:SetNWInt("BreathingStamina", amount)
        
        -- Also update player data if exists
        if BreathingSystem and BreathingSystem.GetPlayerData then
            local data = BreathingSystem.GetPlayerData(ply)
            if data then
                data.stamina = amount
            end
        end
        
        ply:ChatPrint("[BreathingSystem] Stamina set to: " .. amount)
    end)
    
    -- Command to drain stamina (for testing)
    concommand.Add("bs_drain", function(ply, cmd, args)
        if not IsValid(ply) then
            print("This command must be run by a player")
            return
        end
        
        local currentStamina = ply:GetNWInt("BreathingStamina", 100)
        local drainAmount = tonumber(args[1]) or 20
        
        local newStamina = math.max(0, currentStamina - drainAmount)
        ply:SetNWInt("BreathingStamina", newStamina)
        
        -- Update player data too
        if BreathingSystem and BreathingSystem.GetPlayerData then
            local data = BreathingSystem.GetPlayerData(ply)
            if data then
                data.stamina = newStamina
            end
        end
        
        ply:ChatPrint("[BreathingSystem] Drained " .. drainAmount .. " stamina. Current: " .. newStamina)
    end)
    
    -- Command to use a breathing form (drains stamina)
    concommand.Add("bs_use", function(ply, cmd, args)
        if not IsValid(ply) then
            print("This command must be run by a player")
            return
        end
        
        local currentStamina = ply:GetNWInt("BreathingStamina", 100)
        local cost = 25
        
        if currentStamina >= cost then
            ply:SetNWInt("BreathingStamina", currentStamina - cost)
            ply:ChatPrint("[BreathingSystem] Used breathing form! (-" .. cost .. " stamina)")
            
            -- Visual feedback
            ply:EmitSound("buttons/button14.wav", 75, 100)
        else
            ply:ChatPrint("[BreathingSystem] Not enough stamina! Need " .. cost .. ", have " .. currentStamina)
            ply:EmitSound("buttons/button10.wav", 75, 100)
        end
    end)
    
    -- Hook for player damage to drain stamina
    hook.Add("EntityTakeDamage", "BreathingSystem_StaminaDrain", function(target, dmginfo)
        if IsValid(target) and target:IsPlayer() then
            local currentStamina = target:GetNWInt("BreathingStamina", 100)
            local drainAmount = math.min(10, dmginfo:GetDamage() * 0.5)
            
            target:SetNWInt("BreathingStamina", math.max(0, currentStamina - drainAmount))
        end
    end)
    
    print("[BreathingSystem] Stamina sync system loaded")
    print("  Commands:")
    print("    bs_stamina <amount> - Set stamina to specific amount")
    print("    bs_drain <amount> - Drain stamina")
    print("    bs_use - Use a breathing form (costs 25 stamina)")
end

-- Add some client-side animations for the HUD
if CLIENT then
    -- Store previous stamina for animation
    local lastStamina = 100
    local staminaChangeTime = 0
    local staminaFlashColor = Color(255, 255, 255, 0)
    
    -- Hook to detect stamina changes
    hook.Add("Think", "BreathingSystem_StaminaAnimation", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local currentStamina = ply:GetNWInt("BreathingStamina", 100)
        
        -- Detect stamina change
        if currentStamina ~= lastStamina then
            staminaChangeTime = CurTime()
            
            -- Flash color based on change
            if currentStamina < lastStamina then
                -- Stamina decreased - red flash
                staminaFlashColor = Color(255, 0, 0, 100)
            else
                -- Stamina increased - green flash
                staminaFlashColor = Color(0, 255, 0, 100)
            end
            
            lastStamina = currentStamina
        end
        
        -- Fade out flash
        if CurTime() - staminaChangeTime < 0.5 then
            local alpha = math.max(0, 100 * (1 - (CurTime() - staminaChangeTime) * 2))
            staminaFlashColor.a = alpha
        else
            staminaFlashColor.a = 0
        end
    end)
    
    -- Add keybind for quick stamina use
    hook.Add("PlayerButtonDown", "BreathingSystem_StaminaKeys", function(ply, button)
        if button == KEY_G then
            RunConsoleCommand("bs_use")
        end
    end)
    
    print("[BreathingSystem] Client stamina animations loaded")
    print("  Press G to use breathing form (drains stamina)")
end
