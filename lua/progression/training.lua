--[[
    BreathingSystem - Training System
    ================================
    
    This module handles training mechanics and XP gain for players.
    Manages teacher/student relationships and training sessions.
    
    Responsibilities:
    - Handle training sessions between players
    - Manage XP gain and level progression
    - Track teacher/student relationships
    - Provide training API functions
    
    Public API:
    - BreathingSystem.Training.StartTraining(teacher, student, formID) - Start training session
    - BreathingSystem.Training.EndTraining(teacher, student) - End training session
    - BreathingSystem.Training.GainXP(ply, amount) - Give XP to player
    - BreathingSystem.Training.GetXP(ply) - Get player XP
    - BreathingSystem.Training.GetLevel(ply) - Get player level
]]

-- Initialize training module
BreathingSystem.Training = BreathingSystem.Training or {}

-- Training configuration
BreathingSystem.Training.Config = {
    -- XP requirements per level
    xp_requirements = {
        [1] = 0,    -- Level 1: 0 XP
        [2] = 100,  -- Level 2: 100 XP
        [3] = 250,  -- Level 3: 250 XP
        [4] = 450,  -- Level 4: 450 XP
        [5] = 700,  -- Level 5: 700 XP
        [6] = 1000, -- Level 6: 1000 XP
        [7] = 1350, -- Level 7: 1350 XP
        [8] = 1750, -- Level 8: 1750 XP
        [9] = 2200, -- Level 9: 2200 XP
        [10] = 2700, -- Level 10: 2700 XP
        [11] = 3250, -- Level 11: 3250 XP
        [12] = 3850, -- Level 12: 3850 XP
        [13] = 4500, -- Level 13: 4500 XP
        [14] = 5200, -- Level 14: 5200 XP
        [15] = 5950, -- Level 15: 5950 XP
        [16] = 6750, -- Level 16: 6750 XP
        [17] = 7600, -- Level 17: 7600 XP
        [18] = 8500, -- Level 18: 8500 XP
        [19] = 9450, -- Level 19: 9450 XP
        [20] = 10450 -- Level 20: 10450 XP
    },
    
    -- XP gain rates
    xp_gain_rates = {
        training_session = 50,      -- XP per training session
        form_usage = 10,           -- XP per form usage
        breathing_practice = 5,    -- XP per breathing practice
        teaching = 25,             -- XP for teaching others
        achievement = 100          -- XP for achievements
    },
    
    -- Training session settings
    training_session = {
        duration = 300,            -- 5 minutes
        max_distance = 500,        -- Maximum distance between teacher and student
        cooldown = 600,            -- 10 minutes cooldown between sessions
        max_students = 3           -- Maximum students per teacher
    }
}

-- Start training session
function BreathingSystem.Training.StartTraining(teacher, student, formID)
    if not IsValid(teacher) or not IsValid(student) then return false end
    if teacher == student then return false end
    
    local teacherData = BreathingSystem.GetPlayerData(teacher)
    local studentData = BreathingSystem.GetPlayerData(student)
    
    if not teacherData or not studentData then return false end
    
    -- Check if teacher is already training someone
    if teacherData.training_student and IsValid(teacherData.training_student) then
        teacher:ChatPrint("[BreathingSystem] You are already training someone!")
        return false
    end
    
    -- Check if student is already being trained
    if studentData.training_teacher and IsValid(studentData.training_teacher) then
        student:ChatPrint("[BreathingSystem] You are already being trained!")
        return false
    end
    
    -- Check distance
    local distance = teacher:GetPos():Distance(student:GetPos())
    if distance > BreathingSystem.Training.Config.training_session.max_distance then
        teacher:ChatPrint("[BreathingSystem] Student is too far away!")
        return false
    end
    
    -- Check cooldown
    local lastTraining = studentData.last_training_time or 0
    if CurTime() - lastTraining < BreathingSystem.Training.Config.training_session.cooldown then
        local remaining = BreathingSystem.Training.Config.training_session.cooldown - (CurTime() - lastTraining)
        teacher:ChatPrint("[BreathingSystem] Student must wait " .. math.ceil(remaining) .. " seconds before training again!")
        return false
    end
    
    -- Start training session
    teacherData.training_student = student
    studentData.training_teacher = teacher
    studentData.training_start_time = CurTime()
    studentData.training_form = formID
    
    print("[BreathingSystem.Training] Started training session: " .. teacher:Name() .. " -> " .. student:Name())
    
    -- Notify players
    teacher:ChatPrint("[BreathingSystem] Training session started with " .. student:Name())
    student:ChatPrint("[BreathingSystem] Training session started with " .. teacher:Name())
    
    -- Start training timer
    timer.Create("BreathingSystem_Training_" .. teacher:SteamID(), BreathingSystem.Training.Config.training_session.duration, 1, function()
        if IsValid(teacher) and IsValid(student) then
            BreathingSystem.Training.EndTraining(teacher, student)
        end
    end)
    
    return true
end

