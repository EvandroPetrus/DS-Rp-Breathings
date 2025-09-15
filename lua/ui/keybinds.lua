--[[
    BreathingSystem - Keybinds System
    ================================
    
    This module handles customizable controls for the breathing system.
    Allows players to bind keys to different breathing functions.
    
    Responsibilities:
    - Manage keybind configurations
    - Handle key press events
    - Provide keybind API functions
    - Save and load keybind preferences
    
    Public API:
    - BreathingSystem.Keybinds.SetKeybind(ply, action, key) - Set keybind
    - BreathingSystem.Keybinds.GetKeybind(ply, action) - Get keybind
    - BreathingSystem.Keybinds.HandleKeyPress(ply, key) - Handle key press
    - BreathingSystem.Keybinds.GetAllKeybinds(ply) - Get all keybinds
]]

-- Initialize keybinds module
BreathingSystem.Keybinds = BreathingSystem.Keybinds or {}

-- Keybinds configuration
BreathingSystem.Keybinds.Config = {
    -- Default keybinds
    default_keybinds = {
        ["breathing_menu"] = KEY_F1,
        ["forms_menu"] = KEY_F2,
        ["training_menu"] = KEY_F3,
        ["progression_menu"] = KEY_F4,
        ["total_concentration"] = KEY_F5,
        ["use_form_1"] = KEY_1,
        ["use_form_2"] = KEY_2,
        ["use_form_3"] = KEY_3,
        ["use_form_4"] = KEY_4,
        ["use_form_5"] = KEY_5,
        ["use_form_6"] = KEY_6,
        ["use_form_7"] = KEY_7,
        ["use_form_8"] = KEY_8,
        ["use_form_9"] = KEY_9,
        ["use_form_0"] = KEY_0,
        ["toggle_breathing"] = KEY_B,
        ["toggle_hud"] = KEY_H
    },
    
    -- Available actions
    actions = {
        "breathing_menu",
        "forms_menu",
        "training_menu",
        "progression_menu",
        "total_concentration",
        "use_form_1",
        "use_form_2",
        "use_form_3",
        "use_form_4",
        "use_form_5",
        "use_form_6",
        "use_form_7",
        "use_form_8",
        "use_form_9",
        "use_form_0",
        "toggle_breathing",
        "toggle_hud"
    },
    
    -- Key names for display
    key_names = {
        [KEY_1] = "1",
        [KEY_2] = "2",
        [KEY_3] = "3",
        [KEY_4] = "4",
        [KEY_5] = "5",
        [KEY_6] = "6",
        [KEY_7] = "7",
        [KEY_8] = "8",
        [KEY_9] = "9",
        [KEY_0] = "0",
        [KEY_F1] = "F1",
        [KEY_F2] = "F2",
        [KEY_F3] = "F3",
        [KEY_F4] = "F4",
        [KEY_F5] = "F5",
        [KEY_F6] = "F6",
        [KEY_F7] = "F7",
        [KEY_F8] = "F8",
        [KEY_F9] = "F9",
        [KEY_F10] = "F10",
        [KEY_F11] = "F11",
        [KEY_F12] = "F12",
        [KEY_B] = "B",
        [KEY_H] = "H",
        [KEY_TAB] = "TAB",
        [KEY_ENTER] = "ENTER",
        [KEY_SPACE] = "SPACE",
        [KEY_ESCAPE] = "ESC"
    }
}

-- Player keybinds
BreathingSystem.Keybinds.PlayerKeybinds = BreathingSystem.Keybinds.PlayerKeybinds or {}

-- Set keybind for player
function BreathingSystem.Keybinds.SetKeybind(ply, action, key)
    if not IsValid(ply) or not action or not key then return false end
    
    -- Check if action is valid
    if not table.HasValue(BreathingSystem.Keybinds.Config.actions, action) then
        return false
    end
    
    -- Get player keybinds
    local steamid = ply:SteamID()
    if not BreathingSystem.Keybinds.PlayerKeybinds[steamid] then
        BreathingSystem.Keybinds.PlayerKeybinds[steamid] = {}
    end
    
    -- Set keybind
    BreathingSystem.Keybinds.PlayerKeybinds[steamid][action] = key
    
    print("[BreathingSystem.Keybinds] Set keybind for " .. ply:Name() .. ": " .. action .. " -> " .. key)
    
    return true
end

-- Get keybind for player
function BreathingSystem.Keybinds.GetKeybind(ply, action)
    if not IsValid(ply) or not action then return nil end
    
    local steamid = ply:SteamID()
    local playerKeybinds = BreathingSystem.Keybinds.PlayerKeybinds[steamid]
    
    if playerKeybinds and playerKeybinds[action] then
        return playerKeybinds[action]
    end
    
    -- Return default keybind
    return BreathingSystem.Keybinds.Config.default_keybinds[action]
end

-- Get all keybinds for player
function BreathingSystem.Keybinds.GetAllKeybinds(ply)
    if not IsValid(ply) then return {} end
    
    local steamid = ply:SteamID()
    local playerKeybinds = BreathingSystem.Keybinds.PlayerKeybinds[steamid] or {}
    local allKeybinds = {}
    
    for _, action in ipairs(BreathingSystem.Keybinds.Config.actions) do
        local key = playerKeybinds[action] or BreathingSystem.Keybinds.Config.default_keybinds[action]
        local keyName = BreathingSystem.Keybinds.Config.key_names[key] or "Unknown"
        
        allKeybinds[action] = {
            key = key,
            keyName = keyName
        }
    end
    
    return allKeybinds
