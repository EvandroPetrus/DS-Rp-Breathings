--[[
    BreathingSystem - Admin HUD Client
    ==================================
    
    Client-side admin HUD interface with modern design
]]

-- Only run on client
if not CLIENT then return end

-- Admin HUD data storage
local AdminHUD = {
    data = {},
    isOpen = false,
    selectedTab = 1,
    selectedPlayer = nil,
    searchText = "",
    logFilter = "ALL"
}

-- Colors
local Colors = {
    background = Color(20, 20, 25, 250),
    header = Color(30, 30, 35, 255),
    sidebar = Color(25, 25, 30, 255),
    accent = Color(100, 200, 255, 255),
    accentDark = Color(70, 150, 200, 255),
    text = Color(255, 255, 255, 255),
    textDim = Color(180, 180, 180, 255),
    success = Color(100, 255, 100, 255),
    warning = Color(255, 200, 100, 255),
    error = Color(255, 100, 100, 255),
    button = Color(40, 40, 45, 255),
    buttonHover = Color(50, 50, 55, 255),
    buttonActive = Color(60, 60, 65, 255)
}

-- Fonts
surface.CreateFont("BreathingAdmin_Title", {
    font = "Roboto",
    size = 28,
    weight = 700,
    antialias = true
})

surface.CreateFont("BreathingAdmin_Header", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont("BreathingAdmin_SubHeader", {
    font = "Roboto",
    size = 16,
    weight = 500,
    antialias = true
})

surface.CreateFont("BreathingAdmin_Text", {
    font = "Roboto",
    size = 14,
    weight = 400,
    antialias = true
})

surface.CreateFont("BreathingAdmin_Small", {
    font = "Roboto",
    size = 12,
    weight = 400,
    antialias = true
})

-- Helper function to create styled button
local function CreateStyledButton(parent, text, x, y, w, h, onClick)
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(w, h)
    btn:SetText("")
    
    btn.text = text
    btn.isHovered = false
    btn.isPressed = false
    
    btn.Paint = function(self, w, h)
        local color = Colors.button
        if self.isPressed then
            color = Colors.buttonActive
        elseif self.isHovered then
            color = Colors.buttonHover
        end
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Draw text
        draw.SimpleText(self.text, "BreathingAdmin_Text", w/2, h/2, Colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btn.OnCursorEntered = function(self)
        self.isHovered = true
        surface.PlaySound("UI/buttonrollover.wav")
    end
    
    btn.OnCursorExited = function(self)
        self.isHovered = false
    end
    
    btn.OnMousePressed = function(self)
        self.isPressed = true
    end
    
    btn.OnMouseReleased = function(self)
        self.isPressed = false
    end
    
    btn.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        if onClick then onClick() end
    end
    
    return btn
end

-- Create the main admin HUD frame
local function CreateAdminHUD()
    if AdminHUD.frame and IsValid(AdminHUD.frame) then
        AdminHUD.frame:Remove()
    end
    
    -- Main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:SetDeleteOnClose(false)
    
    AdminHUD.frame = frame
    AdminHUD.isOpen = true
    
    -- Custom paint for modern look
    frame.Paint = function(self, w, h)
        -- Background
        draw.RoundedBox(8, 0, 0, w, h, Colors.background)
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 50, Colors.header, true, true, false, false)
        
        -- Title
        draw.SimpleText("Breathing System Admin Panel", "BreathingAdmin_Title", 15, 25, Colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Version info
        draw.SimpleText("v1.0.0", "BreathingAdmin_Small", w - 60, 25, Colors.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Custom close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frame:GetWide() - 40, 10)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Colors.error or Colors.textDim
        draw.SimpleText("✕", "BreathingAdmin_Header", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Close()
        AdminHUD.isOpen = false
    end
    
    -- Tab buttons
    local tabs = {
        {name = "Players", icon = "P"},
        {name = "Balance", icon = "B"},
        {name = "Breathing Types", icon = "T"},
        {name = "Forms", icon = "F"},
        {name = "Logs", icon = "L"},
        {name = "Settings", icon = "S"}
    }
    
    local tabContainer = vgui.Create("DPanel", frame)
    tabContainer:SetPos(0, 50)
    tabContainer:SetSize(150, frame:GetTall() - 50)
    tabContainer.Paint = function(self, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Colors.sidebar, false, false, false, true)
    end
    
    for i, tab in ipairs(tabs) do
        local tabBtn = vgui.Create("DButton", tabContainer)
        tabBtn:SetPos(0, (i-1) * 50)
        tabBtn:SetSize(150, 50)
        tabBtn:SetText("")
        
        tabBtn.Paint = function(self, w, h)
            local isSelected = AdminHUD.selectedTab == i
            local color = isSelected and Colors.accent or (self:IsHovered() and Colors.buttonHover or Color(0, 0, 0, 0))
            
            if isSelected then
                draw.RoundedBox(0, 0, 0, 4, h, Colors.accent)
            end
            
            if self:IsHovered() or isSelected then
                draw.RoundedBox(0, 4, 0, w-4, h, Color(color.r, color.g, color.b, isSelected and 30 or 20))
            end
            
            -- Icon and text
            draw.SimpleText(tab.icon, "BreathingAdmin_Header", 15, h/2, isSelected and Colors.accent or Colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tab.name, "BreathingAdmin_Text", 35, h/2, isSelected and Colors.text or Colors.textDim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        tabBtn.DoClick = function()
            AdminHUD.selectedTab = i
            UpdateContent()
            surface.PlaySound("UI/buttonclick.wav")
        end
    end
    
    -- Content area
    local content = vgui.Create("DPanel", frame)
    content:SetPos(150, 50)
    content:SetSize(frame:GetWide() - 150, frame:GetTall() - 50)
    content.Paint = function(self, w, h)
        -- Content background
    end
    
    AdminHUD.content = content
    
    -- Update content based on selected tab
    UpdateContent()
end

-- Update content based on selected tab
function UpdateContent()
    if not AdminHUD.content or not IsValid(AdminHUD.content) then return end
    
    -- Clear content
    AdminHUD.content:Clear()
    
    if AdminHUD.selectedTab == 1 then
        CreatePlayersTab()
    elseif AdminHUD.selectedTab == 2 then
        CreateBalanceTab()
    elseif AdminHUD.selectedTab == 3 then
        CreateBreathingTypesTab()
    elseif AdminHUD.selectedTab == 4 then
        CreateFormsTab()
    elseif AdminHUD.selectedTab == 5 then
        CreateLogsTab()
    elseif AdminHUD.selectedTab == 6 then
        CreateSettingsTab()
    end
end

-- Players tab
function CreatePlayersTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("Player Management", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Search bar
    local searchBar = vgui.Create("DTextEntry", parent)
    searchBar:SetPos(20, 70)
    searchBar:SetSize(200, 30)
    searchBar:SetPlaceholderText("Search players...")
    searchBar:SetFont("BreathingAdmin_Text")
    searchBar.OnChange = function(self)
        AdminHUD.searchText = self:GetValue()
    end
    
    -- Refresh button
    local refreshBtn = CreateStyledButton(parent, "Refresh", 230, 70, 80, 30, function()
        RequestAdminData()
    end)
    
    -- Player list
    local playerList = vgui.Create("DScrollPanel", parent)
    playerList:SetPos(20, 110)
    playerList:SetSize(300, parent:GetTall() - 140)
    
    local sbar = playerList:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 100))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Colors.accent)
    end
    
    -- Player details panel
    local detailsPanel = vgui.Create("DPanel", parent)
    detailsPanel:SetPos(340, 110)
    detailsPanel:SetSize(parent:GetWide() - 380, parent:GetTall() - 140)
    detailsPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Colors.button)
        
        if AdminHUD.selectedPlayer then
            local playerData = AdminHUD.data.players and AdminHUD.data.players[AdminHUD.selectedPlayer]
            if playerData then
                local y = 20
                
                -- Player name
                draw.SimpleText(playerData.name, "BreathingAdmin_Header", 20, y, Colors.accent)
                y = y + 30
                
                -- SteamID
                draw.SimpleText("SteamID: " .. playerData.steamid, "BreathingAdmin_Small", 20, y, Colors.textDim)
                y = y + 25
                
                -- Stats
                draw.SimpleText("Breathing Type: " .. (playerData.breathing_type or "none"), "BreathingAdmin_Text", 20, y, Colors.text)
                y = y + 20
                
                draw.SimpleText("Level: " .. (playerData.level or 1), "BreathingAdmin_Text", 20, y, Colors.text)
                y = y + 20
                
                draw.SimpleText("XP: " .. (playerData.xp or 0), "BreathingAdmin_Text", 20, y, Colors.text)
                y = y + 20
                
                draw.SimpleText("Stamina: " .. (playerData.stamina or 0) .. "/" .. (playerData.max_stamina or 100), "BreathingAdmin_Text", 20, y, Colors.text)
                y = y + 20
                
                draw.SimpleText("Concentration: " .. (playerData.concentration or 0) .. "/" .. (playerData.max_concentration or 100), "BreathingAdmin_Text", 20, y, Colors.text)
            end
        else
            draw.SimpleText("Select a player to view details", "BreathingAdmin_Text", w/2, h/2, Colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Action buttons for selected player
    if AdminHUD.selectedPlayer then
        local playerData = AdminHUD.data.players[AdminHUD.selectedPlayer]
        if playerData then
            local y = 280
            
            -- Edit Controls Panel
            local editPanel = vgui.Create("DPanel", detailsPanel)
            editPanel:SetPos(20, y)
            editPanel:SetSize(detailsPanel:GetWide() - 40, 280)
            editPanel.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 35, 200))
                draw.SimpleText("Edit Player: " .. playerData.name, "BreathingAdmin_SubHeader", 10, 5, Colors.accent)
            end
            
            local innerY = 35
            
            -- Breathing type dropdown with Apply button
            local breathingLabel = vgui.Create("DLabel", editPanel)
            breathingLabel:SetPos(10, innerY)
            breathingLabel:SetSize(100, 20)
            breathingLabel:SetText("Breathing Type:")
            breathingLabel:SetFont("BreathingAdmin_Text")
            breathingLabel:SetTextColor(Colors.text)
            
            local breathingDropdown = vgui.Create("DComboBox", editPanel)
            breathingDropdown:SetPos(120, innerY)
            breathingDropdown:SetSize(130, 25)
            
            -- Set current value
            local currentBreathing = playerData.breathing_type or "none"
            breathingDropdown:SetValue(currentBreathing)
            
            -- Add all breathing type choices
            breathingDropdown:AddChoice("none", "none")
            breathingDropdown:AddChoice("Water", "water")
            breathingDropdown:AddChoice("Fire", "fire") 
            breathingDropdown:AddChoice("Thunder", "thunder")
            breathingDropdown:AddChoice("Stone", "stone")
            breathingDropdown:AddChoice("Wind", "wind")
            
            -- Apply button for breathing type
            CreateStyledButton(editPanel, "Apply", 255, innerY, 50, 25, function()
                local _, value = breathingDropdown:GetSelected()
                if value then
                    SendAdminCommand("set_player_breathing", {
                        player_index = AdminHUD.selectedPlayer,
                        breathing_type = value
                    })
                    chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Set breathing type to: " .. value)
                end
            end)
            
            innerY = innerY + 30
            
            -- Level input
            local levelLabel = vgui.Create("DLabel", editPanel)
            levelLabel:SetPos(10, innerY)
            levelLabel:SetSize(100, 20)
            levelLabel:SetText("Level:")
            levelLabel:SetFont("BreathingAdmin_Text")
            levelLabel:SetTextColor(Colors.text)
            
            local levelInput = vgui.Create("DTextEntry", editPanel)
            levelInput:SetPos(120, innerY)
            levelInput:SetSize(60, 25)
            levelInput:SetNumeric(true)
            levelInput:SetValue(tostring(playerData.level or 1))
            levelInput:SetFont("BreathingAdmin_Text")
            
            -- Level quick buttons
            CreateStyledButton(editPanel, "+10", 185, innerY, 30, 25, function()
                local current = tonumber(levelInput:GetValue()) or 1
                levelInput:SetValue(tostring(math.min(100, current + 10)))
            end)
            
            CreateStyledButton(editPanel, "Max", 220, innerY, 30, 25, function()
                levelInput:SetValue("100")
            end)
            
            CreateStyledButton(editPanel, "Apply", 255, innerY, 50, 25, function()
                local level = tonumber(levelInput:GetValue())
                if level then
                    SendAdminCommand("set_player_level", {
                        player_index = AdminHUD.selectedPlayer,
                        level = math.Clamp(level, 1, 100)
                    })
                    chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Set level to: " .. level)
                end
            end)
            
            innerY = innerY + 30
            
            -- XP input
            local xpLabel = vgui.Create("DLabel", editPanel)
            xpLabel:SetPos(10, innerY)
            xpLabel:SetSize(100, 20)
            xpLabel:SetText("XP:")
            xpLabel:SetFont("BreathingAdmin_Text")
            xpLabel:SetTextColor(Colors.text)
            
            local xpInput = vgui.Create("DTextEntry", editPanel)
            xpInput:SetPos(120, innerY)
            xpInput:SetSize(60, 25)
            xpInput:SetNumeric(true)
            xpInput:SetValue(tostring(playerData.xp or 0))
            xpInput:SetFont("BreathingAdmin_Text")
            
            -- XP quick buttons
            CreateStyledButton(editPanel, "+100", 185, innerY, 35, 25, function()
                local current = tonumber(xpInput:GetValue()) or 0
                xpInput:SetValue(tostring(current + 100))
            end)
            
            CreateStyledButton(editPanel, "+1K", 223, innerY, 30, 25, function()
                local current = tonumber(xpInput:GetValue()) or 0
                xpInput:SetValue(tostring(current + 1000))
            end)
            
            CreateStyledButton(editPanel, "Apply", 255, innerY, 50, 25, function()
                local xp = tonumber(xpInput:GetValue())
                if xp then
                    SendAdminCommand("set_player_xp", {
                        player_index = AdminHUD.selectedPlayer,
                        xp = math.max(0, xp)
                    })
                    chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Set XP to: " .. xp)
                end
            end)
            
            innerY = innerY + 30
            
            -- Stamina controls
            local staminaLabel = vgui.Create("DLabel", editPanel)
            staminaLabel:SetPos(10, innerY)
            staminaLabel:SetSize(100, 20)
            staminaLabel:SetText("Stamina:")
            staminaLabel:SetFont("BreathingAdmin_Text")
            staminaLabel:SetTextColor(Colors.text)
            
            local staminaInput = vgui.Create("DTextEntry", editPanel)
            staminaInput:SetPos(120, innerY)
            staminaInput:SetSize(40, 25)
            staminaInput:SetNumeric(true)
            staminaInput:SetValue(tostring(playerData.stamina or 100))
            staminaInput:SetFont("BreathingAdmin_Small")
            
            local slashLabel = vgui.Create("DLabel", editPanel)
            slashLabel:SetPos(162, innerY)
            slashLabel:SetSize(10, 25)
            slashLabel:SetText("/")
            slashLabel:SetFont("BreathingAdmin_Text")
            slashLabel:SetTextColor(Colors.textDim)
            
            local maxStaminaInput = vgui.Create("DTextEntry", editPanel)
            maxStaminaInput:SetPos(175, innerY)
            maxStaminaInput:SetSize(40, 25)
            maxStaminaInput:SetNumeric(true)
            maxStaminaInput:SetValue(tostring(playerData.max_stamina or 100))
            maxStaminaInput:SetFont("BreathingAdmin_Small")
            
            CreateStyledButton(editPanel, "Full", 220, innerY, 33, 25, function()
                local max = tonumber(maxStaminaInput:GetValue()) or 100
                staminaInput:SetValue(tostring(max))
            end)
            
            CreateStyledButton(editPanel, "Apply", 255, innerY, 50, 25, function()
                local stamina = tonumber(staminaInput:GetValue())
                local maxStamina = tonumber(maxStaminaInput:GetValue())
                if stamina and maxStamina then
                    SendAdminCommand("set_player_stamina", {
                        player_index = AdminHUD.selectedPlayer,
                        stamina = math.Clamp(stamina, 0, maxStamina),
                        max_stamina = math.max(1, maxStamina)
                    })
                    chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Set stamina to: " .. stamina .. "/" .. maxStamina)
                end
            end)
            
            innerY = innerY + 30
            
            -- Concentration controls
            local concLabel = vgui.Create("DLabel", editPanel)
            concLabel:SetPos(10, innerY)
            concLabel:SetSize(100, 20)
            concLabel:SetText("Concentration:")
            concLabel:SetFont("BreathingAdmin_Text")
            concLabel:SetTextColor(Colors.text)
            
            local concInput = vgui.Create("DTextEntry", editPanel)
            concInput:SetPos(120, innerY)
            concInput:SetSize(40, 25)
            concInput:SetNumeric(true)
            concInput:SetValue(tostring(playerData.concentration or 0))
            concInput:SetFont("BreathingAdmin_Small")
            
            local slashLabel2 = vgui.Create("DLabel", editPanel)
            slashLabel2:SetPos(162, innerY)
            slashLabel2:SetSize(10, 25)
            slashLabel2:SetText("/")
            slashLabel2:SetFont("BreathingAdmin_Text")
            slashLabel2:SetTextColor(Colors.textDim)
            
            local maxConcInput = vgui.Create("DTextEntry", editPanel)
            maxConcInput:SetPos(175, innerY)
            maxConcInput:SetSize(40, 25)
            maxConcInput:SetNumeric(true)
            maxConcInput:SetValue(tostring(playerData.max_concentration or 100))
            maxConcInput:SetFont("BreathingAdmin_Small")
            
            CreateStyledButton(editPanel, "Full", 220, innerY, 33, 25, function()
                local max = tonumber(maxConcInput:GetValue()) or 100
                concInput:SetValue(tostring(max))
            end)
            
            CreateStyledButton(editPanel, "Apply", 255, innerY, 50, 25, function()
                local conc = tonumber(concInput:GetValue())
                local maxConc = tonumber(maxConcInput:GetValue())
                if conc and maxConc then
                    SendAdminCommand("set_player_concentration", {
                        player_index = AdminHUD.selectedPlayer,
                        concentration = math.Clamp(conc, 0, maxConc),
                        max_concentration = math.max(1, maxConc)
                    })
                    chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Set concentration to: " .. conc .. "/" .. maxConc)
                end
            end)
            
            innerY = innerY + 35
            
            -- Quick action buttons
            local btnY = innerY
            CreateStyledButton(editPanel, "Reset Player", 10, btnY, 100, 28, function()
                Derma_Query(
                    "Are you sure you want to reset this player's data?",
                    "Confirm Reset",
                    "Yes", function()
                        SendAdminCommand("reset_player", {
                            player_index = AdminHUD.selectedPlayer
                        })
                    end,
                    "No", function() end
                )
            end)
            
            CreateStyledButton(editPanel, "Full Heal", 115, btnY, 80, 28, function()
                SendAdminCommand("set_player_stamina", {
                    player_index = AdminHUD.selectedPlayer,
                    stamina = playerData.max_stamina or 100,
                    max_stamina = playerData.max_stamina or 100
                })
            end)
            
            CreateStyledButton(editPanel, "Max Level", 200, btnY, 80, 28, function()
                SendAdminCommand("set_player_level", {
                    player_index = AdminHUD.selectedPlayer,
                    level = 100
                })
            end)
            
            btnY = btnY + 33
            
            CreateStyledButton(editPanel, "Give 1000 XP", 10, btnY, 100, 28, function()
                SendAdminCommand("set_player_xp", {
                    player_index = AdminHUD.selectedPlayer,
                    xp = (playerData.xp or 0) + 1000
                })
            end)
            
            CreateStyledButton(editPanel, "Unlock All Forms", 115, btnY, 110, 28, function()
                for i = 1, 5 do
                    SendAdminCommand("unlock_form", {
                        player_index = AdminHUD.selectedPlayer,
                        form_id = playerData.breathing_type .. "_form_" .. i
                    })
                end
            end)
        end
    end
    
    -- Populate player list
    for entIndex, playerData in pairs(AdminHUD.data.players or {}) do
        if AdminHUD.searchText == "" or string.find(string.lower(playerData.name), string.lower(AdminHUD.searchText)) then
            local playerPanel = vgui.Create("DButton", playerList)
            playerPanel:SetSize(280, 60)
            playerPanel:Dock(TOP)
            playerPanel:DockMargin(5, 5, 5, 0)
            playerPanel:SetText("")
            
            playerPanel.Paint = function(self, w, h)
                local isSelected = AdminHUD.selectedPlayer == entIndex
                local bgColor = isSelected and Colors.accent or (self:IsHovered() and Colors.buttonHover or Colors.button)
                
                draw.RoundedBox(6, 0, 0, w, h, bgColor)
                
                if isSelected then
                    draw.RoundedBox(6, 0, 0, w, h, Color(Colors.accent.r, Colors.accent.g, Colors.accent.b, 30))
                end
                
                -- Player info
                local textColor = isSelected and Colors.text or (self:IsHovered() and Colors.text or Colors.textDim)
                draw.SimpleText(playerData.name, "BreathingAdmin_SubHeader", 10, 15, textColor)
                draw.SimpleText("Level " .. (playerData.level or 1) .. " | " .. (playerData.breathing_type or "none"), "BreathingAdmin_Small", 10, 35, textColor)
                
                -- Status indicator
                local statusColor = playerData.stamina and playerData.stamina > 50 and Colors.success or Colors.warning
                draw.RoundedBox(4, w - 15, h/2 - 4, 8, 8, statusColor)
            end
            
            playerPanel.DoClick = function()
                AdminHUD.selectedPlayer = entIndex
                surface.PlaySound("UI/buttonclick.wav")
            end
        end
    end
