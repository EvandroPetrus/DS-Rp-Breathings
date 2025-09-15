--[[
    BreathingSystem - Demo Mode
    ============================
    
    Automated demonstration system for showcasing all breathing types and forms
]]

-- Demo state
local DemoState = {
    active = false,
    currentType = 1,
    currentForm = 1,
    player = nil,
    startTime = 0,
    types = {"water", "fire", "thunder", "stone", "wind"},
    typeNames = {
        water = "Water Breathing",
        fire = "Fire Breathing", 
        thunder = "Thunder Breathing",
        stone = "Stone Breathing",
        wind = "Wind Breathing"
    }
}

-- Demo sequences with descriptions
local DemoSequences = {
    water = {
        {name = "Water Surface Slash", desc = "A horizontal slash that creates a water blade"},
        {name = "Water Wheel", desc = "A circular spinning attack"},
        {name = "Flowing Dance", desc = "Graceful continuous strikes"},
        {name = "Waterfall Basin", desc = "Powerful downward strike"},
        {name = "Constant Flux", desc = "Ultimate water technique"}
    },
    fire = {
        {name = "Unknowing Fire", desc = "Quick burst of flames"},
        {name = "Rising Scorching Sun", desc = "Upward flame arc"},
        {name = "Blazing Universe", desc = "360-degree fire attack"},
        {name = "Flame Tiger", desc = "Fierce charging attack"},
        {name = "Rengoku", desc = "Ultimate fire devastation"}
    },
    thunder = {
        {name = "Thunderclap and Flash", desc = "Lightning-fast dash"},
        {name = "Rice Spirit", desc = "Multiple lightning strikes"},
        {name = "Thunder Swarm", desc = "Area lightning barrage"},
        {name = "Distant Thunder", desc = "Long-range thunder attack"},
        {name = "Heat Lightning", desc = "Continuous lightning stream"}
    },
    stone = {
        {name = "Stone Skin", desc = "Defensive hardening"},
        {name = "Upper Smash", desc = "Powerful uppercut"},
        {name = "Stone Pillar", desc = "Earth eruption attack"},
        {name = "Volcanic Rock", desc = "Molten stone barrage"},
        {name = "Arcs of Justice", desc = "Ultimate stone technique"}
    },
    wind = {
        {name = "Dust Whirlwind Cutter", desc = "Spinning wind blades"},
        {name = "Claws-Purifying Wind", desc = "Sharp wind slashes"},
        {name = "Clean Storm Wind Tree", desc = "Tornado creation"},
        {name = "Rising Dust Storm", desc = "Upward wind vortex"},
        {name = "Cold Mountain Wind", desc = "Freezing wind blast"}
    }
}

-- Function to trigger level up visual and audio effects
local function TriggerLevelUpEffects(ply, level)
    if not IsValid(ply) then return end
    
    -- Sound effects based on milestone
    local sounds = {
        [5] = "ambient/energy/newspark01.wav",
        [10] = "ambient/energy/newspark03.wav",
        [25] = "ambient/energy/weld1.wav",
        [50] = "ambient/energy/whiteflash.wav",
        [100] = "ambient/explosions/exp2.wav"
    }
    
    local sound = sounds[level] or "ambient/energy/newspark01.wav"
    ply:EmitSound(sound, 75, 100)
    
    -- Visual effects
    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
    effectdata:SetNormal(Vector(0, 0, 1))
    
    -- Different effects for different milestones
    if level >= 100 then
        -- Grandmaster - massive effect
        effectdata:SetScale(3)
        effectdata:SetMagnitude(5)
        effectdata:SetRadius(100)
        util.Effect("TeslaHitboxes", effectdata)
        util.Effect("cball_explode", effectdata)
        
        -- Screen flash for the player
        ply:ScreenFade(SCREENFADE.IN, Color(255, 215, 0, 100), 0.5, 0.1)
        
        -- Notify all players
        for _, p in ipairs(player.GetAll()) do
            p:ChatPrint("⚡ " .. ply:Name() .. " has reached GRANDMASTER level!")
        end
    elseif level >= 50 then
        -- Master - large effect
        effectdata:SetScale(2)
        effectdata:SetMagnitude(3)
        util.Effect("TeslaHitboxes", effectdata)
        
        ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 80), 0.4, 0.1)
    elseif level >= 25 then
        -- Expert - medium effect
        effectdata:SetScale(1.5)
        util.Effect("StunstickImpact", effectdata)
        
        ply:ScreenFade(SCREENFADE.IN, Color(100, 200, 255, 60), 0.3, 0.1)
    else
        -- Lower levels - basic effect
        effectdata:SetScale(1)
        util.Effect("ManhackSparks", effectdata)
        
        ply:ScreenFade(SCREENFADE.IN, Color(100, 255, 100, 40), 0.2, 0.1)
    end
    
    -- Particle burst around player
    for i = 1, level / 10 do
        timer.Simple(i * 0.05, function()
            if not IsValid(ply) then return end
            
            local sparkEffect = EffectData()
            sparkEffect:SetOrigin(ply:GetPos() + Vector(math.random(-30, 30), math.random(-30, 30), math.random(20, 80)))
            sparkEffect:SetNormal(Vector(0, 0, 1))
            sparkEffect:SetScale(0.5)
            util.Effect("ManhackSparks", sparkEffect)
        end)
    end
    
    -- Temporary stat boost visual indicator
    ply:SetNWBool("LevelUpGlow", true)
    timer.Simple(1, function()
        if IsValid(ply) then
            ply:SetNWBool("LevelUpGlow", false)
        end
    end)
    
    -- Chat notification with stats
    local statBonus = level * 2
    ply:ChatPrint("💪 Stats increased! +" .. statBonus .. " to all attributes")
    
    -- Award skill points
    local skillPoints = math.floor(level / 5)
    if skillPoints > 0 then
        ply:ChatPrint("🎯 Earned " .. skillPoints .. " skill points!")
    end
    
    -- Unlock notification for special levels
    if level == 10 then
        ply:ChatPrint("🔓 Unlocked: Second Form Slot!")
    elseif level == 25 then
        ply:ChatPrint("🔓 Unlocked: Third Form Slot!")
    elseif level == 50 then
        ply:ChatPrint("🔓 Unlocked: Dual Breathing Styles!")
    elseif level == 100 then
        ply:ChatPrint("🔓 Unlocked: Create Custom Forms!")
    end
