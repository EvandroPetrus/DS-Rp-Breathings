--[[
    BreathingSystem - Simple HUD
    ============================
    
    Displays breathing system info on screen.
]]

-- Client-side only
if not CLIENT then return end

-- HUD Configuration
local HUD_CONFIG = {
    enabled = true,
    position = {x = 20, y = ScrH() - 200},
    colors = {
        background = Color(0, 0, 0, 150),
        text = Color(255, 255, 255, 255),
        water = Color(0, 150, 255, 255),
        fire = Color(255, 100, 0, 255),
        thunder = Color(255, 255, 0, 255),
        stone = Color(128, 128, 128, 255),
        wind = Color(200, 200, 255, 255),
        none = Color(100, 100, 100, 255)
    }
}

-- Get breathing color
local function GetBreathingColor(breathingType)
    return HUD_CONFIG.colors[breathingType] or HUD_CONFIG.colors.none
end

-- Draw the HUD
hook.Add("HUDPaint", "BreathingSystem_HUD", function()
    if not HUD_CONFIG.enabled then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Get player data (simplified for client)
    local breathingType = ply:GetNWString("BreathingType", "none")
    local level = ply:GetNWInt("BreathingLevel", 1)
    local stamina = ply:GetNWInt("BreathingStamina", 100)
    local maxStamina = ply:GetNWInt("BreathingMaxStamina", 100)
    
    -- Position
    local x, y = HUD_CONFIG.position.x, HUD_CONFIG.position.y
    
    -- Draw background
    draw.RoundedBox(8, x, y, 250, 120, HUD_CONFIG.colors.background)
    
    -- Draw title
    draw.SimpleText("BREATHING SYSTEM", "DermaLarge", x + 125, y + 10, HUD_CONFIG.colors.text, TEXT_ALIGN_CENTER)
    
    -- Draw breathing type
    local typeColor = GetBreathingColor(breathingType)
    local typeText = breathingType:upper()
    if breathingType == "none" then
        typeText = "NO BREATHING TYPE"
    end
    draw.SimpleText(typeText, "DermaDefault", x + 125, y + 35, typeColor, TEXT_ALIGN_CENTER)
    
    -- Draw level
    draw.SimpleText("Level: " .. level, "DermaDefault", x + 10, y + 55, HUD_CONFIG.colors.text)
    
    -- Draw stamina bar
    draw.SimpleText("Stamina:", "DermaDefault", x + 10, y + 75, HUD_CONFIG.colors.text)
    
    -- Stamina bar background
    draw.RoundedBox(4, x + 70, y + 75, 170, 16, Color(50, 50, 50, 200))
    
    -- Stamina bar fill
    local staminaPercent = stamina / maxStamina
    local barColor = Color(0, 255, 0, 255)
    if staminaPercent < 0.3 then
        barColor = Color(255, 0, 0, 255)
    elseif staminaPercent < 0.6 then
        barColor = Color(255, 255, 0, 255)
    end
    draw.RoundedBox(4, x + 70, y + 75, 170 * staminaPercent, 16, barColor)
    
    -- Draw stamina text
    draw.SimpleText(stamina .. "/" .. maxStamina, "DermaDefault", x + 155, y + 75, HUD_CONFIG.colors.text, TEXT_ALIGN_CENTER)
    
    -- Draw help text
    draw.SimpleText("Press F9 for menu | Type !bs for help", "DermaDefault", x + 125, y + 100, Color(200, 200, 200, 150), TEXT_ALIGN_CENTER)
end)

-- Toggle HUD command
concommand.Add("breathingsystem_hud_toggle", function()
    HUD_CONFIG.enabled = not HUD_CONFIG.enabled
    local status = HUD_CONFIG.enabled and "enabled" or "disabled"
    chat.AddText(Color(0, 150, 255), "[BreathingSystem] ", Color(255, 255, 255), "HUD " .. status)
end)

print("[BreathingSystem] HUD loaded (client)")
