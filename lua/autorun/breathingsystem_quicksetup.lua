--[[
    BreathingSystem - Quick Setup with U,I,O,P,L Keys
    =================================================
]]

-- Auto-bind configuration for quick setup
if CLIENT then
    -- Create auto-bind command
    concommand.Add("bs_quickbind", function()
        -- Execute the binds
        RunConsoleCommand("bind", "u", "say !useform")
        RunConsoleCommand("bind", "i", "say !changeform")
        RunConsoleCommand("bind", "o", "say !water")
        RunConsoleCommand("bind", "p", "say !fire")
        RunConsoleCommand("bind", "l", "say !thunder")
        
        -- Show confirmation
        chat.AddText(Color(0, 255, 0), "[BreathingSystem] ", Color(255, 255, 255), "Quick binds set!")
        chat.AddText(Color(255, 255, 0), "  U ", Color(255, 255, 255), "- Use Form")
        chat.AddText(Color(255, 255, 0), "  I ", Color(255, 255, 255), "- Change Form")
        chat.AddText(Color(255, 255, 0), "  O ", Color(255, 255, 255), "- Water Breathing")
        chat.AddText(Color(255, 255, 0), "  P ", Color(255, 255, 255), "- Fire Breathing")
        chat.AddText(Color(255, 255, 0), "  L ", Color(255, 255, 255), "- Thunder Breathing")
    end)
    
    -- Update the bind help command
    concommand.Add("bs_setup", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("BreathingSystem - Quick Setup")
        frame:SetSize(400, 350)
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
        
        local info = vgui.Create("DLabel", panel)
        info:SetText("Click the button below to automatically set up these binds:")
        info:SetTextColor(Color(255, 255, 255))
        info:Dock(TOP)
        info:SetHeight(30)
        info:SetContentAlignment(5)
        
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
        
        -- Auto-bind button
        local bindBtn = vgui.Create("DButton", panel)
        bindBtn:SetText("APPLY THESE BINDINGS")
        bindBtn:SetTextColor(Color(255, 255, 255))
        bindBtn:Dock(BOTTOM)
        bindBtn:SetHeight(40)
        bindBtn:DockMargin(10, 10, 10, 10)
        bindBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(0, 200, 0, 255) or Color(0, 150, 0, 255)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        bindBtn.DoClick = function()
            RunConsoleCommand("bs_quickbind")
            frame:Close()
        end
        
        -- Manual bind text
        local manual = vgui.Create("DLabel", panel)
        manual:SetText("Or paste in console: bs_quickbind")
        manual:SetTextColor(Color(150, 150, 150))
        manual:Dock(BOTTOM)
        manual:SetHeight(20)
        manual:SetContentAlignment(5)
    end)
    
    -- Auto-run quick bind on first join
    hook.Add("InitPostEntity", "BreathingSystem_AutoBind", function()
        timer.Simple(15, function()
            if not file.Exists("breathingsystem_bound.txt", "DATA") then
                chat.AddText(Color(0, 255, 0), "[BreathingSystem] ", Color(255, 255, 255), "First time setup detected!")
                chat.AddText(Color(255, 255, 0), "Type ", Color(0, 255, 255), "bs_setup", Color(255, 255, 0), " in console or ", Color(0, 255, 255), "bs_quickbind", Color(255, 255, 0), " to set up keys")
                chat.AddText(Color(255, 255, 255), "Recommended keys: ", Color(255, 255, 0), "U", Color(255, 255, 255), " (use), ", Color(255, 255, 0), "I", Color(255, 255, 255), " (change), ", Color(255, 255, 0), "O,P,L", Color(255, 255, 255), " (types)")
                
                -- Mark as shown
                file.Write("breathingsystem_bound.txt", "1")
            end
        end)
    end)
end

if SERVER then
    -- Update the bind help command for server
    concommand.Add("bs_keys", function(ply, cmd, args)
        local isConsole = not IsValid(ply)
        
        local output = {
            "========================================",
            "QUICK SETUP - COPY & PASTE TO CONSOLE:",
            "========================================",
            "",
            'bind u "say !useform"',
            'bind i "say !changeform"',
            'bind o "say !water"',
            'bind p "say !fire"',
            'bind l "say !thunder"',
            "",
            "Or just run: bs_quickbind",
            "",
            "KEY LAYOUT:",
            "  U = Use Form (particles!)",
            "  I = Change Breathing Type",
            "  O = Water",
            "  P = Fire",
            "  L = Thunder (Lightning)",
            "",
            "Additional binds (optional):",
            'bind k "say !stone"',
            'bind semicolon "say !wind"',
            "========================================"
        }
        
        for _, line in ipairs(output) do
            if isConsole then
                print(line)
            else
                ply:ChatPrint(line)
            end
        end
    end)
    
    -- Welcome message with new keys
    hook.Add("PlayerInitialSpawn", "BreathingSystem_KeyInfo", function(ply)
        timer.Simple(8, function()
            if IsValid(ply) then
                ply:ChatPrint("========================================")
                ply:ChatPrint("[BreathingSystem] Quick Setup Available!")
                ply:ChatPrint("Run 'bs_quickbind' to set up these keys:")
                ply:ChatPrint("  U - Use Form")
                ply:ChatPrint("  I - Change Type")
                ply:ChatPrint("  O - Water | P - Fire | L - Thunder")
                ply:ChatPrint("========================================")
            end
        end)
    end)
end

print("[BreathingSystem] Quick setup ready!")
print("  Commands:")
print("    bs_quickbind - Auto-bind U,I,O,P,L keys")
print("    bs_setup - Open setup menu (client)")
print("    bs_keys - Show key binding commands")