end

-- Balance tab
function CreateBalanceTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("Balance Configuration", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Categories
    local categories = {"damage", "stamina", "cooldowns", "xp", "effects", "combat"}
    local categoryPanels = {}
    
    local scrollPanel = vgui.Create("DScrollPanel", parent)
    scrollPanel:SetPos(20, 70)
    scrollPanel:SetSize(parent:GetWide() - 40, parent:GetTall() - 100)
    
    for i, category in ipairs(categories) do
        local catPanel = vgui.Create("DPanel", scrollPanel)
        catPanel:SetSize(scrollPanel:GetWide() - 20, 200)
        catPanel:Dock(TOP)
        catPanel:DockMargin(0, 10, 0, 0)
        
        catPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Colors.button)
            draw.SimpleText(string.upper(category), "BreathingAdmin_SubHeader", 15, 15, Colors.accent)
        end
        
        local y = 40
        local balanceData = AdminHUD.data.balance and AdminHUD.data.balance.categories and AdminHUD.data.balance.categories[category]
        
        if balanceData then
            for key, data in pairs(balanceData) do
                local label = vgui.Create("DLabel", catPanel)
                label:SetPos(20, y)
                label:SetSize(200, 20)
                label:SetText(key .. ":")
                label:SetFont("BreathingAdmin_Text")
                label:SetTextColor(data.modified and Colors.warning or Colors.text)
                
                local input = vgui.Create("DTextEntry", catPanel)
                input:SetPos(220, y)
                input:SetSize(100, 20)
                input:SetValue(tostring(data.value))
                input:SetFont("BreathingAdmin_Small")
                
                local setBtn = CreateStyledButton(catPanel, "Set", 330, y, 40, 20, function()
                    local value = tonumber(input:GetValue()) or input:GetValue()
                    SendAdminCommand("set_balance", {
                        category = category,
                        key = key,
                        value = value
                    })
                end)
                
                if data.default then
                    local defaultLabel = vgui.Create("DLabel", catPanel)
                    defaultLabel:SetPos(380, y)
                    defaultLabel:SetSize(100, 20)
                    defaultLabel:SetText("Default: " .. tostring(data.default))
                    defaultLabel:SetFont("BreathingAdmin_Small")
                    defaultLabel:SetTextColor(Colors.textDim)
                end
                
                y = y + 25
            end
        end
        
        -- Reset category button
        CreateStyledButton(catPanel, "Reset Category", catPanel:GetWide() - 130, 15, 110, 25, function()
            SendAdminCommand("reset_balance", {category = category})
        end)
    end
    
    -- Global actions
    local actionsPanel = vgui.Create("DPanel", parent)
    actionsPanel:SetPos(20, parent:GetTall() - 50)
    actionsPanel:SetSize(parent:GetWide() - 40, 40)
    actionsPanel.Paint = function() end
    
    CreateStyledButton(actionsPanel, "Reset All", 0, 5, 100, 30, function()
        SendAdminCommand("reset_balance", {})
    end)
    
    -- Preset management
    local presetLabel = vgui.Create("DLabel", actionsPanel)
    presetLabel:SetPos(120, 10)
    presetLabel:SetSize(60, 20)
    presetLabel:SetText("Presets:")
    presetLabel:SetFont("BreathingAdmin_Text")
    presetLabel:SetTextColor(Colors.text)
    
    local presetDropdown = vgui.Create("DComboBox", actionsPanel)
    presetDropdown:SetPos(180, 7)
    presetDropdown:SetSize(150, 25)
    presetDropdown:SetValue("Select Preset")
    
    for _, preset in ipairs(AdminHUD.data.presets or {}) do
        presetDropdown:AddChoice(preset)
    end
    
    CreateStyledButton(actionsPanel, "Load", 340, 5, 60, 30, function()
        local preset = presetDropdown:GetSelected()
        if preset then
            SendAdminCommand("load_preset", {name = preset})
        end
    end)
    
    local saveInput = vgui.Create("DTextEntry", actionsPanel)
    saveInput:SetPos(420, 7)
    saveInput:SetSize(120, 25)
    saveInput:SetPlaceholderText("Preset name...")
    
    CreateStyledButton(actionsPanel, "Save", 550, 5, 60, 30, function()
        local name = saveInput:GetValue()
        if name and name ~= "" then
            SendAdminCommand("save_preset", {name = name})
        end
    end)
