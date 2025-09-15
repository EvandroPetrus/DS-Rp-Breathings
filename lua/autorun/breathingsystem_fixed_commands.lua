--[[
    BreathingSystem - Fixed Quick Setup
    ====================================
]]

-- Fixed version that uses LocalPlayer() instead of RunConsoleCommand for binds
if CLIENT then
    -- Create auto-bind command that works
    concommand.Add("bs_quickbind", function()
        -- Use LocalPlayer():ConCommand instead of RunConsoleCommand
        LocalPlayer():ConCommand('bind u "say !useform"')
        LocalPlayer():ConCommand('bind i "say !changeform"')
        LocalPlayer():ConCommand('bind o "say !water"')
        LocalPlayer():ConCommand('bind p "say !fire"')
        LocalPlayer():ConCommand('bind l "say !thunder"')
        
        -- Show confirmation
        chat.AddText(Color(0, 255, 0), "[BreathingSystem] ", Color(255, 255, 255), "Quick binds set!")
        chat.AddText(Color(255, 255, 0), "  U ", Color(255, 255, 255), "- Use Form")
        chat.AddText(Color(255, 255, 0), "  I ", Color(255, 255, 255), "- Change Form")
        chat.AddText(Color(255, 255, 0), "  O ", Color(255, 255, 255), "- Water Breathing")
        chat.AddText(Color(255, 255, 0), "  P ", Color(255, 255, 255), "- Fire Breathing")
        chat.AddText(Color(255, 255, 0), "  L ", Color(255, 255, 255), "- Thunder Breathing")
        
        -- Alternative: Show commands to copy
        print("========================================")
        print("If binds didn't work, copy these to console:")
        print('bind u "say !useform"')
        print('bind i "say !changeform"')
        print('bind o "say !water"')
        print('bind p "say !fire"')
        print('bind l "say !thunder"')
        print("========================================")
    end)
    
    -- Manual bind command that shows text to copy
    concommand.Add("bs_binds", function()
        local binds = {
            'bind u "say !useform"',
            'bind i "say !changeform"',
            'bind o "say !water"',
            'bind p "say !fire"',
            'bind l "say !thunder"'
        }
        
        -- Copy to clipboard
        SetClipboardText(table.concat(binds, "\n"))
        
        chat.AddText(Color(0, 255, 0), "[BreathingSystem] ", Color(255, 255, 255), "Bind commands copied to clipboard!")
        chat.AddText(Color(255, 255, 0), "Paste them in console to set up keys")
        
        print("========================================")
        print("PASTE THESE IN CONSOLE:")
        print("========================================")
        for _, bind in ipairs(binds) do
            print(bind)
        end
        print("========================================")
    end)
    
    -- Visual setup menu
    concommand.Add("bs_setup", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("BreathingSystem - Quick Setup")
        frame:SetSize(500, 450)
        frame:Center()
        frame:MakePopup()
        
        local panel = vgui.Create("DPanel", frame)
        panel:Dock(FILL)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 255))
        end
        
        local title = vgui.Create("DLabel", panel)
        title:SetText("RECOMMENDED KEY BINDINGS")
        title:SetFont("DermaLarge")
        title:SetTextColor(Color(0, 150, 255))
        title:Dock(TOP)
        title:SetHeight(40)
        title:SetContentAlignment(5)
        
        -- Key display
        local keys = {
            {"U", "Use Breathing Form", Color(0, 255, 0)},
            {"I", "Change Breathing Type", Color(255, 255, 0)},
            {"O", "Switch to Water", Color(0, 150, 255)},
            {"P", "Switch to Fire", Color(255, 100, 0)},
            {"L", "Switch to Thunder", Color(255, 255, 0)}
        }
        
        for _, keyData in ipairs(keys) do
            local keyPanel = vgui.Create("DPanel", panel)
            keyPanel:Dock(TOP)
            keyPanel:SetHeight(35)
            keyPanel:DockMargin(10, 5, 10, 0)
            keyPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 255))
            end
            
            local keyLabel = vgui.Create("DLabel", keyPanel)
            keyLabel:SetText(keyData[1])
            keyLabel:SetFont("DermaLarge")
            keyLabel:SetTextColor(keyData[3])
            keyLabel:Dock(LEFT)
            keyLabel:SetWidth(50)
            keyLabel:SetContentAlignment(5)
            
            local descLabel = vgui.Create("DLabel", keyPanel)
            descLabel:SetText(keyData[2])
            descLabel:SetTextColor(Color(255, 255, 255))
            descLabel:Dock(FILL)
            descLabel:DockMargin(10, 0, 0, 0)
            descLabel:SetContentAlignment(4)
        end
        
        -- Instructions
        local instPanel = vgui.Create("DPanel", panel)
        instPanel:Dock(TOP)
        instPanel:SetHeight(80)
        instPanel:DockMargin(10, 10, 10, 0)
        instPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
        end
        
        local instText = vgui.Create("DLabel", instPanel)
        instText:SetText("COPY THESE COMMANDS TO CONSOLE:\n" ..
                         'bind u "say !useform"\n' ..
                         'bind i "say !changeform"\n' ..
                         'bind o "say !water"   bind p "say !fire"   bind l "say !thunder"')
        instText:SetTextColor(Color(255, 255, 255))
        instText:SetFont("DermaDefault")
        instText:Dock(FILL)
        instText:DockMargin(10, 5, 10, 5)
        instText:SetContentAlignment(5)
        instText:SetWrap(true)
        
        -- Copy button
        local copyBtn = vgui.Create("DButton", panel)
        copyBtn:SetText("COPY BIND COMMANDS TO CLIPBOARD")
        copyBtn:SetTextColor(Color(255, 255, 255))
        copyBtn:Dock(BOTTOM)
        copyBtn:SetHeight(40)
        copyBtn:DockMargin(10, 10, 10, 10)
        copyBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(0, 200, 0, 255) or Color(0, 150, 0, 255)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        copyBtn.DoClick = function()
            local binds = 'bind u "say !useform"\nbind i "say !changeform"\nbind o "say !water"\nbind p "say !fire"\nbind l "say !thunder"'
            SetClipboardText(binds)
            chat.AddText(Color(0, 255, 0), "[BreathingSystem] ", Color(255, 255, 255), "Binds copied! Paste in console")
            frame:Close()
        end
    end)
