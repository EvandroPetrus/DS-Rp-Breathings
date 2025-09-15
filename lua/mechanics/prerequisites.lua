--[[
    BreathingSystem - Prerequisites Mechanics
    ========================================
    
    This module handles prerequisites and requirements for breathing forms.
    Manages level requirements, training, and unlock conditions.
    
    Responsibilities:
    - Check if player meets form requirements
    - Track player progress and unlocks
    - Handle level and training prerequisites
    - Provide API for requirement checking
    
    Public API:
    - BreathingSystem.Prerequisites.CanUseForm(ply, formID) - Check if player can use form
    - BreathingSystem.Prerequisites.GetFormRequirements(formID) - Get form requirements
    - BreathingSystem.Prerequisites.CheckLevel(ply, requiredLevel) - Check level requirement
    - BreathingSystem.Prerequisites.CheckTraining(ply, formID) - Check training requirement
    - BreathingSystem.Prerequisites.UnlockForm(ply, formID) - Unlock form for player
]]

-- Initialize prerequisites module
BreathingSystem.Prerequisites = BreathingSystem.Prerequisites or {}

-- Prerequisites configuration
BreathingSystem.Prerequisites.Config = {
    -- Level requirements
    level_requirements = {
        basic = 1,      -- Basic forms require level 1
        intermediate = 5, -- Intermediate forms require level 5
        advanced = 10,  -- Advanced forms require level 10
        master = 15,    -- Master forms require level 15
        legendary = 20  -- Legendary forms require level 20
    },
    
    -- Training requirements
    training_requirements = {
        basic = 0,      -- Basic forms require no training
        intermediate = 2, -- Intermediate forms require 2 training sessions
        advanced = 5,   -- Advanced forms require 5 training sessions
        master = 10,    -- Master forms require 10 training sessions
        legendary = 20  -- Legendary forms require 20 training sessions
    },
    
    -- Breathing type mastery requirements
    breathing_type_mastery = {
        water = 0.8,    -- Water breathing requires 80% mastery
        fire = 0.9,     -- Fire breathing requires 90% mastery
        thunder = 0.85, -- Thunder breathing requires 85% mastery
        stone = 0.75,   -- Stone breathing requires 75% mastery
        wind = 0.8      -- Wind breathing requires 80% mastery
    }
}

