--[[
    BreathingSystem - Client Commands
    =================================
    
    Convenient console commands for accessing breathing system features
]]

-- Only run on client
if not CLIENT then return end

-- Command to open admin panel (admin only)
concommand.Add("breathing_admin", function(ply, cmd, args)
    if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
        chat.AddText(Color(255, 100, 100), "[BreathingSystem] ", Color(255, 255, 255), "You must be an admin to use this command!")
        return
    end
    
    -- Send chat command to server
    RunConsoleCommand("say", "!breathingadmin")
end, nil, "Opens the Breathing System admin panel (admin only)")

-- Direct admin panel opener (bypasses chat)
concommand.Add("breathing_admin_direct", function(ply, cmd, args)
    if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
        chat.AddText(Color(255, 100, 100), "[BreathingSystem] ", Color(255, 255, 255), "You must be an admin to use this command!")
        return
    end
    
    -- Request data directly from server
    net.Start("BreathingSystem_RequestAdminData")
    net.SendToServer()
    
    -- Open with test data while waiting for server response
    timer.Simple(0.5, function()
        if not AdminHUD or not AdminHUD.isOpen then
            RunConsoleCommand("breathingadmin_test")
        end
    end)
end, nil, "Opens the admin panel directly (admin only)")

-- Command to open player menu
concommand.Add("breathing_menu", function(ply, cmd, args)
    RunConsoleCommand("bs_menu")
end, nil, "Opens the Breathing System player menu")

-- Command to show player stats
concommand.Add("breathing_stats", function(ply, cmd, args)
    local ply = LocalPlayer()
    
    print("=== Breathing System Stats ===")
    print("Type: " .. ply:GetNWString("BreathingType", "none"))
    print("Level: " .. ply:GetNWInt("BreathingLevel", 1))
    print("XP: " .. ply:GetNWInt("BreathingExp", 0) .. "/" .. ply:GetNWInt("BreathingExpNext", 100))
    print("Stamina: " .. ply:GetNWInt("BreathingStamina", 0) .. "/" .. ply:GetNWInt("BreathingMaxStamina", 100))
    print("==============================")
    
    chat.AddText(Color(100, 200, 255), "[Breathing System Stats]")
    chat.AddText(Color(180, 180, 180), "Type: ", Color(255, 255, 255), ply:GetNWString("BreathingType", "none"))
    chat.AddText(Color(180, 180, 180), "Level: ", Color(255, 255, 255), tostring(ply:GetNWInt("BreathingLevel", 1)))
    chat.AddText(Color(180, 180, 180), "XP: ", Color(255, 255, 255), 
        ply:GetNWInt("BreathingExp", 0) .. "/" .. ply:GetNWInt("BreathingExpNext", 100))
    chat.AddText(Color(180, 180, 180), "Stamina: ", Color(255, 255, 255), 
        ply:GetNWInt("BreathingStamina", 0) .. "/" .. ply:GetNWInt("BreathingMaxStamina", 100))
end, nil, "Shows your breathing system stats")

-- Command to select tool
concommand.Add("breathing_tool", function(ply, cmd, args)
    local toolType = args[1] or "player"
    
    if toolType == "admin" then
        if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
            chat.AddText(Color(255, 100, 100), "[BreathingSystem] ", Color(255, 255, 255), "You must be an admin to use the admin tool!")
            return
        end
        RunConsoleCommand("gmod_tool", "breathing_admin")
        chat.AddText(Color(100, 255, 100), "[BreathingSystem] ", Color(255, 255, 255), "Admin tool selected. Press Q to open spawn menu.")
    else
        RunConsoleCommand("gmod_tool", "breathing_player")
        chat.AddText(Color(100, 255, 100), "[BreathingSystem] ", Color(255, 255, 255), "Player tool selected. Press Q to open spawn menu.")
    end
end, function(cmd, args)
    local options = {}
    if string.find(args, "breathing_tool ") then
        table.insert(options, "breathing_tool player")
        if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
            table.insert(options, "breathing_tool admin")
        end
    end
    return options
end, "Selects a breathing system tool (player/admin)")

-- Help command
concommand.Add("breathing_help", function(ply, cmd, args)
    print("\n=== Breathing System Commands ===")
    print("Chat Commands:")
    print("  !breathingadmin - Open admin panel (admin only)")
    print("  !bs or /bs - Open player menu")
    print("")
    print("Console Commands:")
    print("  breathing_admin - Open admin panel (admin only)")
    print("  breathing_menu - Open player menu")
    print("  breathing_stats - Show your stats")
    print("  breathing_tool [player/admin] - Select tool for Q menu")
    print("  breathing_help - Show this help")
    print("")
    print("Game Commands:")
    print("  bs_menu - Open breathing menu")
    print("  bs_switch <type> - Switch breathing type")
    print("  bs_use_form <1-5> - Use a form")
    print("  bs_training <start/stop/toggle> - Control training")
    print("")
    print("Q Menu Tools:")
    print("  1. Press Q to open spawn menu")
    print("  2. Go to Tools tab")
    print("  3. Find 'Breathing System' category")
    print("  4. Select 'Admin Panel' or 'Breathing Controls'")
    print("==================================\n")
    
    chat.AddText(Color(100, 200, 255), "[BreathingSystem] ", Color(255, 255, 255), "Help printed to console. Press ~ to view.")
end, nil, "Shows all breathing system commands")

-- Quick access notification on spawn
hook.Add("InitPostEntity", "BreathingSystem_ClientReady", function()
    timer.Simple(2, function()
        chat.AddText(Color(100, 200, 255), "[BreathingSystem] ", Color(255, 255, 255), "Type ", Color(255, 255, 100), "breathing_help", Color(255, 255, 255), " in console for commands.")
        chat.AddText(Color(100, 200, 255), "[BreathingSystem] ", Color(255, 255, 255), "Or press ", Color(255, 255, 100), "Q", Color(255, 255, 255), " → Tools → Breathing System")
    end)
end)

print("[BreathingSystem] Client commands loaded. Type 'breathing_help' for more info.") 