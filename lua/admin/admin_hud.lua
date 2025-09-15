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
                
                -- Gather breathing types (hardcoded since they're defined in separate files)
                data.breathingTypes = {
                    water = {
                        name = "Water Breathing",
                        description = "Fluid and adaptive breathing style",
                        category = "elemental",
                        color = Color(100, 150, 255)
                    },
                    fire = {
                        name = "Fire Breathing",
                        description = "Fierce and powerful breathing style",
                        category = "elemental",
                        color = Color(255, 100, 100)
                    },
                    thunder = {
                        name = "Thunder Breathing",
                        description = "Fast and electrifying breathing style",
                        category = "elemental",
                        color = Color(255, 255, 100)
                    },
                    stone = {
                        name = "Stone Breathing",
                        description = "Solid and defensive breathing style",
                        category = "elemental",
                        color = Color(150, 100, 50)
                    },
                    wind = {
                        name = "Wind Breathing",
                        description = "Swift and unpredictable breathing style",
                        category = "elemental",
                        color = Color(200, 200, 255)
                    }
                }
                
                -- Gather forms (simplified list)
                data.forms = {
                    water_form_1 = {name = "Water Surface Slash", breathing_type = "water", damage = 30, stamina_cost = 20, cooldown = 3},
                    water_form_2 = {name = "Water Wheel", breathing_type = "water", damage = 40, stamina_cost = 25, cooldown = 4},
                    water_form_3 = {name = "Flowing Dance", breathing_type = "water", damage = 35, stamina_cost = 30, cooldown = 5},
                    water_form_4 = {name = "Waterfall Basin", breathing_type = "water", damage = 50, stamina_cost = 35, cooldown = 6},
                    water_form_5 = {name = "Constant Flux", breathing_type = "water", damage = 60, stamina_cost = 40, cooldown = 8},
                    
                    fire_form_1 = {name = "Unknowing Fire", breathing_type = "fire", damage = 40, stamina_cost = 20, cooldown = 4},
                    fire_form_2 = {name = "Rising Scorching Sun", breathing_type = "fire", damage = 50, stamina_cost = 25, cooldown = 5},
                    fire_form_3 = {name = "Blazing Universe", breathing_type = "fire", damage = 60, stamina_cost = 35, cooldown = 8},
                    fire_form_4 = {name = "Flame Tiger", breathing_type = "fire", damage = 80, stamina_cost = 40, cooldown = 10},
                    fire_form_5 = {name = "Rengoku", breathing_type = "fire", damage = 100, stamina_cost = 50, cooldown = 15},
                    
                    thunder_form_1 = {name = "Thunderclap and Flash", breathing_type = "thunder", damage = 35, stamina_cost = 20, cooldown = 2},
                    thunder_form_2 = {name = "Rice Spirit", breathing_type = "thunder", damage = 45, stamina_cost = 25, cooldown = 3},
                    thunder_form_3 = {name = "Thunder Swarm", breathing_type = "thunder", damage = 55, stamina_cost = 30, cooldown = 4},
                    thunder_form_4 = {name = "Distant Thunder", breathing_type = "thunder", damage = 65, stamina_cost = 35, cooldown = 5},
                    thunder_form_5 = {name = "Heat Lightning", breathing_type = "thunder", damage = 75, stamina_cost = 40, cooldown = 6},
                    
                    stone_form_1 = {name = "Stone Skin", breathing_type = "stone", damage = 25, stamina_cost = 25, cooldown = 5},
                    stone_form_2 = {name = "Upper Smash", breathing_type = "stone", damage = 45, stamina_cost = 30, cooldown = 6},
                    stone_form_3 = {name = "Stone Pillar", breathing_type = "stone", damage = 55, stamina_cost = 35, cooldown = 7},
                    stone_form_4 = {name = "Volcanic Rock", breathing_type = "stone", damage = 70, stamina_cost = 40, cooldown = 8},
                    stone_form_5 = {name = "Arcs of Justice", breathing_type = "stone", damage = 85, stamina_cost = 45, cooldown = 10},
                    
                    wind_form_1 = {name = "Dust Whirlwind Cutter", breathing_type = "wind", damage = 30, stamina_cost = 18, cooldown = 3},
                    wind_form_2 = {name = "Claws-Purifying Wind", breathing_type = "wind", damage = 40, stamina_cost = 22, cooldown = 4},
                    wind_form_3 = {name = "Clean Storm Wind Tree", breathing_type = "wind", damage = 50, stamina_cost = 28, cooldown = 5},
                    wind_form_4 = {name = "Rising Dust Storm", breathing_type = "wind", damage = 60, stamina_cost = 32, cooldown = 6},
                    wind_form_5 = {name = "Cold Mountain Wind", breathing_type = "wind", damage = 70, stamina_cost = 38, cooldown = 7}
                }
                
                -- Send data to client
                print("[BreathingSystem] Sending admin HUD data to " .. ply:Name())
                net.Start("BreathingSystem_OpenAdminHUD")
                net.WriteTable(data)
                net.Send(ply)
                
                ply:ChatPrint("[BreathingSystem] Opening admin HUD...")
                print("[BreathingSystem] Admin HUD data sent to client")
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
                    -- Update network vars
                    target:SetNWInt("BreathingLevel", args.level)
                    ply:ChatPrint("[Admin] Set " .. target:Name() .. "'s level to " .. args.level)
                    
                    -- Log the action
                    if BreathingSystem.Logging then
                        BreathingSystem.Logging.LogPlayer("INFO", "Admin set level to " .. args.level, target, "Admin")
                    end
                end
            end
            
        elseif cmd == "set_player_xp" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.xp = args.xp
                    -- Update network vars
                    target:SetNWInt("BreathingExp", args.xp)
                    -- Calculate next level XP requirement
                    local nextLevel = (data.level or 1) + 1
                    local xpRequired = nextLevel * 100
                    target:SetNWInt("BreathingExpNext", xpRequired)
                    ply:ChatPrint("[Admin] Set " .. target:Name() .. "'s XP to " .. args.xp)
                    
                    -- Log the action
                    if BreathingSystem.Logging then
                        BreathingSystem.Logging.LogPlayer("INFO", "Admin set XP to " .. args.xp, target, "Admin")
                    end
                end
            end
            
        elseif cmd == "set_player_stamina" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.stamina = args.stamina
                    data.max_stamina = args.max_stamina
                    -- Update network vars
                    target:SetNWInt("BreathingStamina", args.stamina)
                    target:SetNWInt("BreathingMaxStamina", args.max_stamina)
                    ply:ChatPrint("[Admin] Updated " .. target:Name() .. "'s stamina")
                end
            end
            
        elseif cmd == "set_player_concentration" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.concentration = args.concentration
                    data.max_concentration = args.max_concentration
                    -- Update network vars if they exist
                    target:SetNWInt("BreathingConcentration", args.concentration)
                    target:SetNWInt("BreathingMaxConcentration", args.max_concentration)
                    ply:ChatPrint("[Admin] Updated " .. target:Name() .. "'s concentration")
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
                local success = BreathingSystem.Balance.SetValue(args.category, args.key, args.value)
                if success then
                    BreathingSystem.Balance.ApplyBalance()
                    ply:ChatPrint("[Admin] Set balance " .. args.category .. "." .. args.key .. " = " .. tostring(args.value))
                    
                    -- Log the change
                    if BreathingSystem.Logging then
                        BreathingSystem.Logging.LogPlayer("INFO", "Admin changed balance: " .. args.category .. "." .. args.key .. " = " .. tostring(args.value), ply, "Admin")
                    end
                else
                    ply:ChatPrint("[Admin] Failed to set balance value!")
                end
            else
                ply:ChatPrint("[Admin] Balance system not initialized!")
                print("[BreathingSystem] Balance module not found!")
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
            if IsValid(target) and target:IsPlayer() then
                -- Extract form number from form_id or use provided form_number
                local formNum = args.form_number or 1
                local breathingType = args.form_id and string.match(args.form_id, "^(%w+)_form") or nil
                
                -- Get player's current breathing type if not specified
                local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if not breathingType and playerData then
                    breathingType = playerData.breathing_type
                end
                
                if breathingType and breathingType ~= "none" then
                    -- Force the player to use the form
                    target:ConCommand("bs_form " .. formNum)
                    
                    -- Also trigger effects directly if available
                    if BreathingSystem.CreateFormEffect then
                        BreathingSystem.CreateFormEffect(target, breathingType, args.form_id)
                    end
                    
                    ply:ChatPrint("[Admin] Testing form " .. (args.form_id or formNum) .. " on " .. target:Name())
                else
                    ply:ChatPrint("[Admin] Player needs a breathing type first!")
                end
            end
            
        elseif cmd == "unlock_all_forms" then
            local target = Entity(args.player_index)
            if IsValid(target) and target:IsPlayer() then
                local data = BreathingSystem.PlayerRegistry.GetPlayerData(target)
                if data then
                    data.forms_unlocked = data.forms_unlocked or {}
                    
                    -- Unlock all forms for their current breathing type
                    local breathingType = data.breathing_type or "water"
                    for i = 1, 5 do
                        local formId = breathingType .. "_form_" .. i
                        if not table.HasValue(data.forms_unlocked, formId) then
                            table.insert(data.forms_unlocked, formId)
                        end
                    end
                    
                    ply:ChatPrint("[Admin] Unlocked all " .. breathingType .. " forms for " .. target:Name())
                end
            end
            
        elseif cmd == "refresh_data" then
            -- Send updated data back to admin
            timer.Simple(0.1, function()
                if IsValid(ply) then
                    ply:ConCommand("breathingadmin_refresh")
                end
            end)
            
        elseif cmd == "debug_modules" then
            -- Debug command to check loaded modules
            ply:ChatPrint("[Admin] Checking loaded modules...")
            ply:ChatPrint("- BreathingSystem: " .. (BreathingSystem and "YES" or "NO"))
            ply:ChatPrint("- PlayerRegistry: " .. (BreathingSystem.PlayerRegistry and "YES" or "NO"))
            ply:ChatPrint("- Balance: " .. (BreathingSystem.Balance and "YES" or "NO"))
            ply:ChatPrint("- Logging: " .. (BreathingSystem.Logging and "YES" or "NO"))
            ply:ChatPrint("- CreateFormEffect: " .. (BreathingSystem.CreateFormEffect and "YES" or "NO"))
            
            -- Also print to console
            print("[BreathingSystem] Module Status:")
            print("  - Main: " .. tostring(BreathingSystem ~= nil))
            print("  - PlayerRegistry: " .. tostring(BreathingSystem.PlayerRegistry ~= nil))
            print("  - Balance: " .. tostring(BreathingSystem.Balance ~= nil))
            print("  - Logging: " .. tostring(BreathingSystem.Logging ~= nil))
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

-- Don't include client file here, it will be loaded separately 