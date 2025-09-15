--[[
    BreathingSystem - Chat Commands for Forms
    ==========================================
    Uses chat commands instead of hardcoded keys for flexibility
]]

if SERVER then
    -- Chat command handler for breathing system
    hook.Add("PlayerSay", "BreathingSystem_FormCommands", function(ply, text, team)
        local lower = string.lower(text)
        
        -- Use form command
        if lower == "!useform" or lower == "!use" then
            -- Use default form (1)
            ply:ConCommand("bs_use_form 1")
            return "" -- Hide the command from chat
            
        elseif string.sub(lower, 1, 9) == "!useform " then
            -- Use specific form number
            local formNum = string.sub(text, 10)
            ply:ConCommand("bs_use_form " .. formNum)
            return ""
            
        -- Change breathing type command
        elseif lower == "!changeform" or lower == "!change" or lower == "!switch" then
            -- Cycle to next type
            ply:ConCommand("bs_switch")
            return ""
            
        elseif string.sub(lower, 1, 12) == "!changeform " then
            -- Change to specific type
            local breathingType = string.sub(text, 13)
            ply:ConCommand("bs_switch " .. breathingType)
            return ""
            
        -- Quick type switches
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
            
        -- Help command
        elseif lower == "!forms" or lower == "!formhelp" then
            ply:ChatPrint("========================================")
            ply:ChatPrint("BREATHING FORMS COMMANDS")
            ply:ChatPrint("========================================")
            ply:ChatPrint("!useform [1-5] - Use a breathing form")
            ply:ChatPrint("!changeform [type] - Change breathing type")
            ply:ChatPrint("!water - Switch to Water breathing")
            ply:ChatPrint("!fire - Switch to Fire breathing")
            ply:ChatPrint("!thunder - Switch to Thunder breathing")
            ply:ChatPrint("!stone - Switch to Stone breathing")
            ply:ChatPrint("!wind - Switch to Wind breathing")
            ply:ChatPrint("")
            ply:ChatPrint("Short versions:")
            ply:ChatPrint("!use - Use form 1")
            ply:ChatPrint("!change - Cycle breathing type")
            ply:ChatPrint("========================================")
            return ""
        end
    end)
    
    -- Console commands for binding
    concommand.Add("breathing_use", function(ply, cmd, args)
        if not IsValid(ply) then return end
        local formNum = args[1] or "1"
        ply:ConCommand("bs_use_form " .. formNum)
    end)
    
    concommand.Add("breathing_switch", function(ply, cmd, args)
        if not IsValid(ply) then return end
        local breathingType = args[1] or ""
        ply:ConCommand("bs_switch " .. breathingType)
    end)
    
    -- Bind helper commands
    concommand.Add("bs_bind_help", function(ply, cmd, args)
        if not IsValid(ply) then
            print("========================================")
            print("BINDING GUIDE")
            print("========================================")
            print("To bind keys, use these commands in console:")
            print("")
            print('bind g "say !useform"')
            print('bind h "say !changeform"')
            print("")
            print("Or use console commands:")
            print('bind g "breathing_use"')
            print('bind h "breathing_switch"')
            print("")
            print("Custom binds:")
            print('bind mouse3 "say !useform 1"')
            print('bind mouse4 "say !changeform"')
            print('bind f "say !fire"')
            print('bind v "say !water"')
            print("========================================")
        else
            ply:ChatPrint("========================================")
            ply:ChatPrint("BINDING GUIDE")
            ply:ChatPrint("========================================")
            ply:ChatPrint("Open console and type:")
            ply:ChatPrint("")
            ply:ChatPrint('bind g "say !useform"')
            ply:ChatPrint('bind h "say !changeform"')
            ply:ChatPrint("")
            ply:ChatPrint("Or for mouse buttons:")
            ply:ChatPrint('bind mouse3 "say !useform"')
            ply:ChatPrint('bind mouse4 "say !changeform"')
            ply:ChatPrint("")
            ply:ChatPrint("Quick type binds:")
            ply:ChatPrint('bind 1 "say !water"')
            ply:ChatPrint('bind 2 "say !fire"')
            ply:ChatPrint('bind 3 "say !thunder"')
            ply:ChatPrint('bind 4 "say !stone"')
            ply:ChatPrint('bind 5 "say !wind"')
            ply:ChatPrint("========================================")
        end
    end)
    
    print("[BreathingSystem] Chat commands loaded")
    print("  Commands:")
    print("    !useform [1-5] - Use breathing form")
    print("    !changeform [type] - Change breathing type")
    print("    !forms - Show help")
    print("")
    print("  For key bindings, run: bs_bind_help")