end

-- Handle key press
function BreathingSystem.Keybinds.HandleKeyPress(ply, key)
    if not IsValid(ply) or not key then return false end
    
    local steamid = ply:SteamID()
    local playerKeybinds = BreathingSystem.Keybinds.PlayerKeybinds[steamid]
    
    -- Find action for this key
    local action = nil
    if playerKeybinds then
        for actionName, actionKey in pairs(playerKeybinds) do
            if actionKey == key then
                action = actionName
                break
            end
        end
    end
    
    -- Check default keybinds if not found
    if not action then
        for actionName, actionKey in pairs(BreathingSystem.Keybinds.Config.default_keybinds) do
            if actionKey == key then
                action = actionName
                break
            end
        end
    end
    
    if not action then return false end
    
    -- Execute action
    return BreathingSystem.Keybinds.ExecuteAction(ply, action)
end

-- Execute keybind action
function BreathingSystem.Keybinds.ExecuteAction(ply, action)
    if not IsValid(ply) or not action then return false end
    
    if action == "breathing_menu" then
        return BreathingSystem.Menus.ShowBreathingMenu(ply)
    elseif action == "forms_menu" then
        return BreathingSystem.Menus.ShowFormsMenu(ply)
    elseif action == "training_menu" then
        return BreathingSystem.Menus.ShowTrainingMenu(ply)
    elseif action == "progression_menu" then
        return BreathingSystem.Menus.ShowProgressionMenu(ply)
    elseif action == "total_concentration" then
        return BreathingSystem.Concentration.EnterTotalConcentration(ply)
    elseif action == "toggle_breathing" then
        local data = BreathingSystem.GetPlayerData(ply)
        if data and data.is_breathing then
            BreathingSystem.StopPlayerBreathing(ply)
            ply:ChatPrint("[BreathingSystem] Stopped breathing")
        else
            BreathingSystem.SetPlayerBreathing(ply, data.current_breathing_type or "normal")
            ply:ChatPrint("[BreathingSystem] Started breathing")
        end
        return true
    elseif action == "toggle_hud" then
        local data = BreathingSystem.GetPlayerData(ply)
        if data then
            data.hud_enabled = not (data.hud_enabled or true)
            if data.hud_enabled then
                BreathingSystem.HUD.ShowHUD(ply)
                ply:ChatPrint("[BreathingSystem] HUD enabled")
            else
                BreathingSystem.HUD.HideHUD(ply)
                ply:ChatPrint("[BreathingSystem] HUD disabled")
            end
        end
        return true
    elseif string.find(action, "use_form_") then
        local formNumber = string.match(action, "use_form_(%d+)")
        if formNumber then
            local formIndex = tonumber(formNumber)
            if formIndex then
                return BreathingSystem.Keybinds.UseFormByIndex(ply, formIndex)
            end
        end
    end
    
    return false
end

-- Use form by index
function BreathingSystem.Keybinds.UseFormByIndex(ply, index)
    if not IsValid(ply) or not index then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local breathingType = data.current_breathing_type or "normal"
    local forms = {}
    
    -- Get forms for current breathing type
    for formID, form in pairs(BreathingSystem.Forms.GetAll()) do
        if string.find(formID, breathingType) then
            table.insert(forms, formID)
        end
    end
    
    -- Sort forms by difficulty
    table.sort(forms, function(a, b)
        local formA = BreathingSystem.Forms.GetForm(a)
        local formB = BreathingSystem.Forms.GetForm(b)
        return (formA.difficulty or 1) < (formB.difficulty or 1)
    end)
    
    -- Get form at index
    local formID = forms[index]
    if not formID then return false end
    
    -- Check if form can be used
    if not BreathingSystem.Prerequisites.CanUseForm(ply, formID) then
        ply:ChatPrint("[BreathingSystem] Cannot use this form!")
        return false
    end
    
    if not BreathingSystem.Cooldowns.CanUseForm(ply, formID) then
        local cooldownTime = BreathingSystem.Cooldowns.GetCooldownTime(ply, formID)
        ply:ChatPrint("[BreathingSystem] Form is on cooldown for " .. math.ceil(cooldownTime) .. " seconds!")
        return false
    end
    
    -- Use form
    ply:ChatPrint("[BreathingSystem] Using form: " .. formID)
    return true
end

-- Reset keybinds to default
function BreathingSystem.Keybinds.ResetKeybinds(ply)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    BreathingSystem.Keybinds.PlayerKeybinds[steamid] = {}
    
    print("[BreathingSystem.Keybinds] Reset keybinds for " .. ply:Name())
    
    return true
end

-- Get key name
function BreathingSystem.Keybinds.GetKeyName(key)
    return BreathingSystem.Keybinds.Config.key_names[key] or "Unknown"
end

-- Initialize keybinds system
if SERVER then
    -- Network messages
    util.AddNetworkString("BreathingSystem_KeybindUpdate")
    util.AddNetworkString("BreathingSystem_KeybindRequest")
    
    -- Handle keybind requests
    net.Receive("BreathingSystem_KeybindRequest", function(len, ply)
        local action = net.ReadString()
        local key = net.ReadUInt(8)
        
        BreathingSystem.Keybinds.SetKeybind(ply, action, key)
    end)
    
    print("[BreathingSystem.Keybinds] Keybinds system loaded")
end