end

-- Function to demonstrate level up animations
local function DemoLevelUpSequence(ply)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("🎯 LEVEL UP DEMONSTRATION")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("")
    
    -- Reset player to low level for demonstration
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if playerData then
            playerData.level = 1
            playerData.xp = 0
            ply:SetNWInt("BreathingLevel", 1)
            ply:SetNWInt("BreathingXP", 0)
        end
    end
    
    -- Define milestone levels to showcase
    local milestones = {
        {level = 5, desc = "Novice → Apprentice", xp = 500},
        {level = 10, desc = "Apprentice → Adept", xp = 1500},
        {level = 25, desc = "Adept → Expert", xp = 5000},
        {level = 50, desc = "Expert → Master", xp = 15000},
        {level = 100, desc = "Master → Grandmaster", xp = 50000}
    }
    
    local currentMilestone = 1
    
    local function ShowNextLevelUp()
        if not IsValid(ply) or currentMilestone > #milestones then
            -- Demo complete
            if IsValid(ply) then
                timer.Simple(1, function()
                    if not IsValid(ply) then return end
                    
                    ply:ChatPrint("")
                    ply:ChatPrint("=====================================")
                    ply:ChatPrint("🏆 FULL DEMONSTRATION COMPLETE!")
                    ply:ChatPrint("All systems showcased successfully.")
                    ply:ChatPrint("=====================================")
                    
                    -- Reset to normal state
                    ply:ConCommand("bs_switch water")
                    
                    if BreathingSystem and BreathingSystem.PlayerRegistry then
                        local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
                        if playerData then
                            playerData.level = 10
                            playerData.xp = 1000
                            ply:SetNWInt("BreathingLevel", 10)
                            ply:SetNWInt("BreathingXP", 1000)
                        end
                    end
                end)
            end
            return
        end
        
        local milestone = milestones[currentMilestone]
        
        -- Announce the level up
        ply:ChatPrint("⬆️ LEVEL UP: " .. milestone.desc)
        ply:ChatPrint("📊 Reaching Level " .. milestone.level .. " (" .. milestone.xp .. " XP)")
        
        -- Trigger the level up
        if BreathingSystem and BreathingSystem.PlayerRegistry then
            local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
            if playerData then
                -- Set the new level
                playerData.level = milestone.level
                playerData.xp = milestone.xp
                ply:SetNWInt("BreathingLevel", milestone.level)
                ply:SetNWInt("BreathingXP", milestone.xp)
                
                -- Trigger level up effects
                TriggerLevelUpEffects(ply, milestone.level)
            end
        end
        
        -- Schedule next milestone
        currentMilestone = currentMilestone + 1
        timer.Simple(2, ShowNextLevelUp)
    end
    
    -- Start the sequence
    timer.Simple(1, ShowNextLevelUp)
