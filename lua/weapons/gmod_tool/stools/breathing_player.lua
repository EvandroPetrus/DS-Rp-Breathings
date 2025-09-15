--[[
    BreathingSystem - Player Tool
    =============================
    
    Tool for the Q menu to access player breathing controls
]]

TOOL.Category = "Breathing System"
TOOL.Name = "#tool.breathing_player.name"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Tool information
if CLIENT then
    language.Add("tool.breathing_player.name", "Breathing Controls")
    language.Add("tool.breathing_player.desc", "Control your breathing system")
    language.Add("tool.breathing_player.0", "Left click to open breathing menu")
    
    TOOL.Information = {
        {name = "left", text = "Open Breathing Menu"},
        {name = "right", text = "Quick Stats"},
        {name = "reload", text = "Toggle Training Mode"}
    }
end

-- Left click - Open breathing menu
function TOOL:LeftClick(trace)
    if CLIENT then
        -- Open the breathing system menu
        RunConsoleCommand("bs_menu")
        return true
    end
    
    return false
end

-- Right click - Show quick stats
function TOOL:RightClick(trace)
    if CLIENT then
        local ply = LocalPlayer()
        
        chat.AddText(Color(100, 200, 255), "[Breathing System Stats]")
        chat.AddText(Color(180, 180, 180), "Type: ", Color(255, 255, 255), ply:GetNWString("BreathingType", "none"))
        chat.AddText(Color(180, 180, 180), "Level: ", Color(255, 255, 255), tostring(ply:GetNWInt("BreathingLevel", 1)))
        chat.AddText(Color(180, 180, 180), "XP: ", Color(255, 255, 255), 
            ply:GetNWInt("BreathingExp", 0) .. "/" .. ply:GetNWInt("BreathingExpNext", 100))
        chat.AddText(Color(180, 180, 180), "Stamina: ", Color(255, 255, 255), 
            ply:GetNWInt("BreathingStamina", 0) .. "/" .. ply:GetNWInt("BreathingMaxStamina", 100))
        
        surface.PlaySound("buttons/button15.wav")
        return true
    end
    
    return false
end

-- Reload - Toggle training mode
function TOOL:Reload(trace)
    if CLIENT then
        RunConsoleCommand("bs_training", "toggle")
        return true
    end
    
    return false
end

