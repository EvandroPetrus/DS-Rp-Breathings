--[[
    BreathingSystem - Form Selection & Training System
    ==================================================
    Handles form selection, leveling, and training progression
]]

if SERVER then
    -- Initialize training data storage
    BreathingSystem = BreathingSystem or {}
    BreathingSystem.Training = BreathingSystem.Training or {}
    BreathingSystem.Training.PlayerData = BreathingSystem.Training.PlayerData or {}
    
    -- Get or create player training data
    local function GetTrainingData(ply)
        local steamID = ply:SteamID()
        if not BreathingSystem.Training.PlayerData[steamID] then
            BreathingSystem.Training.PlayerData[steamID] = {
                level = 1,
                experience = 0,
                training_points = 0,
                unlocked_forms = {
                    water = {true, false, false, false, false},  -- Only form 1 unlocked by default
                    fire = {true, false, false, false, false},
                    thunder = {true, false, false, false, false},
                    stone = {true, false, false, false, false},
                    wind = {true, false, false, false, false}
                },
                form_mastery = {},
                total_uses = 0
            }
        end
        return BreathingSystem.Training.PlayerData[steamID]
    end
    
    -- Level requirements for forms
    local FORM_REQUIREMENTS = {
        [1] = {level = 1, training_points = 0},
        [2] = {level = 3, training_points = 5},
        [3] = {level = 5, training_points = 10},
        [4] = {level = 7, training_points = 20},
        [5] = {level = 10, training_points = 40}
    }
    
    -- Experience required for each level
    local function GetExpForLevel(level)
        return level * 100 + (level - 1) * 50
    end
    
    -- Check if player can use a form
    local function CanUseForm(ply, breathingType, formNum)
        local data = GetTrainingData(ply)
        
        -- Check if form is unlocked
        if not data.unlocked_forms[breathingType] or not data.unlocked_forms[breathingType][formNum] then
            return false, "Form not unlocked yet!"
        end
        
        return true
    end
    
    -- Grant experience to player
    local function GrantExperience(ply, amount)
        local data = GetTrainingData(ply)
        data.experience = data.experience + amount
        
        -- Check for level up
        local requiredExp = GetExpForLevel(data.level + 1)
        while data.experience >= requiredExp do
            data.experience = data.experience - requiredExp
            data.level = data.level + 1
            data.training_points = data.training_points + 3 -- Grant 3 training points per level
            
            -- Announce level up
            ply:ChatPrint("[BreathingSystem] LEVEL UP! You are now level " .. data.level .. "!")
            ply:ChatPrint("[BreathingSystem] You gained 3 training points! Total: " .. data.training_points)
            
            -- Effects
            ply:EmitSound("ambient/levels/labs/electric_explosion1.wav", 80, 100)
            ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 100), 0.5, 0.2)
            
            -- Update network vars
            ply:SetNWInt("BreathingLevel", data.level)
            
            requiredExp = GetExpForLevel(data.level + 1)
        end
        
        -- Update HUD
        ply:SetNWInt("BreathingExp", data.experience)
        ply:SetNWInt("BreathingExpNext", requiredExp)
    end
    
    -- Apply form-specific effects
    local function ApplyFormEffects(ply, breathingType, formNum)
        local data = GetTrainingData(ply)
        local power = 1 + (data.level * 0.1) -- Power scales with level
        
        if breathingType == "water" then
            if formNum == 1 then
                -- Form 1: Basic water slash
                ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 5))
            elseif formNum == 2 then
                -- Form 2: Water wheel - area healing
                for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
                    if target:IsPlayer() and target:Team() == ply:Team() then
                        target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + 10))
                    end
                end
            elseif formNum == 3 then
                -- Form 3: Flowing dance - speed boost
                ply:SetWalkSpeed(300 * power)
                ply:SetRunSpeed(500 * power)
                timer.Simple(5, function()
                    if IsValid(ply) then
                        ply:SetWalkSpeed(200)
                        ply:SetRunSpeed(400)
                    end
                end)
            elseif formNum == 4 then
                -- Form 4: Waterfall basin - team heal
                for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
                    if target:IsPlayer() and target:Team() == ply:Team() then
                        target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + 30))
                        target:SetArmor(math.min(100, target:Armor() + 20))
                    end
                end
            elseif formNum == 5 then
                -- Form 5: Constant flux - ultimate
                ply:SetHealth(ply:GetMaxHealth())
                ply:SetArmor(100)
                ply:SetWalkSpeed(400 * power)
                ply:SetRunSpeed(700 * power)
                ply:GodEnable()
                timer.Simple(3, function()
                    if IsValid(ply) then
                        ply:GodDisable()
                        ply:SetWalkSpeed(200)
                        ply:SetRunSpeed(400)
                    end
                end)
            end
        end
        
        -- Add similar effects for other breathing types...
    end
    
    -- Enhanced form usage with training system
    concommand.Add("bs_use_form", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local playerData = BreathingSystem.PlayerRegistry and 
                          BreathingSystem.PlayerRegistry.GetPlayerData and
                          BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        
        if not playerData then
            ply:ChatPrint("[BreathingSystem] No player data found!")
            return
        end
        
        local breathingType = playerData.breathing_type or "water"
        local formNum = tonumber(args[1]) or 1
        
        -- Validate form number
        formNum = math.Clamp(formNum, 1, 5)
        
        -- Check if player can use this form
        local canUse, reason = CanUseForm(ply, breathingType, formNum)
        if not canUse then
            ply:ChatPrint("[BreathingSystem] " .. reason)
            ply:ChatPrint("[BreathingSystem] Form " .. formNum .. " requires:")
            local req = FORM_REQUIREMENTS[formNum]
            ply:ChatPrint("  - Level " .. req.level)
            ply:ChatPrint("  - " .. req.training_points .. " training points")
            ply:EmitSound("buttons/button10.wav", 75, 100)
            return
        end
        
        -- Check stamina
        local stamina = playerData.stamina or 100
        local staminaCost = 20 + (formNum * 5) -- Higher forms cost more stamina
        
        if stamina < staminaCost then
            ply:ChatPrint("[BreathingSystem] Not enough stamina! Need " .. staminaCost)
            return
        end
        
        -- Use stamina
        playerData.stamina = math.max(0, stamina - staminaCost)
        ply:SetNWInt("BreathingStamina", playerData.stamina)
        
        -- Get form name
        local forms = BreathingSystem.BreathingTypes and
                     BreathingSystem.BreathingTypes.GetForms and
                     BreathingSystem.BreathingTypes.GetForms(breathingType) or {}
        
        local form = forms[formNum]
        local formName = form and form.name or ("Form " .. formNum)
        
        -- Announce form usage
        ply:ChatPrint("[" .. breathingType:upper() .. "] " .. formName .. "!")
        
        -- Grant experience based on form level
        GrantExperience(ply, 10 * formNum)
        
        -- Track form usage
        local data = GetTrainingData(ply)
        data.total_uses = data.total_uses + 1
        
        -- Track mastery
        local masteryKey = breathingType .. "_" .. formNum
        data.form_mastery[masteryKey] = (data.form_mastery[masteryKey] or 0) + 1
        
        -- Trigger effects (from enhanced effects system)
        if BreathingSystem.CreateFormEffect then
            BreathingSystem.CreateFormEffect(ply, breathingType, form and form.id)
        end
        
        -- Apply form-specific effects based on level
        ApplyFormEffects(ply, breathingType, formNum)
    end)
    
    -- Command to unlock forms with training points
    concommand.Add("bs_unlock_form", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local breathingType = args[1]
        local formNum = tonumber(args[2])
        
        if not breathingType or not formNum then
            ply:ChatPrint("[BreathingSystem] Usage: bs_unlock_form <type> <form_number>")
            ply:ChatPrint("  Types: water, fire, thunder, stone, wind")
            ply:ChatPrint("  Forms: 1-5")
            return
        end
        
        formNum = math.Clamp(formNum, 1, 5)
        
        local data = GetTrainingData(ply)
        local req = FORM_REQUIREMENTS[formNum]
        
        -- Check if already unlocked
        if data.unlocked_forms[breathingType] and data.unlocked_forms[breathingType][formNum] then
            ply:ChatPrint("[BreathingSystem] Form already unlocked!")
            return
        end
        
        -- Check requirements
        if data.level < req.level then
            ply:ChatPrint("[BreathingSystem] Need level " .. req.level .. " (current: " .. data.level .. ")")
            return
        end
        
        if data.training_points < req.training_points then
            ply:ChatPrint("[BreathingSystem] Need " .. req.training_points .. " training points (have: " .. data.training_points .. ")")
            return
        end
        
        -- Check previous form
        if formNum > 1 and not data.unlocked_forms[breathingType][formNum - 1] then
            ply:ChatPrint("[BreathingSystem] Must unlock Form " .. (formNum - 1) .. " first!")
            return
        end
        
        -- Unlock the form
        data.training_points = data.training_points - req.training_points
        data.unlocked_forms[breathingType][formNum] = true
        
        ply:ChatPrint("[BreathingSystem] UNLOCKED: " .. breathingType:upper() .. " Form " .. formNum .. "!")
        ply:EmitSound("ambient/levels/labs/electric_explosion2.wav", 80, 100)
        ply:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 100), 0.5, 0.2)
    end)
    
    -- Command to check training status
    concommand.Add("bs_training", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local data = GetTrainingData(ply)
        local playerData = BreathingSystem.PlayerRegistry and 
                          BreathingSystem.PlayerRegistry.GetPlayerData and
                          BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        
        local breathingType = playerData and playerData.breathing_type or "water"
        
        ply:ChatPrint("========================================")
        ply:ChatPrint("BREATHING TRAINING STATUS")
        ply:ChatPrint("========================================")
        ply:ChatPrint("Level: " .. data.level)
        ply:ChatPrint("Experience: " .. data.experience .. "/" .. GetExpForLevel(data.level + 1))
        ply:ChatPrint("Training Points: " .. data.training_points)
        ply:ChatPrint("Current Type: " .. breathingType:upper())
        ply:ChatPrint("")
        ply:ChatPrint("UNLOCKED FORMS (" .. breathingType .. "):")
        
        local forms = data.unlocked_forms[breathingType]
        for i = 1, 5 do
            local status = forms[i] and "✓ UNLOCKED" or "✗ LOCKED"
            local req = FORM_REQUIREMENTS[i]
            ply:ChatPrint("  Form " .. i .. ": " .. status .. " (Req: Lv" .. req.level .. ", " .. req.training_points .. "TP)")
        end
        
        ply:ChatPrint("")
        ply:ChatPrint("Total Forms Used: " .. data.total_uses)
        ply:ChatPrint("========================================")
    end)
    
    -- Give training points command (for testing)
    concommand.Add("bs_give_tp", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        -- Admin check (optional)
        -- if not ply:IsAdmin() then return end
        
        local amount = tonumber(args[1]) or 10
        local data = GetTrainingData(ply)
        data.training_points = data.training_points + amount
        
        ply:ChatPrint("[BreathingSystem] Granted " .. amount .. " training points! Total: " .. data.training_points)
    end)
    
    -- Give experience command
    concommand.Add("bs_give_exp", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local amount = tonumber(args[1]) or 100
        GrantExperience(ply, amount)
        
        ply:ChatPrint("[BreathingSystem] Granted " .. amount .. " experience!")
    end)
    
    -- Quick unlock all forms (for testing)
    concommand.Add("bs_unlock_all", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local data = GetTrainingData(ply)
        local breathingType = args[1] or "water"
        
        -- Unlock all forms for the type
        for i = 1, 5 do
            data.unlocked_forms[breathingType][i] = true
        end
        
        -- Set to max level
        data.level = 20
        data.training_points = 100
        
        ply:ChatPrint("[BreathingSystem] All " .. breathingType:upper() .. " forms unlocked!")
        ply:ChatPrint("[BreathingSystem] Set to level 20 with 100 training points!")
    end)
    
    -- Initialize player on spawn
    hook.Add("PlayerInitialSpawn", "BreathingSystem_InitTraining", function(ply)
        local data = GetTrainingData(ply)
        
        -- Set initial network vars
        ply:SetNWInt("BreathingLevel", data.level)
        ply:SetNWInt("BreathingExp", data.experience)
        ply:SetNWInt("BreathingExpNext", GetExpForLevel(data.level + 1))
        
        -- Welcome message
        timer.Simple(5, function()
            if IsValid(ply) then
                ply:ChatPrint("========================================")
                ply:ChatPrint("[BreathingSystem] Training System Active!")
                ply:ChatPrint("  Level: " .. data.level)
                ply:ChatPrint("  Training Points: " .. data.training_points)
                ply:ChatPrint("  Type 'bs_training' to check status")
                ply:ChatPrint("  Type 'bs_unlock_form <type> <num>' to unlock forms")
                ply:ChatPrint("========================================")
            end
        end)
    end)
    
    -- Chat commands for form selection
    hook.Add("PlayerSay", "BreathingSystem_FormSelection", function(ply, text, team)
        local lower = string.lower(text)
        
        -- Handle form selection: !form1, !form2, etc.
        if string.match(lower, "^!form%d$") then
            local formNum = tonumber(string.match(lower, "%d"))
            if formNum and formNum >= 1 and formNum <= 5 then
                ply:ConCommand("bs_use_form " .. formNum)
                return ""
            end
        end
        
        -- Handle specific form commands
        if lower == "!training" then
            ply:ConCommand("bs_training")
            return ""
        elseif lower == "!unlock" then
            ply:ChatPrint("[BreathingSystem] Usage: !unlock <type> <form>")
            ply:ChatPrint("  Example: !unlock water 2")
            return ""
        elseif string.match(lower, "^!unlock%s+%w+%s+%d$") then
            local type, num = string.match(lower, "^!unlock%s+(%w+)%s+(%d)$")
            ply:ConCommand("bs_unlock_form " .. type .. " " .. num)
            return ""
        end
    end)
    
    print("[BreathingSystem] Training & Form Selection System Loaded!")
    print("  Commands:")
    print("    bs_use_form [1-5] - Use specific form")
    print("    bs_training - Check training status")
    print("    bs_unlock_form <type> <num> - Unlock a form")
    print("    bs_give_tp [amount] - Give training points")
    print("    bs_give_exp [amount] - Give experience")
    print("  Chat Commands:")
    print("    !form1-5 - Use forms 1-5")
    print("    !training - Check status")
    print("    !unlock <type> <num> - Unlock form")
end
