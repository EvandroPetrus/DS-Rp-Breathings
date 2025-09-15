--[[
    BreathingSystem - Unlocks System
    ===============================
    
    This module handles form unlocking and progression tracking.
    Manages which forms players have unlocked and their progression status.
    
    Responsibilities:
    - Track unlocked forms per player
    - Handle form unlocking conditions
    - Manage progression milestones
    - Provide API for unlock management
    
    Public API:
    - BreathingSystem.Unlocks.UnlockForm(ply, formID) - Unlock form for player
    - BreathingSystem.Unlocks.IsFormUnlocked(ply, formID) - Check if form is unlocked
    - BreathingSystem.Unlocks.GetUnlockedForms(ply) - Get all unlocked forms
    - BreathingSystem.Unlocks.CheckUnlockConditions(ply, formID) - Check unlock conditions
]]

-- Initialize unlocks module
BreathingSystem.Unlocks = BreathingSystem.Unlocks or {}

-- Unlocks configuration
BreathingSystem.Unlocks.Config = {
    -- Unlock conditions
    unlock_conditions = {
        level = true,           -- Requires level
        training = true,        -- Requires training
        previous_forms = true,  -- Requires previous forms
        mastery = true,         -- Requires breathing type mastery
        achievements = true     -- Requires achievements
    },
    
    -- Unlock thresholds
    unlock_thresholds = {
        basic_forms = {
            level = 1,
            training = 0,
            mastery = 0
        },
        intermediate_forms = {
            level = 5,
            training = 2,
            mastery = 0.3
        },
        advanced_forms = {
            level = 10,
            training = 5,
            mastery = 0.6
        },
        master_forms = {
            level = 15,
            training = 10,
            mastery = 0.8
        },
        legendary_forms = {
            level = 20,
            training = 20,
            mastery = 0.95
        }
    },
    
    -- Special unlock conditions
    special_unlocks = {
        -- Water breathing special unlocks
        water_constant_flux = {
            requires_forms = {"water_surface_slash", "water_water_wheel", "water_flowing_dance", "water_waterfall_basin"},
            requires_mastery = 0.9,
            requires_achievement = "water_master"
        },
        
        -- Fire breathing special unlocks
        fire_sun_breathing = {
            requires_forms = {"fire_unknowing_fire", "fire_rising_scorching_sun", "fire_blazing_universe", "fire_hinokami_kagura"},
            requires_mastery = 0.95,
            requires_achievement = "fire_master"
        },
        
        -- Thunder breathing special unlocks
        thunder_honoikazuchi_no_kami = {
            requires_forms = {"thunder_clap_flash", "thunder_rice_spirit", "thunder_swarm", "thunder_heat_lightning"},
            requires_mastery = 0.9,
            requires_achievement = "thunder_master"
        }
    }
}

