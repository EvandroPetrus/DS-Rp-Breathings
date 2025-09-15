--[[
    BreathingSystem - Admin HUD
    ===========================
    
    Comprehensive admin control panel for managing all breathing system features.
    Activated via chat command: !breathingadmin or /breathingadmin
    
    Features:
    - Player management (stats, breathing types, forms)
    - Balance control (damage, stamina, cooldowns, XP)
    - System monitoring (logs, performance)
    - Testing tools (spawn effects, test forms)
    - Quick actions (reset, save, load)
]]

-- Only run on server and client appropriately
if SERVER then
    -- Admin check function
    local function IsAdmin(ply)
        return IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin())
    end
    
    -- Network strings for admin HUD
    util.AddNetworkString("BreathingSystem_OpenAdminHUD")
    util.AddNetworkString("BreathingSystem_AdminCommand")
    util.AddNetworkString("BreathingSystem_AdminDataSync")
    util.AddNetworkString("BreathingSystem_RequestAdminData")
    
    -- Chat command handler
    hook.Add("PlayerSay", "BreathingSystem_AdminCommand", function(ply, text, team)
        local lowerText = string.lower(text)
        
        if (lowerText == "!breathingadmin" or lowerText == "/breathingadmin") then
            if IsAdmin(ply) then
                -- Send all necessary data to the admin
                local data = {
                    players = {},
                    breathingTypes = {},
                    forms = {},
                    balance = BreathingSystem.Balance and BreathingSystem.Balance.GetBalanceReport() or {},
                    logs = BreathingSystem.Logging and BreathingSystem.Logging.GetLogs(50) or {},
                    presets = BreathingSystem.Balance and BreathingSystem.Balance.GetPresets() or {}
                }
                
                -- Gather player data
                for _, player in ipairs(player.GetAll()) do
                    local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(player)
                    if playerData then
                        data.players[player:EntIndex()] = {
                            name = player:Name(),
                            steamid = player:SteamID(),
                            breathing_type = playerData.breathing_type,
                            level = playerData.level,
                            xp = playerData.xp,
                            stamina = playerData.stamina,
                            max_stamina = playerData.max_stamina,
                            concentration = playerData.concentration,
                            max_concentration = playerData.max_concentration,
                            forms_unlocked = playerData.forms_unlocked or {},
                            total_concentration_active = playerData.total_concentration_active
                        }
                    end
                end
                
                -- Gather breathing types
                if BreathingSystem.Config and BreathingSystem.Config.breathing_types then
                    for id, typeData in pairs(BreathingSystem.Config.breathing_types) do
                        data.breathingTypes[id] = {
                            name = typeData.name,
                            description = typeData.description,
                            category = typeData.category,
                            color = typeData.color
                        }
                    end
                end
                
                -- Gather forms
                if BreathingSystem.Forms and BreathingSystem.Forms.registered_forms then
                    for id, formData in pairs(BreathingSystem.Forms.registered_forms) do
                        data.forms[id] = {
                            name = formData.name,
                            description = formData.description,
                            breathing_type = formData.breathing_type,
                            damage = formData.damage,
                            stamina_cost = formData.stamina_cost,
                            cooldown = formData.cooldown
                        }
                    end
                end
                
                -- Send data to client
                net.Start("BreathingSystem_OpenAdminHUD")
                net.WriteTable(data)
                net.Send(ply)
                
                ply:ChatPrint("[BreathingSystem] Opening admin HUD...")
            else
                ply:ChatPrint("[BreathingSystem] You must be an admin to use this command!")
            end
            
            return true -- Suppress the command from chat
        end
    end)
    
    -- Handle admin commands from client
    net.Receive("BreathingSystem_AdminCommand", function(len, ply)
        if not IsAdmin(ply) then return end
        
        local cmd = net.ReadString()
        local args = net.ReadTable()
        
        -- Log admin action
        if BreathingSystem.Logging then
            BreathingSystem.Logging.LogPlayer("INFO", "Admin command: " .. cmd, ply, "Admin")
        end
        
        -- Process commands
        if cmd == "set_player_breathing" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                BreathingSystem.PlayerRegistry.SetPlayerBreathing(target, args.breathing_type)
                ply:ChatPrint("[Admin] Set " .. target:Name() .. "'s breathing to " .. args.breathing_type)
            end
            
        elseif cmd == "set_player_level" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.level = args.level
                    ply:ChatPrint("[Admin] Set " .. target:Name() .. "'s level to " .. args.level)
                end
            end
            
        elseif cmd == "set_player_xp" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.xp = args.xp
                    ply:ChatPrint("[Admin] Set " .. target:Name() .. "'s XP to " .. args.xp)
                end
            end
            
        elseif cmd == "set_player_stamina" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.stamina = args.stamina
                    data.max_stamina = args.max_stamina
                    ply:ChatPrint("[Admin] Updated " .. target:Name() .. "'s stamina")
                end
            end
            
        elseif cmd == "unlock_form" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.forms_unlocked = data.forms_unlocked or {}
                    table.insert(data.forms_unlocked, args.form_id)
                    ply:ChatPrint("[Admin] Unlocked form " .. args.form_id .. " for " .. target:Name())
                end
            end
            
        elseif cmd == "reset_player" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                BreathingSystem.PlayerRegistry.UnregisterPlayer(target)
                BreathingSystem.PlayerRegistry.RegisterPlayer(target)
                ply:ChatPrint("[Admin] Reset " .. target:Name() .. "'s data")
            end
            
        elseif cmd == "set_balance" then
            if BreathingSystem.Balance then
                BreathingSystem.Balance.SetValue(args.category, args.key, args.value)
                BreathingSystem.Balance.ApplyBalance()
                ply:ChatPrint("[Admin] Set balance " .. args.category .. "." .. args.key .. " = " .. tostring(args.value))
            end
            
        elseif cmd == "reset_balance" then
            if BreathingSystem.Balance then
                if args.category then
                    BreathingSystem.Balance.ResetCategory(args.category)
                else
                    BreathingSystem.Balance.ResetAll()
                end
                BreathingSystem.Balance.ApplyBalance()
                ply:ChatPrint("[Admin] Reset balance")
            end
            
        elseif cmd == "save_preset" then
            if BreathingSystem.Balance then
                BreathingSystem.Balance.SavePreset(args.name)
                ply:ChatPrint("[Admin] Saved preset: " .. args.name)
            end
            
        elseif cmd == "load_preset" then
            if BreathingSystem.Balance then
                BreathingSystem.Balance.LoadPreset(args.name)
                ply:ChatPrint("[Admin] Loaded preset: " .. args.name)
            end
            
        elseif cmd == "set_log_level" then
            if BreathingSystem.Logging then
                BreathingSystem.Logging.SetLevel(args.level)
                ply:ChatPrint("[Admin] Set log level to " .. args.level)
            end
            
        elseif cmd == "clear_logs" then
            if BreathingSystem.Logging then
                BreathingSystem.Logging.ClearLogs()
                ply:ChatPrint("[Admin] Cleared logs")
            end
            
        elseif cmd == "test_form" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() and BreathingSystem.Forms then
                BreathingSystem.Forms.UseForm(target, args.form_id)
                ply:ChatPrint("[Admin] Testing form " .. args.form_id .. " on " .. target:Name())
            end
            
        elseif cmd == "refresh_data" then
            -- Send updated data back to admin
            timer.Simple(0.1, function()
                if IsValid(ply) then
                    ply:ConCommand("breathingadmin_refresh")
                end
            end)
        end
    end)
    
    -- Request data handler
    net.Receive("BreathingSystem_RequestAdminData", function(len, ply)
        if not IsAdmin(ply) then return end
        
        -- Gather and send updated data
        local data = {
            players = {},
            balance = BreathingSystem.Balance and BreathingSystem.Balance.GetBalanceReport() or {},
            logs = BreathingSystem.Logging and BreathingSystem.Logging.GetLogs(50) or {}
        }
        
        for _, player in ipairs(player.GetAll()) do
            local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(player)
            if playerData then
                data.players[player:EntIndex()] = {
                    name = player:Name(),
                    steamid = player:SteamID(),
                    breathing_type = playerData.breathing_type,
                    level = playerData.level,
                    xp = playerData.xp,
                    stamina = playerData.stamina,
                    max_stamina = playerData.max_stamina,
                    concentration = playerData.concentration,
                    max_concentration = playerData.max_concentration
                }
            end
        end
        
        net.Start("BreathingSystem_AdminDataSync")
        net.WriteTable(data)
        net.Send(ply)
    end)
    
    print("[BreathingSystem] Admin HUD server-side loaded")
end

-- Client-side HUD
if CLIENT then
    -- Include client HUD file
    include("admin/admin_hud_client.lua")
end 