-- Check if player can use a form
function BreathingSystem.Prerequisites.CanUseForm(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return false end
    
    -- Check if form is unlocked
    if not BreathingSystem.Prerequisites.IsFormUnlocked(ply, formID) then
        return false
    end
    
    -- Check level requirement
    if not BreathingSystem.Prerequisites.CheckLevel(ply, form.requirements.level or 1) then
        return false
    end
    
    -- Check previous forms requirement
    if not BreathingSystem.Prerequisites.CheckPreviousForms(ply, form.requirements.previous_forms or {}) then
        return false
    end
    
    -- Check training requirement
    if not BreathingSystem.Prerequisites.CheckTraining(ply, formID) then
        return false
    end
    
    -- Check breathing type mastery
    if not BreathingSystem.Prerequisites.CheckBreathingTypeMastery(ply, formID) then
        return false
    end
    
    return true
end

-- Get form requirements
function BreathingSystem.Prerequisites.GetFormRequirements(formID)
    if not formID then return {} end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return {} end
    
    return form.requirements or {}
end

-- Check level requirement
function BreathingSystem.Prerequisites.CheckLevel(ply, requiredLevel)
    if not IsValid(ply) or not requiredLevel then return true end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local playerLevel = data.level or 1
    return playerLevel >= requiredLevel
end

-- Check previous forms requirement
function BreathingSystem.Prerequisites.CheckPreviousForms(ply, requiredForms)
    if not IsValid(ply) or not requiredForms or #requiredForms == 0 then return true end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local unlockedForms = data.unlocked_forms or {}
    
    for _, formID in ipairs(requiredForms) do
        if not unlockedForms[formID] then
            return false
        end
    end
    
    return true
end

-- Check training requirement
function BreathingSystem.Prerequisites.CheckTraining(ply, formID)
    if not IsValid(ply) or not formID then return true end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return false end
    
    local requiredTraining = form.requirements.training or 0
    if requiredTraining <= 0 then return true end
    
    local playerTraining = data.training_sessions or 0
    return playerTraining >= requiredTraining
end

-- Check breathing type mastery
function BreathingSystem.Prerequisites.CheckBreathingTypeMastery(ply, formID)
    if not IsValid(ply) or not formID then return true end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return false end
    
    local breathingType = data.current_breathing_type or "normal"
    local requiredMastery = BreathingSystem.Prerequisites.Config.breathing_type_mastery[breathingType] or 0
    if requiredMastery <= 0 then return true end
    
    local playerMastery = data.breathing_type_mastery or {}
    local currentMastery = playerMastery[breathingType] or 0
    
    return currentMastery >= requiredMastery
end

-- Check if form is unlocked
function BreathingSystem.Prerequisites.IsFormUnlocked(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local unlockedForms = data.unlocked_forms or {}
    return unlockedForms[formID] or false
end

-- Unlock form for player
function BreathingSystem.Prerequisites.UnlockForm(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.unlocked_forms then
        data.unlocked_forms = {}
    end
    
    data.unlocked_forms[formID] = true
    
    print("[BreathingSystem.Prerequisites] Unlocked form " .. formID .. " for " .. ply:Name())
    
    return true
end

-- Lock form for player
function BreathingSystem.Prerequisites.LockForm(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.unlocked_forms then
        data.unlocked_forms = {}
    end
    
    data.unlocked_forms[formID] = false
    
    print("[BreathingSystem.Prerequisites] Locked form " .. formID .. " for " .. ply:Name())
    
    return true
end

-- Get player's unlocked forms
function BreathingSystem.Prerequisites.GetUnlockedForms(ply)
    if not IsValid(ply) then return {} end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return {} end
    
    return data.unlocked_forms or {}
end

-- Add training session
function BreathingSystem.Prerequisites.AddTrainingSession(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    data.training_sessions = (data.training_sessions or 0) + 1
    
    print("[BreathingSystem.Prerequisites] Added training session for " .. ply:Name() .. " (Total: " .. data.training_sessions .. ")")
    
    return true
end

-- Set player level
function BreathingSystem.Prerequisites.SetLevel(ply, level)
    if not IsValid(ply) or not level or level < 1 then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    data.level = level
    
    print("[BreathingSystem.Prerequisites] Set level " .. level .. " for " .. ply:Name())
    
    return true
end

-- Get player level
function BreathingSystem.Prerequisites.GetLevel(ply)
    if not IsValid(ply) then return 1 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 1 end
    
    return data.level or 1
end

-- Set breathing type mastery
function BreathingSystem.Prerequisites.SetBreathingTypeMastery(ply, breathingType, mastery)
    if not IsValid(ply) or not breathingType or not mastery then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    if not data.breathing_type_mastery then
        data.breathing_type_mastery = {}
    end
    
    data.breathing_type_mastery[breathingType] = math.Clamp(mastery, 0, 1)
    
    print("[BreathingSystem.Prerequisites] Set " .. breathingType .. " mastery to " .. mastery .. " for " .. ply:Name())
    
    return true
end

-- Get breathing type mastery
function BreathingSystem.Prerequisites.GetBreathingTypeMastery(ply, breathingType)
    if not IsValid(ply) or not breathingType then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    local mastery = data.breathing_type_mastery or {}
    return mastery[breathingType] or 0
end

-- Check all prerequisites for a form
function BreathingSystem.Prerequisites.CheckAllPrerequisites(ply, formID)
    if not IsValid(ply) or not formID then return false, "Invalid parameters" end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return false, "Form not found" end
    
    -- Check if form is unlocked
    if not BreathingSystem.Prerequisites.IsFormUnlocked(ply, formID) then
        return false, "Form not unlocked"
    end
    
    -- Check level requirement
    local requiredLevel = form.requirements.level or 1
    if not BreathingSystem.Prerequisites.CheckLevel(ply, requiredLevel) then
        return false, "Level " .. requiredLevel .. " required"
    end
    
    -- Check previous forms requirement
    local requiredForms = form.requirements.previous_forms or {}
    if not BreathingSystem.Prerequisites.CheckPreviousForms(ply, requiredForms) then
        return false, "Previous forms required"
    end
    
    -- Check training requirement
    local requiredTraining = form.requirements.training or 0
    if not BreathingSystem.Prerequisites.CheckTraining(ply, formID) then
        return false, "Training required"
    end
    
    -- Check breathing type mastery
    if not BreathingSystem.Prerequisites.CheckBreathingTypeMastery(ply, formID) then
        return false, "Breathing type mastery required"
    end
    
    return true, "All prerequisites met"
end

-- Initialize prerequisites system
if SERVER then
    print("[BreathingSystem.Prerequisites] Prerequisites mechanics loaded")
end