-- End training session
function BreathingSystem.Training.EndTraining(teacher, student)
    if not IsValid(teacher) or not IsValid(student) then return false end
    
    local teacherData = BreathingSystem.GetPlayerData(teacher)
    local studentData = BreathingSystem.GetPlayerData(student)
    
    if not teacherData or not studentData then return false end
    
    -- Check if they were actually training
    if teacherData.training_student != student or studentData.training_teacher != teacher then
        return false
    end
    
    -- Calculate XP gain
    local trainingTime = CurTime() - (studentData.training_start_time or CurTime())
    local xpGain = math.floor(trainingTime / 60) * BreathingSystem.Training.Config.xp_gain_rates.training_session
    
    -- Give XP to student
    BreathingSystem.Training.GainXP(student, xpGain)
    
    -- Give XP to teacher
    BreathingSystem.Training.GainXP(teacher, BreathingSystem.Training.Config.xp_gain_rates.teaching)
    
    -- Update training data
    studentData.last_training_time = CurTime()
    studentData.training_sessions = (studentData.training_sessions or 0) + 1
    
    -- Clear training relationship
    teacherData.training_student = nil
    studentData.training_teacher = nil
    studentData.training_start_time = nil
    studentData.training_form = nil
    
    print("[BreathingSystem.Training] Ended training session: " .. teacher:Name() .. " -> " .. student:Name() .. " (XP: " .. xpGain .. ")")
    
    -- Notify players
    teacher:ChatPrint("[BreathingSystem] Training session ended. XP gained: " .. BreathingSystem.Training.Config.xp_gain_rates.teaching)
    student:ChatPrint("[BreathingSystem] Training session ended. XP gained: " .. xpGain)
    
    -- Check for form unlocks
    BreathingSystem.Unlocks.AutoUnlockForms(student)
    
    return true
end

-- Gain XP
function BreathingSystem.Training.GainXP(ply, amount)
    if not IsValid(ply) or not amount or amount <= 0 then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local oldXP = data.xp or 0
    local newXP = oldXP + amount
    local oldLevel = BreathingSystem.Training.GetLevel(ply)
    
    data.xp = newXP
    
    -- Check for level up
    local newLevel = BreathingSystem.Training.GetLevel(ply)
    if newLevel > oldLevel then
        BreathingSystem.Training.LevelUp(ply, oldLevel, newLevel)
    end
    
    print("[BreathingSystem.Training] " .. ply:Name() .. " gained " .. amount .. " XP (Total: " .. newXP .. ")")
    
    return true
end

-- Get player XP
function BreathingSystem.Training.GetXP(ply)
    if not IsValid(ply) then return 0 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 0 end
    
    return data.xp or 0
end

-- Get player level
function BreathingSystem.Training.GetLevel(ply)
    if not IsValid(ply) then return 1 end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return 1 end
    
    local xp = data.xp or 0
    local level = 1
    
    for reqLevel, reqXP in pairs(BreathingSystem.Training.Config.xp_requirements) do
        if xp >= reqXP then
            level = reqLevel
        end
    end
    
    return level
end

-- Level up player
function BreathingSystem.Training.LevelUp(ply, oldLevel, newLevel)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    data.level = newLevel
    
    print("[BreathingSystem.Training] " .. ply:Name() .. " leveled up from " .. oldLevel .. " to " .. newLevel .. "!")
    
    -- Notify player
    ply:ChatPrint("[BreathingSystem] Level up! You are now level " .. newLevel .. "!")
    
    -- Check for form unlocks
    BreathingSystem.Unlocks.AutoUnlockForms(ply)
    
    -- Trigger level up event
    hook.Run("BreathingSystem_LevelUp", ply, oldLevel, newLevel)
    
    return true
end

-- Get XP progress for next level
function BreathingSystem.Training.GetXPProgress(ply)
    if not IsValid(ply) then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    local currentXP = data.xp or 0
    local currentLevel = BreathingSystem.Training.GetLevel(ply)
    local nextLevel = currentLevel + 1
    
    local currentLevelXP = BreathingSystem.Training.Config.xp_requirements[currentLevel] or 0
    local nextLevelXP = BreathingSystem.Training.Config.xp_requirements[nextLevel] or currentLevelXP
    
    local progress = {
        currentLevel = currentLevel,
        nextLevel = nextLevel,
        currentXP = currentXP,
        currentLevelXP = currentLevelXP,
        nextLevelXP = nextLevelXP,
        xpNeeded = nextLevelXP - currentXP,
        progressPercent = 0
    }
    
    if nextLevelXP > currentLevelXP then
        progress.progressPercent = ((currentXP - currentLevelXP) / (nextLevelXP - currentLevelXP)) * 100
    else
        progress.progressPercent = 100
    end
    
    return progress
end

-- Get training status
function BreathingSystem.Training.GetTrainingStatus(ply)
    if not IsValid(ply) then return nil end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return nil end
    
    return {
        isTraining = data.training_teacher and IsValid(data.training_teacher),
        isTeaching = data.training_student and IsValid(data.training_student),
        teacher = data.training_teacher,
        student = data.training_student,
        trainingStartTime = data.training_start_time,
        trainingForm = data.training_form
    }
end

-- Force end all training sessions for a player
function BreathingSystem.Training.ForceEndAllTraining(ply)
    if not IsValid(ply) then return false end
    
    local data = BreathingSystem.GetPlayerData(ply)
    if not data then return false end
    
    local ended = false
    
    -- End teaching session
    if data.training_student and IsValid(data.training_student) then
        BreathingSystem.Training.EndTraining(ply, data.training_student)
        ended = true
    end
    
    -- End learning session
    if data.training_teacher and IsValid(data.training_teacher) then
        BreathingSystem.Training.EndTraining(data.training_teacher, ply)
        ended = true
    end
    
    return ended
end

-- Initialize training system
if SERVER then
    -- Handle player disconnect
    hook.Add("PlayerDisconnected", "BreathingSystem_Training_Disconnect", function(ply)
        BreathingSystem.Training.ForceEndAllTraining(ply)
    end)
    
    print("[BreathingSystem.Training] Training system loaded")
end