end

-- Function to display demo information
local function ShowDemoInfo(ply, typeId, formNum, formName, formDesc)
    -- Clear previous messages
    ply:ChatPrint("")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("🎭 BREATHING SYSTEM DEMONSTRATION")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("")
    
    -- Show current breathing type
    local typeName = DemoState.typeNames[typeId] or typeId
    ply:ChatPrint("⚡ " .. string.upper(typeName))
    ply:ChatPrint("")
    
    -- Show form info
    ply:ChatPrint("📍 Form " .. formNum .. ": " .. formName)
    ply:ChatPrint("📝 " .. formDesc)
    ply:ChatPrint("")
    
    -- Progress indicator
    local totalTypes = #DemoState.types
    local totalForms = 5
    local currentProgress = ((DemoState.currentType - 1) * totalForms) + DemoState.currentForm
    local totalSteps = totalTypes * totalForms
    
    ply:ChatPrint("Progress: " .. currentProgress .. "/" .. totalSteps)
    ply:ChatPrint("=====================================")
    
    -- Also print to all players if in multiplayer
    for _, p in ipairs(player.GetAll()) do
        if p != ply then
            p:ChatPrint("[DEMO] " .. ply:Name() .. " is demonstrating: " .. typeName .. " - " .. formName)
        end
    end
end

-- Function to execute a single demo step
local function ExecuteDemoStep()
    if not DemoState.active or not IsValid(DemoState.player) then
        DemoState.active = false
        return
    end
    
    local ply = DemoState.player
    local typeId = DemoState.types[DemoState.currentType]
    local formNum = DemoState.currentForm
    
    -- Get form info
    local sequences = DemoSequences[typeId]
    local formInfo = sequences and sequences[formNum] or {name = "Form " .. formNum, desc = "Breathing technique"}
    
    -- Show demo information
    ShowDemoInfo(ply, typeId, formNum, formInfo.name, formInfo.desc)
    
    -- Set the breathing type if needed
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if playerData then
            -- Update breathing type
            if playerData.breathing_type ~= typeId then
                playerData.breathing_type = typeId
                ply:SetNWString("BreathingType", typeId)
                
                -- Visual feedback for type change
                ply:EmitSound("ambient/energy/whiteflash.wav", 75, 100)
            end
            
            -- Ensure player has enough stamina
            playerData.stamina = playerData.max_stamina or 100
            playerData.concentration = playerData.max_concentration or 100
            ply:SetNWInt("BreathingStamina", playerData.stamina)
            ply:SetNWInt("BreathingConcentration", playerData.concentration)
        end
    end
    
    -- Trigger the form effect
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        
        -- Use the form
        ply:ConCommand("bs_form " .. formNum)
        
        -- Create visual effect if available
        if BreathingSystem and BreathingSystem.CreateFormEffect then
            BreathingSystem.CreateFormEffect(ply, typeId, typeId .. "_form_" .. formNum)
        end
        
        -- Apply gameplay effects
        if ApplyFormGameplayEffects then
            ApplyFormGameplayEffects(ply, typeId, formNum)
        end
    end)
    
    -- Schedule next step
    timer.Simple(2, function()
        if not DemoState.active then return end
        
        -- Move to next form
        DemoState.currentForm = DemoState.currentForm + 1
        
        -- Check if we need to move to next type
        if DemoState.currentForm > 5 then
            DemoState.currentForm = 1
            DemoState.currentType = DemoState.currentType + 1
            
            -- Check if demo is complete
            if DemoState.currentType > #DemoState.types then
                -- Demo complete
                DemoState.active = false
                
                if IsValid(DemoState.player) then
                    DemoState.player:ChatPrint("")
                    DemoState.player:ChatPrint("=====================================")
                    DemoState.player:ChatPrint("✅ FORMS DEMONSTRATION COMPLETE!")
                    DemoState.player:ChatPrint("Now showcasing LEVEL UP animations...")
                    DemoState.player:ChatPrint("=====================================")
                    
                    -- Start level up demonstrations
                    timer.Simple(2, function()
                        DemoLevelUpSequence(DemoState.player)
                    end)
                end
                
                return
            end
        end
        
        -- Continue demo
        ExecuteDemoStep()
    end)
end

