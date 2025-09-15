--[[
    BreathingSystem - Menus System
    =============================
    
    This module handles menus for breathing selection and unlocked forms.
    Provides interactive menus for players to manage their breathing system.
    
    Responsibilities:
    - Display breathing type selection menu
    - Show unlocked forms menu
    - Handle form selection and activation
    - Provide training menu
    - Display progression information
    
    Public API:
    - BreathingSystem.Menus.ShowBreathingMenu(ply) - Show breathing selection menu
    - BreathingSystem.Menus.ShowFormsMenu(ply) - Show forms menu
    - BreathingSystem.Menus.ShowTrainingMenu(ply) - Show training menu
    - BreathingSystem.Menus.ShowProgressionMenu(ply) - Show progression menu
]]

-- Initialize menus module
BreathingSystem.Menus = BreathingSystem.Menus or {}

-- Menu configuration
BreathingSystem.Menus.Config = {
    -- Menu dimensions
    width = 800,
    height = 600,
    
    -- Colors
    colors = {
        background = Color(0, 0, 0, 200),
        header = Color(50, 50, 50, 255),
        button = Color(100, 100, 100, 255),
        button_hover = Color(150, 150, 150, 255),
        text = Color(255, 255, 255, 255),
        text_secondary = Color(200, 200, 200, 255),
        success = Color(0, 255, 0, 255),
        warning = Color(255, 255, 0, 255),
        error = Color(255, 0, 0, 255)
    },
    
    -- Menu types
    menu_types = {
        "breathing_selection",
        "forms",
        "training",
        "progression",
        "settings"
    }
}