end

if SERVER then
    -- Chat command handler remains the same
    hook.Add("PlayerSay", "BreathingSystem_FormCommands", function(ply, text, team)
        local lower = string.lower(text)
        
        if lower == "!useform" or lower == "!use" then
            ply:ConCommand("bs_use_form 1")
            return ""
        elseif string.sub(lower, 1, 9) == "!useform " then
            local formNum = string.sub(text, 10)
            ply:ConCommand("bs_use_form " .. formNum)
            return ""
        elseif lower == "!changeform" or lower == "!change" or lower == "!switch" then
            ply:ConCommand("bs_switch")
            return ""
        elseif string.sub(lower, 1, 12) == "!changeform " then
            local breathingType = string.sub(text, 13)
            ply:ConCommand("bs_switch " .. breathingType)
            return ""
        elseif lower == "!water" then
            ply:ConCommand("bs_switch water")
            return ""
        elseif lower == "!fire" then
            ply:ConCommand("bs_switch fire")
            return ""
        elseif lower == "!thunder" then
            ply:ConCommand("bs_switch thunder")
            return ""
        elseif lower == "!stone" then
            ply:ConCommand("bs_switch stone")
            return ""
        elseif lower == "!wind" then
            ply:ConCommand("bs_switch wind")
            return ""
        elseif lower == "!forms" or lower == "!formhelp" then
            ply:ChatPrint("========================================")
            ply:ChatPrint("BREATHING FORMS COMMANDS")
            ply:ChatPrint("========================================")
            ply:ChatPrint("!useform - Use breathing form")
            ply:ChatPrint("!changeform - Change breathing type")
            ply:ChatPrint("!water, !fire, !thunder, !stone, !wind")
            ply:ChatPrint("")
            ply:ChatPrint("TO BIND KEYS: Type bs_setup in console")
            ply:ChatPrint("========================================")
            return ""
        end
    end)
end

print("[BreathingSystem] Fixed chat commands loaded")
print("  bs_quickbind - Try to auto-bind keys")
print("  bs_binds - Copy bind commands to clipboard")
print("  bs_setup - Visual setup menu")