-- Start demo command
concommand.Add("bs_demo", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    -- Check if demo is already running
    if DemoState.active then
        ply:ChatPrint("[DEMO] Demo is already running!")
        return
    end
    
    -- Initialize demo state
    DemoState.active = true
    DemoState.player = ply
    DemoState.currentType = 1
    DemoState.currentForm = 1
    DemoState.startTime = CurTime()
    
    ply:ChatPrint("")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("🎬 STARTING BREATHING SYSTEM DEMO")
    ply:ChatPrint("This will showcase all 5 breathing types")
    ply:ChatPrint("with 5 forms each (25 total demonstrations)")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("")
    
    -- Ensure player has data
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        if not BreathingSystem.PlayerRegistry.GetPlayerData(ply) then
            BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
        end
        
        -- Unlock all forms for demo
        local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if playerData then
            playerData.forms_unlocked = {}
            for _, typeId in ipairs(DemoState.types) do
                for i = 1, 5 do
                    table.insert(playerData.forms_unlocked, typeId .. "_form_" .. i)
                end
            end
            
            -- Set player to max level for demo
            playerData.level = 100
            playerData.xp = 99999
            ply:SetNWInt("BreathingLevel", 100)
            ply:SetNWInt("BreathingXP", 99999)
        end
    end
    
    -- Start the demo after a brief delay
    timer.Simple(2, function()
        ExecuteDemoStep()
    end)
end, nil, "Start the breathing system demonstration")

-- Stop demo command
concommand.Add("bs_demo_stop", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    if DemoState.active and DemoState.player == ply then
        DemoState.active = false
        ply:ChatPrint("[DEMO] Demonstration stopped.")
    else
        ply:ChatPrint("[DEMO] No active demonstration to stop.")
    end
end, nil, "Stop the current demonstration")

-- Quick demo (only shows one form per type)
concommand.Add("bs_demo_quick", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    if DemoState.active then
        ply:ChatPrint("[DEMO] Demo is already running!")
        return
    end
    
    ply:ChatPrint("")
    ply:ChatPrint("=====================================")
    ply:ChatPrint("⚡ QUICK DEMO - One form per type")
    ply:ChatPrint("=====================================")
    
    local types = {"water", "fire", "thunder", "stone", "wind"}
    local delay = 0
    
    -- Ensure player setup
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        if not BreathingSystem.PlayerRegistry.GetPlayerData(ply) then
            BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
        end
    end
    
    for i, typeId in ipairs(types) do
        timer.Simple(delay, function()
            if not IsValid(ply) then return end
            
            -- Switch type
            ply:ConCommand("bs_switch " .. typeId)
            
            -- Show info
            ply:ChatPrint("")
            ply:ChatPrint("[" .. i .. "/5] " .. string.upper(DemoState.typeNames[typeId]))
            
            -- Use form after switch
            timer.Simple(0.5, function()
                if not IsValid(ply) then return end
                ply:ConCommand("bs_form 1")
                
                if BreathingSystem and BreathingSystem.CreateFormEffect then
                    BreathingSystem.CreateFormEffect(ply, typeId, typeId .. "_form_1")
                end
            end)
        end)
        
        delay = delay + 2
    end
    
    timer.Simple(delay + 1, function()
        if IsValid(ply) then
            ply:ChatPrint("")
            ply:ChatPrint("=====================================")
            ply:ChatPrint("✅ QUICK DEMO COMPLETE!")
            ply:ChatPrint("=====================================")
        end
    end)
end, nil, "Quick demo - one form per breathing type")

-- Standalone level up demo
concommand.Add("bs_demo_levelup", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[DEMO] Starting level up demonstration...")
    
    -- Ensure player has data
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        if not BreathingSystem.PlayerRegistry.GetPlayerData(ply) then
            BreathingSystem.PlayerRegistry.RegisterPlayer(ply)
        end
    end
    
    DemoLevelUpSequence(ply)
end, nil, "Demonstrate level up animations")

-- Single level up test
concommand.Add("bs_test_levelup", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local targetLevel = tonumber(args[1]) or 10
    
    ply:ChatPrint("[TEST] Triggering level " .. targetLevel .. " animation...")
    
    -- Ensure player has data
    if BreathingSystem and BreathingSystem.PlayerRegistry then
        local playerData = BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        if playerData then
            playerData.level = targetLevel
            playerData.xp = targetLevel * 100
            ply:SetNWInt("BreathingLevel", targetLevel)
            ply:SetNWInt("BreathingXP", targetLevel * 100)
        end
    end
    
    -- Trigger the effects
    TriggerLevelUpEffects(ply, targetLevel)
end, nil, "Test a specific level up: bs_test_levelup [level]")

print("[BreathingSystem] Demo system loaded")
print("[BreathingSystem] Commands: bs_demo (full), bs_demo_quick (quick), bs_demo_levelup (levels), bs_demo_stop")
print("[BreathingSystem] Test commands: bs_test_levelup [level]") 