-- Tool panel
function TOOL.BuildCPanel(panel)
    panel:ClearControls()
    
    -- Header
    panel:AddControl("Header", {
        Text = "Breathing System",
        Description = "Control your breathing techniques and forms"
    })
    
    -- Player stats display
    local statsPanel = vgui.Create("DPanel")
    statsPanel:SetTall(120)
    statsPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 200))
        
        local ply = LocalPlayer()
        local y = 10
        
        -- Breathing type
        local breathingType = ply:GetNWString("BreathingType", "none")
        local typeColor = Color(255, 255, 255)
        if breathingType == "water" then typeColor = Color(100, 150, 255)
        elseif breathingType == "fire" then typeColor = Color(255, 100, 100)
        elseif breathingType == "thunder" then typeColor = Color(255, 255, 100)
        elseif breathingType == "stone" then typeColor = Color(150, 100, 50)
        elseif breathingType == "wind" then typeColor = Color(200, 200, 255)
        end
        
        draw.SimpleText("Breathing: " .. breathingType:upper(), "DermaDefaultBold", 10, y, typeColor)
        y = y + 20
        
        -- Level
        draw.SimpleText("Level: " .. ply:GetNWInt("BreathingLevel", 1), "DermaDefault", 10, y, Color(255, 255, 255))
        y = y + 15
        
        -- XP bar
        local xp = ply:GetNWInt("BreathingExp", 0)
        local xpNext = ply:GetNWInt("BreathingExpNext", 100)
        local xpPercent = xpNext > 0 and (xp / xpNext) or 0
        
        draw.SimpleText("XP: " .. xp .. "/" .. xpNext, "DermaDefault", 10, y, Color(255, 255, 255))
        y = y + 15
        
        -- XP bar visual
        draw.RoundedBox(2, 10, y, w - 20, 10, Color(20, 20, 25))
        draw.RoundedBox(2, 10, y, (w - 20) * xpPercent, 10, Color(100, 200, 255))
        y = y + 15
        
        -- Stamina
        local stamina = ply:GetNWInt("BreathingStamina", 0)
        local maxStamina = ply:GetNWInt("BreathingMaxStamina", 100)
        local staminaPercent = maxStamina > 0 and (stamina / maxStamina) or 0
        
        draw.SimpleText("Stamina: " .. stamina .. "/" .. maxStamina, "DermaDefault", 10, y, Color(255, 255, 255))
        y = y + 15
        
        -- Stamina bar visual
        draw.RoundedBox(2, 10, y, w - 20, 10, Color(20, 20, 25))
        draw.RoundedBox(2, 10, y, (w - 20) * staminaPercent, 10, Color(100, 255, 100))
    end
    panel:AddItem(statsPanel)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Quick Actions
    panel:AddControl("Label", {Text = "Quick Actions:"})
    
    -- Open menu button
    local menuBtn = vgui.Create("DButton")
    menuBtn:SetText("Open Breathing Menu")
    menuBtn:SetTall(30)
    menuBtn.DoClick = function()
        RunConsoleCommand("bs_menu")
    end
    menuBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(70, 150, 200) or Color(100, 200, 255)
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.SimpleText(self:GetText(), "DermaDefaultBold", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    panel:AddItem(menuBtn)
    
    -- Training button
    local trainingBtn = vgui.Create("DButton")
    trainingBtn:SetText("Start Training")
    trainingBtn:SetTall(30)
    trainingBtn.DoClick = function()
        RunConsoleCommand("bs_training", "start")
    end
    panel:AddItem(trainingBtn)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Breathing type selector
    panel:AddControl("Label", {Text = "Change Breathing Type:"})
    
    local typeSelect = vgui.Create("DComboBox")
    typeSelect:SetValue("Select Type...")
    local types = {"water", "fire", "thunder", "stone", "wind"}
    for _, t in ipairs(types) do
        typeSelect:AddChoice(t:upper(), t)
    end
    typeSelect.OnSelect = function(self, index, text, value)
        RunConsoleCommand("bs_switch", value)
    end
    panel:AddItem(typeSelect)
    
    panel:AddControl("Label", {Text = ""})
    
    -- Form usage
    panel:AddControl("Label", {Text = "Use Forms:"})
    
    for i = 1, 5 do
        local formBtn = vgui.Create("DButton")
        formBtn:SetText("Form " .. i)
        formBtn:SetTall(25)
        formBtn.DoClick = function()
            RunConsoleCommand("bs_use_form", tostring(i))
        end
        formBtn.Paint = function(self, w, h)
            local ply = LocalPlayer()
            local level = ply:GetNWInt("BreathingLevel", 1)
            local canUse = level >= (i * 2 - 1) -- Basic level requirement
            
            local color = Color(60, 60, 65)
            if not canUse then
                color = Color(40, 40, 45)
            elseif self:IsHovered() then
                color = Color(80, 80, 85)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, color)
            
            local textColor = canUse and Color(255, 255, 255) or Color(100, 100, 100)
            draw.SimpleText(self:GetText(), "DermaDefault", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            if not canUse then
                draw.SimpleText("Lvl " .. (i * 2 - 1), "DermaDefault", w - 5, h/2, Color(255, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        panel:AddItem(formBtn)
    end
    
    panel:AddControl("Label", {Text = ""})
    
    -- Keybinds info
    local keybindsLabel = vgui.Create("DLabel")
    keybindsLabel:SetText("Keybinds:\nF3 - Quick Menu\nF4 - Training Mode")
    keybindsLabel:SetTextColor(Color(180, 180, 180))
    keybindsLabel:SetWrap(true)
    keybindsLabel:SetAutoStretchVertical(true)
    panel:AddItem(keybindsLabel)
end

-- Draw tool screen
if CLIENT then
    function TOOL:DrawToolScreen(width, height)
        surface.SetDrawColor(20, 20, 25, 250)
        surface.DrawRect(0, 0, width, height)
        
        local ply = LocalPlayer()
        local breathingType = ply:GetNWString("BreathingType", "none")
        
        -- Header with breathing type color
        local headerColor = Color(100, 200, 255)
        if breathingType == "water" then headerColor = Color(100, 150, 255)
        elseif breathingType == "fire" then headerColor = Color(255, 100, 100)
        elseif breathingType == "thunder" then headerColor = Color(255, 255, 100)
        elseif breathingType == "stone" then headerColor = Color(150, 100, 50)
        elseif breathingType == "wind" then headerColor = Color(200, 200, 255)
        end
        
        surface.SetDrawColor(headerColor)
        surface.DrawRect(0, 0, width, 40)
        
        draw.SimpleText("BREATHING SYSTEM", "DermaLarge", width/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(breathingType:upper(), "DermaDefaultBold", width/2, 50, headerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local y = 80
        
        -- Stats
        draw.SimpleText("Level: " .. ply:GetNWInt("BreathingLevel", 1), "DermaDefaultBold", 20, y, Color(255, 255, 255))
        y = y + 20
        
        -- XP bar
        local xp = ply:GetNWInt("BreathingExp", 0)
        local xpNext = ply:GetNWInt("BreathingExpNext", 100)
        local xpPercent = xpNext > 0 and (xp / xpNext) or 0
        
        draw.SimpleText("XP: " .. xp .. "/" .. xpNext, "DermaDefault", 20, y, Color(180, 180, 180))
        y = y + 15
        
        draw.RoundedBox(2, 20, y, width - 40, 10, Color(40, 40, 45))
        draw.RoundedBox(2, 20, y, (width - 40) * xpPercent, 10, Color(100, 200, 255))
        y = y + 20
        
        -- Stamina bar
        local stamina = ply:GetNWInt("BreathingStamina", 0)
        local maxStamina = ply:GetNWInt("BreathingMaxStamina", 100)
        local staminaPercent = maxStamina > 0 and (stamina / maxStamina) or 0
        
        draw.SimpleText("Stamina: " .. stamina .. "/" .. maxStamina, "DermaDefault", 20, y, Color(180, 180, 180))
        y = y + 15
        
        draw.RoundedBox(2, 20, y, width - 40, 10, Color(40, 40, 45))
        draw.RoundedBox(2, 20, y, (width - 40) * staminaPercent, 10, Color(100, 255, 100))
        y = y + 25
        
        -- Instructions
        draw.SimpleText("Controls:", "DermaDefaultBold", 20, y, Color(100, 200, 255))
        y = y + 20
        
        draw.SimpleText("• Left: Menu", "DermaDefault", 20, y, Color(255, 255, 255))
        y = y + 15
        
        draw.SimpleText("• Right: Stats", "DermaDefault", 20, y, Color(255, 255, 255))
        y = y + 15
        
        draw.SimpleText("• Reload: Training", "DermaDefault", 20, y, Color(255, 255, 255))
        
        -- Footer
        draw.SimpleText("v1.0.0", "DermaDefault", width - 20, height - 20, Color(180, 180, 180), TEXT_ALIGN_RIGHT)
    end
end 