end

-- Breathing Types tab
function CreateBreathingTypesTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("Breathing Types Overview", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Total Types: " .. table.Count(AdminHUD.data.breathingTypes or {}), "BreathingAdmin_Text", w - 10, h/2, Colors.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Scroll panel for breathing types
    local scrollPanel = vgui.Create("DScrollPanel", parent)
    scrollPanel:SetPos(20, 70)
    scrollPanel:SetSize(parent:GetWide() - 40, parent:GetTall() - 100)
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 100))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Colors.accent)
    end
    
    -- Create cards for each breathing type
    local x, y = 10, 10
    local cardWidth, cardHeight = 280, 180
    local spacing = 10
    local cardsPerRow = math.floor((scrollPanel:GetWide() - 20) / (cardWidth + spacing))
    local cardIndex = 0
    
    for id, typeData in pairs(AdminHUD.data.breathingTypes or {}) do
        local typePanel = vgui.Create("DPanel", scrollPanel)
        
        local row = math.floor(cardIndex / cardsPerRow)
        local col = cardIndex % cardsPerRow
        
        typePanel:SetPos(col * (cardWidth + spacing) + 10, row * (cardHeight + spacing) + 10)
        typePanel:SetSize(cardWidth, cardHeight)
        
        typePanel.Paint = function(self, w, h)
            -- Card background
            draw.RoundedBox(8, 0, 0, w, h, Colors.button)
            
            -- Type color bar at top
            if typeData.color then
                draw.RoundedBoxEx(8, 0, 0, w, 30, typeData.color, true, true, false, false)
            end
            
            -- Type ID badge
            draw.RoundedBox(4, w - 70, 5, 65, 20, Color(0, 0, 0, 150))
            draw.SimpleText(string.upper(id), "BreathingAdmin_Small", w - 37, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Type name
            draw.SimpleText(typeData.name or "Unknown", "BreathingAdmin_SubHeader", 10, 40, Colors.accent)
            
            -- Category
            draw.SimpleText("Category: " .. (typeData.category or "unknown"), "BreathingAdmin_Small", 10, 65, Colors.textDim)
            
            -- Description
            local desc = typeData.description or "No description available"
            local wrappedText = {}
            local words = string.Explode(" ", desc)
            local currentLine = ""
            
            surface.SetFont("BreathingAdmin_Small")
            for _, word in ipairs(words) do
                local testLine = currentLine .. (currentLine == "" and "" or " ") .. word
                local tw, th = surface.GetTextSize(testLine)
                
                if tw > w - 20 then
                    if currentLine != "" then
                        table.insert(wrappedText, currentLine)
                    end
                    currentLine = word
                else
                    currentLine = testLine
                end
            end
            if currentLine != "" then
                table.insert(wrappedText, currentLine)
            end
            
            for i = 1, math.min(3, #wrappedText) do
                draw.SimpleText(wrappedText[i], "BreathingAdmin_Small", 10, 80 + (i * 15), Colors.text)
            end
            
            -- Player count using this type
            local count = 0
            for _, playerData in pairs(AdminHUD.data.players or {}) do
                if playerData.breathing_type == id then
                    count = count + 1
                end
            end
            
            draw.RoundedBox(4, 10, h - 30, w - 20, 25, Color(30, 30, 35, 200))
            draw.SimpleText("Active Players: " .. count, "BreathingAdmin_Small", w/2, h - 17, count > 0 and Colors.success or Colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Add click functionality to assign to selected player
        local assignBtn = vgui.Create("DButton", typePanel)
        assignBtn:SetPos(10, cardHeight - 30)
        assignBtn:SetSize(cardWidth - 20, 25)
        assignBtn:SetText("")
        assignBtn.Paint = function() end -- Invisible button
        assignBtn.DoClick = function()
            if AdminHUD.selectedPlayer then
                SendAdminCommand("set_player_breathing", {
                    player_index = AdminHUD.selectedPlayer,
                    breathing_type = id
                })
                chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Assigned " .. typeData.name .. " to selected player")
            else
                chat.AddText(Color(255, 100, 100), "[Admin] ", Color(255, 255, 255), "No player selected! Go to Players tab first.")
            end
        end
        
        cardIndex = cardIndex + 1
    end
end

-- Forms tab
function CreateFormsTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("Forms Management", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Total Forms: " .. table.Count(AdminHUD.data.forms or {}), "BreathingAdmin_Text", w - 10, h/2, Colors.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Filter buttons for breathing types
    local filterY = 70
    local filters = {"all", "water", "fire", "thunder", "stone", "wind"}
    local selectedFilter = "all"
    
    for i, filter in ipairs(filters) do
        local filterBtn = CreateStyledButton(parent, string.upper(filter), 20 + (i-1) * 80, filterY, 75, 25, function()
            selectedFilter = filter
            UpdateFormsList()
        end)
    end
    
    -- Forms list
    local formsList = vgui.Create("DListView", parent)
    formsList:SetPos(20, 105)
    formsList:SetSize(parent:GetWide() - 40, parent:GetTall() - 185)
    formsList:SetMultiSelect(false)
    
    formsList:AddColumn("Form Name"):SetWidth(250)
    formsList:AddColumn("Type"):SetWidth(80)
    formsList:AddColumn("Damage"):SetWidth(70)
    formsList:AddColumn("Stamina"):SetWidth(70)
    formsList:AddColumn("Cooldown"):SetWidth(70)
    formsList:AddColumn("ID"):SetWidth(150)
    
    -- Function to update forms list based on filter
    function UpdateFormsList()
        formsList:Clear()
        
        for id, formData in pairs(AdminHUD.data.forms or {}) do
            if selectedFilter == "all" or formData.breathing_type == selectedFilter then
                formsList:AddLine(
                    formData.name or "Unknown",
                    string.upper(formData.breathing_type or "none"),
                    tostring(formData.damage or 0),
                    tostring(formData.stamina_cost or 0),
                    tostring(formData.cooldown or 0) .. "s",
                    id
                )
            end
        end
        
        -- Color code rows by type
        for k, line in pairs(formsList:GetLines()) do
            local breathingType = string.lower(line:GetColumnText(2))
            
            line.Paint = function(self, w, h)
                local bgColor = Colors.button
                
                if self:IsSelected() then
                    bgColor = Colors.accent
                elseif self:IsHovered() then
                    bgColor = Colors.buttonHover
                end
                
                draw.RoundedBox(4, 0, 0, w, h, bgColor)
                
                -- Type color indicator
                local typeColor = Color(100, 100, 100)
                if breathingType == "water" then typeColor = Color(100, 150, 255)
                elseif breathingType == "fire" then typeColor = Color(255, 100, 100)
                elseif breathingType == "thunder" then typeColor = Color(255, 255, 100)
                elseif breathingType == "stone" then typeColor = Color(150, 100, 50)
                elseif breathingType == "wind" then typeColor = Color(200, 200, 255)
                end
                
                draw.RoundedBox(4, 2, 2, 4, h - 4, typeColor)
            end
        end
    end
    
    -- Initial population
    UpdateFormsList()
    
    -- Action buttons panel
    local actionsPanel = vgui.Create("DPanel", parent)
    actionsPanel:SetPos(20, parent:GetTall() - 70)
    actionsPanel:SetSize(parent:GetWide() - 40, 50)
    actionsPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 35, 200))
    end
    
    -- Test form on selected player button
    CreateStyledButton(actionsPanel, "Test Form on Player", 10, 10, 150, 30, function()
        if not AdminHUD.selectedPlayer then
            chat.AddText(Color(255, 100, 100), "[Admin] ", Color(255, 255, 255), "No player selected! Select a player from the Players tab first.")
            return
        end
        
        local selected = formsList:GetSelectedLine()
        if selected then
            local line = formsList:GetLine(selected)
            if line then
                local formId = line:GetColumnText(6) -- ID is in column 6
                local formName = line:GetColumnText(1)
                
                -- Get the form number from the ID (e.g., "water_form_1" -> 1)
                local formNum = string.match(formId, "_(%d+)$") or "1"
                
                SendAdminCommand("test_form", {
                    player_index = AdminHUD.selectedPlayer,
                    form_id = formId,
                    form_number = tonumber(formNum)
                })
                
                chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Testing form: " .. formName)
            end
        else
            chat.AddText(Color(255, 100, 100), "[Admin] ", Color(255, 255, 255), "No form selected!")
        end
    end)
    
    -- Give form to player button
    CreateStyledButton(actionsPanel, "Unlock for Player", 170, 10, 130, 30, function()
        if not AdminHUD.selectedPlayer then
            chat.AddText(Color(255, 100, 100), "[Admin] ", Color(255, 255, 255), "No player selected!")
            return
        end
        
        local selected = formsList:GetSelectedLine()
        if selected then
            local line = formsList:GetLine(selected)
            if line then
                local formId = line:GetColumnText(6)
                local formName = line:GetColumnText(1)
                
                SendAdminCommand("unlock_form", {
                    player_index = AdminHUD.selectedPlayer,
                    form_id = formId
                })
                
                chat.AddText(Color(100, 255, 100), "[Admin] ", Color(255, 255, 255), "Unlocked form: " .. formName)
            end
        else
            chat.AddText(Color(255, 100, 100), "[Admin] ", Color(255, 255, 255), "No form selected!")
        end
    end)
    
    -- Info label
    local infoLabel = vgui.Create("DLabel", actionsPanel)
    infoLabel:SetPos(320, 10)
    infoLabel:SetSize(300, 30)
    infoLabel:SetText("Selected Player: " .. (AdminHUD.selectedPlayer and "Yes" or "None"))
    infoLabel:SetFont("BreathingAdmin_Text")
    infoLabel:SetTextColor(AdminHUD.selectedPlayer and Colors.success or Colors.warning)
    infoLabel:SetContentAlignment(4) -- Center vertically
end

-- Logs tab
function CreateLogsTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("System Logs", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Filter buttons
    local filters = {"ALL", "ERROR", "WARNING", "INFO", "DEBUG"}
    local x = 20
    
    for _, filter in ipairs(filters) do
        local filterBtn = CreateStyledButton(parent, filter, x, 70, 70, 25, function()
            AdminHUD.logFilter = filter
            UpdateLogsDisplay()
        end)
        x = x + 75
    end
    
    -- Clear logs button
    CreateStyledButton(parent, "Clear Logs", parent:GetWide() - 120, 70, 100, 25, function()
        SendAdminCommand("clear_logs", {})
    end)
    
    -- Logs display
    local logsPanel = vgui.Create("DScrollPanel", parent)
    logsPanel:SetPos(20, 105)
    logsPanel:SetSize(parent:GetWide() - 40, parent:GetTall() - 135)
    
    AdminHUD.logsPanel = logsPanel
    
    UpdateLogsDisplay()
end

-- Update logs display
function UpdateLogsDisplay()
    if not AdminHUD.logsPanel or not IsValid(AdminHUD.logsPanel) then return end
    
    AdminHUD.logsPanel:Clear()
    
    for _, log in ipairs(AdminHUD.data.logs or {}) do
        if AdminHUD.logFilter == "ALL" or log.level == AdminHUD.logFilter then
            local logEntry = vgui.Create("DPanel", AdminHUD.logsPanel)
            logEntry:SetSize(AdminHUD.logsPanel:GetWide() - 20, 40)
            logEntry:Dock(TOP)
            logEntry:DockMargin(0, 2, 0, 0)
            
            logEntry.Paint = function(self, w, h)
                local bgColor = Colors.button
                local levelColor = Colors.text
                
                if log.level == "ERROR" then
                    levelColor = Colors.error
                elseif log.level == "WARNING" then
                    levelColor = Colors.warning
                elseif log.level == "INFO" then
                    levelColor = Colors.success
                elseif log.level == "DEBUG" then
                    levelColor = Colors.accent
                end
                
                draw.RoundedBox(4, 0, 0, w, h, bgColor)
                
                -- Timestamp
                draw.SimpleText(log.timestamp or "Unknown", "BreathingAdmin_Small", 10, 10, Colors.textDim)
                
                -- Level
                draw.SimpleText("[" .. log.level .. "]", "BreathingAdmin_Small", 150, 10, levelColor)
                
                -- Category
                draw.SimpleText("[" .. (log.category or "General") .. "]", "BreathingAdmin_Small", 220, 10, Colors.textDim)
                
                -- Message
                local msg = log.message or ""
                if #msg > 100 then
                    msg = string.sub(msg, 1, 97) .. "..."
                end
                draw.SimpleText(msg, "BreathingAdmin_Small", 10, 25, Colors.text)
            end
        end
    end
end

-- Settings tab
function CreateSettingsTab()
    local parent = AdminHUD.content
    
    -- Header
    local header = vgui.Create("DPanel", parent)
    header:SetPos(20, 20)
    header:SetSize(parent:GetWide() - 40, 40)
    header.Paint = function(self, w, h)
        draw.SimpleText("System Settings", "BreathingAdmin_Header", 0, h/2, Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    local y = 70
    
    -- Log level setting
    local logLabel = vgui.Create("DLabel", parent)
    logLabel:SetPos(20, y)
    logLabel:SetSize(100, 25)
    logLabel:SetText("Log Level:")
    logLabel:SetFont("BreathingAdmin_Text")
    logLabel:SetTextColor(Colors.text)
    
    local logDropdown = vgui.Create("DComboBox", parent)
    logDropdown:SetPos(130, y)
    logDropdown:SetSize(150, 25)
    logDropdown:SetValue("INFO")
    
    local levels = {"ERROR", "WARNING", "INFO", "DEBUG", "VERBOSE"}
    for _, level in ipairs(levels) do
        logDropdown:AddChoice(level)
    end
    
    logDropdown.OnSelect = function(self, index, value)
        SendAdminCommand("set_log_level", {level = value})
    end
    
    y = y + 40
    
    -- Auto-save toggle
    local autoSaveCheck = vgui.Create("DCheckBoxLabel", parent)
    autoSaveCheck:SetPos(20, y)
    autoSaveCheck:SetSize(200, 25)
    autoSaveCheck:SetText("Enable Auto-Save")
    autoSaveCheck:SetFont("BreathingAdmin_Text")
    autoSaveCheck:SetTextColor(Colors.text)
    autoSaveCheck:SetValue(true)
    
    y = y + 40
    
    -- Performance monitoring toggle
    local perfCheck = vgui.Create("DCheckBoxLabel", parent)
    perfCheck:SetPos(20, y)
    perfCheck:SetSize(200, 25)
    perfCheck:SetText("Performance Monitoring")
    perfCheck:SetFont("BreathingAdmin_Text")
    perfCheck:SetTextColor(Colors.text)
    perfCheck:SetValue(true)
    
    y = y + 40
    
    -- PvP enabled toggle
    local pvpCheck = vgui.Create("DCheckBoxLabel", parent)
    pvpCheck:SetPos(20, y)
    pvpCheck:SetSize(200, 25)
    pvpCheck:SetText("Enable PvP")
    pvpCheck:SetFont("BreathingAdmin_Text")
    pvpCheck:SetTextColor(Colors.text)
    pvpCheck:SetValue(true)
    
    pvpCheck.OnChange = function(self, val)
        SendAdminCommand("set_balance", {
            category = "combat",
            key = "pvp_enabled",
            value = val
        })
    end
    
    y = y + 60
    
    -- System info
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(20, y)
    infoPanel:SetSize(400, 150)
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Colors.button)
        
        draw.SimpleText("System Information", "BreathingAdmin_SubHeader", 10, 10, Colors.accent)
        
        draw.SimpleText("Version: 1.0.0", "BreathingAdmin_Text", 10, 35, Colors.text)
        draw.SimpleText("Players: " .. table.Count(AdminHUD.data.players or {}), "BreathingAdmin_Text", 10, 55, Colors.text)
        draw.SimpleText("Breathing Types: " .. table.Count(AdminHUD.data.breathingTypes or {}), "BreathingAdmin_Text", 10, 75, Colors.text)
        draw.SimpleText("Forms: " .. table.Count(AdminHUD.data.forms or {}), "BreathingAdmin_Text", 10, 95, Colors.text)
        draw.SimpleText("Active Presets: " .. table.Count(AdminHUD.data.presets or {}), "BreathingAdmin_Text", 10, 115, Colors.text)
    end
end

-- Send admin command to server
function SendAdminCommand(cmd, args)
    net.Start("BreathingSystem_AdminCommand")
    net.WriteString(cmd)
    net.WriteTable(args or {})
    net.SendToServer()
    
    -- Request updated data after a short delay
    timer.Simple(0.5, function()
        RequestAdminData()
    end)
end

-- Request updated data from server
function RequestAdminData()
    net.Start("BreathingSystem_RequestAdminData")
    net.SendToServer()
end

-- Receive admin HUD data
net.Receive("BreathingSystem_OpenAdminHUD", function()
    print("[BreathingSystem] Received admin HUD data from server")
    AdminHUD.data = net.ReadTable()
    print("[BreathingSystem] Data received, creating admin HUD...")
    CreateAdminHUD()
    print("[BreathingSystem] Admin HUD should now be visible")
end)

-- Receive data sync
net.Receive("BreathingSystem_AdminDataSync", function()
    local newData = net.ReadTable()
    
    -- Update specific data
    if newData.players then
        AdminHUD.data.players = newData.players
    end
    if newData.balance then
        AdminHUD.data.balance = newData.balance
    end
    if newData.logs then
        AdminHUD.data.logs = newData.logs
    end
    
    -- Update display if open
    if AdminHUD.isOpen then
        UpdateContent()
    end
end)

-- Console command for refresh
concommand.Add("breathingadmin_refresh", function()
    RequestAdminData()
end)

-- Debug command to test admin HUD directly
concommand.Add("breathingadmin_test", function()
    if not LocalPlayer():IsAdmin() and not LocalPlayer():IsSuperAdmin() then
        chat.AddText(Color(255, 100, 100), "[BreathingSystem] ", Color(255, 255, 255), "You must be an admin!")
        return
    end
    
    print("[BreathingSystem] Testing admin HUD with dummy data...")
    
    -- Create dummy data for testing
    AdminHUD.data = {
        players = {
            [1] = {
                name = "Test Player",
                steamid = "STEAM_0:0:12345",
                breathing_type = "water",
                level = 5,
                xp = 250,
                stamina = 80,
                max_stamina = 100,
                concentration = 50,
                max_concentration = 100,
                forms_unlocked = {},
                total_concentration_active = false
            }
        },
        breathingTypes = {
            water = {name = "Water Breathing", description = "Fluid and adaptive", category = "elemental", color = Color(100, 150, 255)},
            fire = {name = "Fire Breathing", description = "Fierce and powerful", category = "elemental", color = Color(255, 100, 100)}
        },
        forms = {
            water_form_1 = {name = "Water Surface Slash", description = "Basic water attack", breathing_type = "water", damage = 30, stamina_cost = 10, cooldown = 3}
        },
        balance = {categories = {}},
        logs = {
            {timestamp = os.date("%Y-%m-%d %H:%M:%S"), level = "INFO", message = "Test log entry", category = "Test"}
        },
        presets = {"Default", "Competitive", "Casual"}
    }
    
    CreateAdminHUD()
    chat.AddText(Color(100, 255, 100), "[BreathingSystem] ", Color(255, 255, 255), "Admin HUD opened with test data")
end)

-- Also add a simpler version check
concommand.Add("breathingadmin_check", function()
    print("[BreathingSystem] Admin HUD client is loaded and ready")
    print("[BreathingSystem] You are " .. (LocalPlayer():IsAdmin() and "an admin" or "NOT an admin"))
    print("[BreathingSystem] AdminHUD table exists: " .. tostring(AdminHUD ~= nil))
    print("[BreathingSystem] CreateAdminHUD function exists: " .. tostring(CreateAdminHUD ~= nil))
end)

print("[BreathingSystem] Admin HUD client loaded")
print("[BreathingSystem] Test with: breathingadmin_test (admin only)")
print("[BreathingSystem] Check status with: breathingadmin_check") 