-- Show breathing selection menu
function BreathingSystem.Menus.ShowBreathingMenu(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local menuData = {
        type = "breathing_selection",
        title = "Breathing Type Selection",
        currentType = data.current_breathing_type or "normal",
        breathingTypes = {}
    }
    
    -- Get available breathing types
    for typeID, typeData in pairs(BreathingSystem.Config.BreathingTypes) do
        local canUse = true
        local reason = ""
        
        -- Check if player can use this breathing type
        if typeID != "normal" then
            local level = BreathingSystem.Training.GetLevel(ply)
            if level < 5 then
                canUse = false
                reason = "Level 5 required"
            end
        end
        
        table.insert(menuData.breathingTypes, {
            id = typeID,
            name = typeData.name or "Unknown",
            description = typeData.description or "No description",
            canUse = canUse,
            reason = reason,
            color = typeData.color or Color(255, 255, 255)
        })
    end
    
    -- Send menu data to client
    net.Start("BreathingSystem_MenuData")
    net.WriteTable(menuData)
    net.Send(ply)
    
    return true
end

-- Show forms menu
function BreathingSystem.Menus.ShowFormsMenu(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local menuData = {
        type = "forms",
        title = "Breathing Forms",
        currentType = data.current_breathing_type or "normal",
        forms = {}
    }
    
    -- Get forms for current breathing type
    local breathingType = data.current_breathing_type or "normal"
    for formID, form in pairs(BreathingSystem.Forms.GetAll()) do
        if string.find(formID, breathingType) then
            local canUse = BreathingSystem.Prerequisites.CanUseForm(ply, formID)
            local isUnlocked = BreathingSystem.Unlocks.IsFormUnlocked(ply, formID)
            local cooldownInfo = BreathingSystem.Cooldowns.GetCooldownInfo(ply, formID)
            
            table.insert(menuData.forms, {
                id = formID,
                name = form.name or "Unknown",
                description = form.description or "No description",
                difficulty = form.difficulty or 1,
                canUse = canUse,
                isUnlocked = isUnlocked,
                cooldownInfo = cooldownInfo,
                requirements = form.requirements or {}
            })
        end
    end
    
    -- Send menu data to client
    net.Start("BreathingSystem_MenuData")
    net.WriteTable(menuData)
    net.Send(ply)
    
    return true
end

-- Show training menu
function BreathingSystem.Menus.ShowTrainingMenu(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local menuData = {
        type = "training",
        title = "Training Menu",
        playerData = {
            level = BreathingSystem.Training.GetLevel(ply),
            xp = BreathingSystem.Training.GetXP(ply),
            xpProgress = BreathingSystem.Training.GetXPProgress(ply),
            trainingSessions = data.training_sessions or 0
        },
        trainingStatus = BreathingSystem.Training.GetTrainingStatus(ply),
        availableTeachers = {},
        availableStudents = {}
    }
    
    -- Get available teachers
    for _, teacher in pairs(player.GetAll()) do
        if IsValid(teacher) and teacher != ply then
            local teacherData = BreathingSystem.GetPlayerData(teacher)
            if teacherData and teacherData.level and teacherData.level > BreathingSystem.Training.GetLevel(ply) then
                table.insert(menuData.availableTeachers, {
                    name = teacher:Name(),
                    level = teacherData.level,
                    breathingType = teacherData.current_breathing_type or "normal"
                })
            end
        end
    end
    
    -- Get available students
    for _, student in pairs(player.GetAll()) do
        if IsValid(student) and student != ply then
            local studentData = BreathingSystem.GetPlayerData(student)
            if studentData and studentData.level and studentData.level < BreathingSystem.Training.GetLevel(ply) then
                table.insert(menuData.availableStudents, {
                    name = student:Name(),
                    level = studentData.level,
                    breathingType = studentData.current_breathing_type or "normal"
                })
            end
        end
    end
    
    -- Send menu data to client
    net.Start("BreathingSystem_MenuData")
    net.WriteTable(menuData)
    net.Send(ply)
    
    return true
end

-- Show progression menu
function BreathingSystem.Menus.ShowProgressionMenu(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local menuData = {
        type = "progression",
        title = "Progression Menu",
        playerData = {
            level = BreathingSystem.Training.GetLevel(ply),
            xp = BreathingSystem.Training.GetXP(ply),
            xpProgress = BreathingSystem.Training.GetXPProgress(ply),
            unlockedForms = BreathingSystem.Unlocks.GetUnlockedForms(ply),
            breathingTypeMastery = data.breathing_type_mastery or {}
        },
        achievements = data.achievements or {},
        statistics = {
            totalDamageDealt = data.total_damage_dealt or 0,
            totalDamageTaken = data.total_damage_taken or 0,
            kills = data.kills or 0,
            deaths = data.deaths or 0,
            trainingSessions = data.training_sessions or 0
        }
    }
    
    -- Send menu data to client
    net.Start("BreathingSystem_MenuData")
    net.WriteTable(menuData)
    net.Send(ply)
    
    return true
end

-- Handle menu action
function BreathingSystem.Menus.HandleMenuAction(ply, action, data)
    if not IsValid(ply) or not action then return false end
    
    if action == "select_breathing_type" then
        local breathingType = data.breathingType
        if breathingType and BreathingSystem.Config.BreathingTypes[breathingType] then
            BreathingSystem.SetPlayerBreathing(ply, breathingType)
            ply:ChatPrint("[BreathingSystem] Breathing type changed to: " .. breathingType)
            return true
        end
    elseif action == "use_form" then
        local formID = data.formID
        if formID and BreathingSystem.Forms.GetForm(formID) then
            -- Check if form can be used
            if BreathingSystem.Prerequisites.CanUseForm(ply, formID) then
                if BreathingSystem.Cooldowns.CanUseForm(ply, formID) then
                    -- Use form (this would trigger the form activation)
                    ply:ChatPrint("[BreathingSystem] Using form: " .. formID)
                    return true
                else
                    ply:ChatPrint("[BreathingSystem] Form is on cooldown!")
                    return false
                end
            else
                ply:ChatPrint("[BreathingSystem] Cannot use this form!")
                return false
            end
        end
    elseif action == "start_training" then
        local studentName = data.studentName
        local formID = data.formID
        if studentName and formID then
            local student = player.GetByName(studentName)
            if IsValid(student) then
                if BreathingSystem.Training.StartTraining(ply, student, formID) then
                    ply:ChatPrint("[BreathingSystem] Training session started with " .. student:Name())
                    return true
                else
                    ply:ChatPrint("[BreathingSystem] Failed to start training session!")
                    return false
                end
            else
                ply:ChatPrint("[BreathingSystem] Student not found!")
                return false
            end
        end
    elseif action == "enter_total_concentration" then
        if BreathingSystem.Concentration.EnterTotalConcentration(ply) then
            ply:ChatPrint("[BreathingSystem] Entered total concentration!")
            return true
        else
            ply:ChatPrint("[BreathingSystem] Cannot enter total concentration right now!")
            return false
        end
    end
    
    return false
end

-- Initialize menus system
if SERVER then
    -- Network messages
    util.AddNetworkString("BreathingSystem_MenuData")
    util.AddNetworkString("BreathingSystem_MenuAction")
    
    -- Handle menu actions
    net.Receive("BreathingSystem_MenuAction", function(len, ply)
        local action = net.ReadString()
        local data = net.ReadTable()
        
        BreathingSystem.Menus.HandleMenuAction(ply, action, data)
    end)
    
    print("[BreathingSystem.Menus] Menus system loaded")
end