end

-- Remove the old hardcoded key bindings on client
if CLIENT then
    -- Remove old hooks if they exist
    hook.Remove("PlayerButtonDown", "BreathingSystem_FormKey")
    hook.Remove("PlayerButtonDown", "BreathingSystem_StaminaKeys")
    
    -- Add startup message
    hook.Add("InitPostEntity", "BreathingSystem_BindMessage", function()
        timer.Simple(10, function()
            chat.AddText(Color(0, 150, 255), "[BreathingSystem] ", Color(255, 255, 255), "Type ", Color(255, 255, 0), "!forms", Color(255, 255, 255), " for commands or ", Color(255, 255, 0), "bs_bind_help", Color(255, 255, 255), " in console for binding guide")
        end)
    end)
    
    -- Create quick bind menu
    concommand.Add("bs_bind_menu", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("BreathingSystem - Key Binding Guide")
        frame:SetSize(500, 600)
        frame:Center()
        frame:MakePopup()
        
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        
        local text = vgui.Create("RichText", scroll)
        text:Dock(FILL)
        text:SetVerticalScrollbarEnabled(false)
        
        text:InsertColorChange(0, 150, 255, 255)
        text:AppendText("BREATHING SYSTEM KEY BINDING GUIDE\n\n")
        
        text:InsertColorChange(255, 255, 255, 255)
        text:AppendText("Copy and paste these commands into your console:\n\n")
        
        text:InsertColorChange(255, 255, 0, 255)
        text:AppendText("RECOMMENDED BINDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText('bind g "say !useform"\n')
        text:AppendText('bind h "say !changeform"\n\n')
        
        text:InsertColorChange(255, 255, 0, 255)
        text:AppendText("MOUSE BINDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText('bind mouse3 "say !useform"\n')
        text:AppendText('bind mouse4 "say !changeform"\n')
        text:AppendText('bind mouse5 "say !useform 2"\n\n')
        
        text:InsertColorChange(255, 255, 0, 255)
        text:AppendText("NUMBER KEY BINDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText('bind 1 "say !water"\n')
        text:AppendText('bind 2 "say !fire"\n')
        text:AppendText('bind 3 "say !thunder"\n')
        text:AppendText('bind 4 "say !stone"\n')
        text:AppendText('bind 5 "say !wind"\n\n')
        
        text:InsertColorChange(255, 255, 0, 255)
        text:AppendText("FUNCTION KEY BINDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText('bind f1 "say !useform 1"\n')
        text:AppendText('bind f2 "say !useform 2"\n')
        text:AppendText('bind f3 "say !useform 3"\n')
        text:AppendText('bind f4 "say !useform 4"\n')
        text:AppendText('bind f5 "say !useform 5"\n\n')
        
        text:InsertColorChange(255, 255, 0, 255)
        text:AppendText("CUSTOM BINDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText('bind shift "say !useform"\n')
        text:AppendText('bind alt "say !changeform"\n')
        text:AppendText('bind q "say !useform 1"\n')
        text:AppendText('bind e "say !changeform"\n\n')
        
        text:InsertColorChange(0, 255, 0, 255)
        text:AppendText("CHAT COMMANDS:\n")
        text:InsertColorChange(200, 200, 200, 255)
        text:AppendText("!useform [1-5] - Use a form\n")
        text:AppendText("!changeform [type] - Change type\n")
        text:AppendText("!water, !fire, !thunder, !stone, !wind\n")
        text:AppendText("!forms - Show help\n")
        
        local copyBtn = vgui.Create("DButton", frame)
        copyBtn:SetText("Copy Example Binds to Clipboard")
        copyBtn:Dock(BOTTOM)
        copyBtn:SetHeight(30)
        copyBtn:DoClick = function()
            local binds = 'bind g "say !useform"\nbind h "say !changeform"\nbind mouse3 "say !useform 1"\nbind mouse4 "say !changeform"'
            SetClipboardText(binds)
            chat.AddText(Color(0, 255, 0), "[BreathingSystem] Binds copied to clipboard!")
        end
    end)
    
    print("[BreathingSystem] Chat commands ready")
    print("  Type !forms in chat for help")
    print("  Run bs_bind_help for binding guide")
    print("  Run bs_bind_menu for visual binding menu")
end
