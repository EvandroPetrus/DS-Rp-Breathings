--[[
    BreathingSystem - Admin Tool
    ============================
    
    Tool for the Q menu to access the admin HUD
]]

TOOL.Category = "Breathing System"
TOOL.Name = "#tool.breathing_admin.name"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Tool information
if CLIENT then
    language.Add("tool.breathing_admin.name", "Admin Panel")
    language.Add("tool.breathing_admin.desc", "Open the Breathing System Admin Panel")
    language.Add("tool.breathing_admin.0", "Left click to open the admin panel")
    
    -- Custom tool icon
    TOOL.Information = {
        {name = "left", text = "Open Admin Panel"},
        {name = "right", text = "Quick Player Info"},
        {name = "reload", text = "Refresh Data"}
    }
end

-- Initialize
function TOOL:Init()
    if CLIENT then
        self.AdminHUDOpen = false
    end
end

-- Left click - Open admin panel
function TOOL:LeftClick(trace)
    if CLIENT then
        -- Check if player is admin
        if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
            chat.AddText(Color(255, 100, 100), "[BreathingSystem] ", Color(255, 255, 255), "You must be an admin to use this tool!")
            surface.PlaySound("buttons/button10.wav")
            return false
        end
        
        -- Send command to server to open admin HUD
        timer.Simple(0.1, function()
            RunConsoleCommand("say", "!breathingadmin")
        end)
        return true
    end
    
    if SERVER then
        -- Server-side check
        if IsValid(self:GetOwner()) and (self:GetOwner():IsAdmin() or self:GetOwner():IsSuperAdmin()) then
            return true
        end
    end
    
    return false
end

-- Right click - Quick player info
function TOOL:RightClick(trace)
    if CLIENT then
        if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
            return false
        end
        
        -- If we hit a player, show their info
        if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
            local ply = trace.Entity
            
            chat.AddText(Color(100, 200, 255), "[Player Info] ", Color(255, 255, 255), ply:Name())
            chat.AddText(Color(180, 180, 180), "SteamID: ", Color(255, 255, 255), ply:SteamID())
            chat.AddText(Color(180, 180, 180), "Breathing: ", Color(255, 255, 255), ply:GetNWString("BreathingType", "none"))
            chat.AddText(Color(180, 180, 180), "Level: ", Color(255, 255, 255), tostring(ply:GetNWInt("BreathingLevel", 1)))
            chat.AddText(Color(180, 180, 180), "Stamina: ", Color(255, 255, 255), 
                ply:GetNWInt("BreathingStamina", 0) .. "/" .. ply:GetNWInt("BreathingMaxStamina", 100))
            
            surface.PlaySound("buttons/button15.wav")
            return true
        else
            -- Show general server info
            local playerCount = #player.GetAll()
            chat.AddText(Color(100, 200, 255), "[Server Info]")
            chat.AddText(Color(180, 180, 180), "Players: ", Color(255, 255, 255), tostring(playerCount))
            chat.AddText(Color(180, 180, 180), "Addon Version: ", Color(255, 255, 255), "1.0.0")
            
            return true
        end
    end
    
    return false
end

-- Reload - Refresh data
function TOOL:Reload(trace)
    if CLIENT then
        if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
            return false
        end
        
        -- Request data refresh
        net.Start("BreathingSystem_RequestAdminData")
        net.SendToServer()
        
        chat.AddText(Color(100, 255, 100), "[BreathingSystem] ", Color(255, 255, 255), "Refreshing admin data...")
        surface.PlaySound("buttons/button3.wav")
        
        return true
    end
    
    return false
end