-- Unlock form for player
function BreathingSystem.Unlocks.UnlockForm(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    -- Check if already unlocked
    if BreathingSystem.Unlocks.IsFormUnlocked(ply, formID) then
        return true
    end
    
    -- Check unlock conditions
    local canUnlock, reason = BreathingSystem.Unlocks.CheckUnlockConditions(ply, formID)
    if not canUnlock then
        print("[BreathingSystem.Unlocks] Cannot unlock " .. formID .. " for " .. ply:Name() .. ": " .. reason)
        return false
    end
    
    -- Initialize unlocked forms if needed
    if not data.unlocked_forms then
        data.unlocked_forms = {}
    end
    
    -- Unlock the form
    data.unlocked_forms[formID] = true
    data.unlock_time = data.unlock_time or {}
    data.unlock_time[formID] = CurTime()
    
    print("[BreathingSystem.Unlocks] Unlocked form " .. formID .. " for " .. ply:Name())
    
    -- Notify player
    ply:ChatPrint("[BreathingSystem] You have unlocked a new form: " .. formID)
    
    -- Trigger unlock event
    hook.Run("BreathingSystem_FormUnlocked", ply, formID)
    
    return true
end

-- Check if form is unlocked
function BreathingSystem.Unlocks.IsFormUnlocked(ply, formID)
    if not IsValid(ply) or not formID then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local unlockedForms = data.unlocked_forms or {}
    return unlockedForms[formID] or false
end

-- Get all unlocked forms for player
function BreathingSystem.Unlocks.GetUnlockedForms(ply)
    if not IsValid(ply) then return {} end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return {} end
    
    return data.unlocked_forms or {}
end

-- Check unlock conditions for a form
function BreathingSystem.Unlocks.CheckUnlockConditions(ply, formID)
    if not IsValid(ply) or not formID then return false, "Invalid parameters" end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return false, "Form not found" end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false, "Player data not found" end
    
    -- Check special unlock conditions first
    local specialUnlock = BreathingSystem.Unlocks.Config.special_unlocks[formID]
    if specialUnlock then
        return BreathingSystem.Unlocks.CheckSpecialUnlockConditions(ply, formID, specialUnlock)
    end
    
    -- Check standard unlock conditions
    local difficulty = form.difficulty or 1
    local thresholds = BreathingSystem.Unlocks.GetThresholdsForDifficulty(difficulty)
    
    -- Check level requirement
    if BreathingSystem.Unlocks.Config.unlock_conditions.level then
        local playerLevel = data.level or 1
        if playerLevel < thresholds.level then
            return false, "Level " .. thresholds.level .. " required"
        end
    end
    
    -- Check training requirement
    if BreathingSystem.Unlocks.Config.unlock_conditions.training then
        local playerTraining = data.training_sessions or 0
        if playerTraining < thresholds.training then
            return false, "Training required"
        end
    end
    
    -- Check previous forms requirement
    if BreathingSystem.Unlocks.Config.unlock_conditions.previous_forms then
        local requiredForms = form.requirements.previous_forms or {}
        for _, reqForm in ipairs(requiredForms) do
            if not BreathingSystem.Unlocks.IsFormUnlocked(ply, reqForm) then
                return false, "Previous forms required"
            end
        end
    end
    
    -- Check mastery requirement
    if BreathingSystem.Unlocks.Config.unlock_conditions.mastery then
        local breathingType = data.current_breathing_type or "normal"
        local playerMastery = data.breathing_type_mastery or {}
        local currentMastery = playerMastery[breathingType] or 0
        
        if currentMastery < thresholds.mastery then
            return false, "Breathing type mastery required"
        end
    end
    
    return true, "All conditions met"
end

-- Check special unlock conditions
function BreathingSystem.Unlocks.CheckSpecialUnlockConditions(ply, formID, conditions)
    if not IsValid(ply) or not formID or not conditions then return false, "Invalid parameters" end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false, "Player data not found" end
    
    -- Check required forms
    if conditions.requires_forms then
        for _, reqForm in ipairs(conditions.requires_forms) do
            if not BreathingSystem.Unlocks.IsFormUnlocked(ply, reqForm) then
                return false, "Required forms not unlocked"
            end
        end
    end
    
    -- Check mastery requirement
    if conditions.requires_mastery then
        local breathingType = data.current_breathing_type or "normal"
        local playerMastery = data.breathing_type_mastery or {}
        local currentMastery = playerMastery[breathingType] or 0
        
        if currentMastery < conditions.requires_mastery then
            return false, "Mastery requirement not met"
        end
    end
    
    -- Check achievement requirement
    if conditions.requires_achievement then
        local achievements = data.achievements or {}
        if not achievements[conditions.requires_achievement] then
            return false, "Achievement required"
        end
    end
    
    return true, "All special conditions met"
end

-- Get thresholds for difficulty level
function BreathingSystem.Unlocks.GetThresholdsForDifficulty(difficulty)
    if difficulty <= 1 then
        return BreathingSystem.Unlocks.Config.unlock_thresholds.basic_forms
    elseif difficulty <= 2 then
        return BreathingSystem.Unlocks.Config.unlock_thresholds.intermediate_forms
    elseif difficulty <= 3 then
        return BreathingSystem.Unlocks.Config.unlock_thresholds.advanced_forms
    elseif difficulty <= 4 then
        return BreathingSystem.Unlocks.Config.unlock_thresholds.master_forms
    else
        return BreathingSystem.Unlocks.Config.unlock_thresholds.legendary_forms
    end
end

-- Auto-unlock forms based on conditions
function BreathingSystem.Unlocks.AutoUnlockForms(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local unlockedCount = 0
    
    -- Check all forms for auto-unlock
    for formID, form in pairs(BreathingSystem.Forms.GetAll()) do
        if not BreathingSystem.Unlocks.IsFormUnlocked(ply, formID) then
            local canUnlock, reason = BreathingSystem.Unlocks.CheckUnlockConditions(ply, formID)
            if canUnlock then
                BreathingSystem.Unlocks.UnlockForm(ply, formID)
                unlockedCount = unlockedCount + 1
            end
        end
    end
    
    if unlockedCount > 0 then
        print("[BreathingSystem.Unlocks] Auto-unlocked " .. unlockedCount .. " forms for " .. ply:Name())
    end
    
    return unlockedCount > 0
end

-- Get unlock progress for a form
function BreathingSystem.Unlocks.GetUnlockProgress(ply, formID)
    if not IsValid(ply) or not formID then return nil end
    
    local form = BreathingSystem.Forms.GetForm(formID)
    if not form then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    local progress = {
        formID = formID,
        isUnlocked = BreathingSystem.Unlocks.IsFormUnlocked(ply, formID),
        requirements = {}
    }
    
    -- Check level requirement
    local playerLevel = data.level or 1
    local requiredLevel = form.requirements.level or 1
    progress.requirements.level = {
        current = playerLevel,
        required = requiredLevel,
        met = playerLevel >= requiredLevel
    }
    
    -- Check training requirement
    local playerTraining = data.training_sessions or 0
    local requiredTraining = form.requirements.training or 0
    progress.requirements.training = {
        current = playerTraining,
        required = requiredTraining,
        met = playerTraining >= requiredTraining
    }
    
    -- Check previous forms requirement
    local requiredForms = form.requirements.previous_forms or {}
    local unlockedForms = data.unlocked_forms or {}
    local previousFormsMet = 0
    
    for _, reqForm in ipairs(requiredForms) do
        if unlockedForms[reqForm] then
            previousFormsMet = previousFormsMet + 1
        end
    end
    
    progress.requirements.previous_forms = {
        current = previousFormsMet,
        required = #requiredForms,
        met = previousFormsMet >= #requiredForms
    }
    
    -- Check mastery requirement
    local breathingType = data.current_breathing_type or "normal"
    local playerMastery = data.breathing_type_mastery or {}
    local currentMastery = playerMastery[breathingType] or 0
    local requiredMastery = BreathingSystem.Unlocks.GetThresholdsForDifficulty(form.difficulty or 1).mastery
    
    progress.requirements.mastery = {
        current = currentMastery,
        required = requiredMastery,
        met = currentMastery >= requiredMastery
    }
    
    return progress
end

-- Initialize unlocks system
if SERVER then
    print("[BreathingSystem.Unlocks] Unlocks system loaded")
end