-- Tool panel
function TOOL.BuildCPanel(panel)
    panel:ClearControls()
    
    -- Header
    panel:AddControl("Header", {
        Text = "Breathing System Admin",
        Description = "Administrative controls for the Breathing System addon"
    })
    
    -- Check if admin
    if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
        local label = vgui.Create("DLabel")
        label:SetText("⚠️ Admin access required!")
        label:SetTextColor(Color(255, 100, 100))
        label:SetFont("DermaDefaultBold")
        label:SizeToContents()
        panel:AddItem(label)
        return
    end
    
    -- Open Admin Panel button
    local openBtn = vgui.Create("DButton")
    openBtn:SetText("Open Admin Panel")
    openBtn:SetTall(40)
    openBtn.DoClick = function()
        -- Close the spawn menu first
        if IsValid(g_SpawnMenu) then
            g_SpawnMenu:Close()
        end
        
        -- Then open the admin panel
        timer.Simple(0.1, function()
            RunConsoleCommand("say", "!breathingadmin")
        end)
    end
    openBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(70, 150, 200) or Color(100, 200, 255)
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.SimpleText(self:GetText(), "DermaDefaultBold", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    panel:AddItem(openBtn)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Quick Actions
    panel:AddControl("Label", {Text = "Quick Actions:"})
    
    -- Player selector
    local playerSelect = vgui.Create("DComboBox")
    playerSelect:SetValue("Select Player...")
    for _, ply in ipairs(player.GetAll()) do
        playerSelect:AddChoice(ply:Name(), ply:EntIndex())
    end
    panel:AddItem(playerSelect)
    
    -- Breathing type selector
    local breathingSelect = vgui.Create("DComboBox")
    breathingSelect:SetValue("Set Breathing Type...")
    local types = {"none", "water", "fire", "thunder", "stone", "wind"}
    for _, t in ipairs(types) do
        breathingSelect:AddChoice(t)
    end
    breathingSelect.OnSelect = function(self, index, value)
        local _, entIndex = playerSelect:GetSelected()
        if entIndex then
            net.Start("BreathingSystem_AdminCommand")
            net.WriteString("set_player_breathing")
            net.WriteTable({
                player_index = entIndex,
                breathing_type = value
            })
            net.SendToServer()
        end
    end
    panel:AddItem(breathingSelect)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Balance presets
    panel:AddControl("Label", {Text = "Balance Presets:"})
    
    local presetSelect = vgui.Create("DComboBox")
    presetSelect:SetValue("Load Preset...")
    presetSelect:AddChoice("Default")
    presetSelect:AddChoice("Competitive")
    presetSelect:AddChoice("Casual")
    presetSelect:AddChoice("Training")
    presetSelect.OnSelect = function(self, index, value)
        net.Start("BreathingSystem_AdminCommand")
        net.WriteString("load_preset")
        net.WriteTable({name = value})
        net.SendToServer()
    end
    panel:AddItem(presetSelect)
    
    -- Save preset
    local savePanel = vgui.Create("DPanel")
    savePanel:SetTall(30)
    savePanel.Paint = function() end
    
    local saveInput = vgui.Create("DTextEntry", savePanel)
    saveInput:SetPlaceholderText("Preset name...")
    saveInput:SetWide(120)
    saveInput:Dock(LEFT)
    
    local saveBtn = vgui.Create("DButton", savePanel)
    saveBtn:SetText("Save")
    saveBtn:SetWide(60)
    saveBtn:Dock(RIGHT)
    saveBtn.DoClick = function()
        local name = saveInput:GetValue()
        if name and name ~= "" then
            net.Start("BreathingSystem_AdminCommand")
            net.WriteString("save_preset")
            net.WriteTable({name = name})
            net.SendToServer()
            saveInput:SetValue("")
        end
    end
    panel:AddItem(savePanel)
    
    panel:AddControl("Label", {Text = ""})
    
    -- System controls
    panel:AddControl("Label", {Text = "System Controls:"})
    
    -- Log level
    local logLevel = vgui.Create("DComboBox")
    logLevel:SetValue("Set Log Level...")
    local levels = {"ERROR", "WARNING", "INFO", "DEBUG", "VERBOSE"}
    for _, level in ipairs(levels) do
        logLevel:AddChoice(level)
    end
    logLevel.OnSelect = function(self, index, value)
        net.Start("BreathingSystem_AdminCommand")
        net.WriteString("set_log_level")
        net.WriteTable({level = value})
        net.SendToServer()
    end
    panel:AddItem(logLevel)
    
    -- Clear logs button
    local clearLogsBtn = vgui.Create("DButton")
    clearLogsBtn:SetText("Clear System Logs")
    clearLogsBtn:SetTall(25)
    clearLogsBtn.DoClick = function()
        net.Start("BreathingSystem_AdminCommand")
        net.WriteString("clear_logs")
        net.WriteTable({})
        net.SendToServer()
    end
    panel:AddItem(clearLogsBtn)
    
    -- Reset balance button
    local resetBtn = vgui.Create("DButton")
    resetBtn:SetText("Reset All Balance")
    resetBtn:SetTall(25)
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all balance values to default?",
            "Confirm Reset",
            "Yes", function()
                net.Start("BreathingSystem_AdminCommand")
                net.WriteString("reset_balance")
                net.WriteTable({})
                net.SendToServer()
            end,
            "No", function() end
        )
    end
    panel:AddItem(resetBtn)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Info
    local infoLabel = vgui.Create("DLabel")
    infoLabel:SetText("ℹ️ Use left click to open the full admin panel")
    infoLabel:SetTextColor(Color(180, 180, 180))
    infoLabel:SetWrap(true)
    infoLabel:SetAutoStretchVertical(true)
    panel:AddItem(infoLabel)
end

-- Draw tool screen
if CLIENT then
    function TOOL:DrawToolScreen(width, height)
        surface.SetDrawColor(20, 20, 25, 250)
        surface.DrawRect(0, 0, width, height)
        
        -- Header
        surface.SetDrawColor(100, 200, 255, 255)
        surface.DrawRect(0, 0, width, 40)
        
        draw.SimpleText("BREATHING SYSTEM", "DermaLarge", width/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Admin Panel", "DermaDefaultBold", width/2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local y = 80
        
        -- Instructions
        draw.SimpleText("Controls:", "DermaDefaultBold", 20, y, Color(100, 200, 255))
        y = y + 25
        
        draw.SimpleText("• Left Click: Open Admin Panel", "DermaDefault", 20, y, Color(255, 255, 255))
        y = y + 20
        
        draw.SimpleText("• Right Click: Quick Player Info", "DermaDefault", 20, y, Color(255, 255, 255))
        y = y + 20
        
        draw.SimpleText("• Reload: Refresh Data", "DermaDefault", 20, y, Color(255, 255, 255))
        y = y + 30
        
        -- Status
        if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
            draw.SimpleText("Status: ADMIN ACCESS", "DermaDefaultBold", 20, y, Color(100, 255, 100))
        else
            draw.SimpleText("Status: NO ACCESS", "DermaDefaultBold", 20, y, Color(255, 100, 100))
        end
        
        -- Footer
        draw.SimpleText("v1.0.0", "DermaDefault", width - 20, height - 20, Color(180, 180, 180), TEXT_ALIGN_RIGHT)
    end
end 