--[[
    BreathingSystem - Auto Test Script
    ==================================
    
    This script automatically runs all test commands to verify the addon is working.
    Can be triggered manually or automatically on server start.
]]

-- Only run on server
if not SERVER then return end

-- Auto test function
function BreathingSystem.RunAutoTest(ply)
    local isConsole = not IsValid(ply)
    
    local function output(msg)
        if isConsole then
            print(msg)
        else
            ply:ChatPrint(msg)
        end
    end
    
    output("========================================")
    output("BREATHINGSYSTEM AUTO-TEST STARTING")
    output("========================================")
    
    -- Test 1: Check if modules loaded
    output("")
    output("[TEST 1] Checking modules...")
    local modules = {
        {"Core", BreathingSystem},
        {"PlayerRegistry", BreathingSystem.PlayerRegistry},
        {"BreathingTypes", BreathingSystem.BreathingTypes},
        {"Config", BreathingSystem.Config},
        {"Forms", BreathingSystem.Forms},
        {"Particles", BreathingSystem.Particles},
        {"Sounds", BreathingSystem.Sounds},
        {"Animations", BreathingSystem.Animations}
    }
    
    local allLoaded = true
    for _, module in ipairs(modules) do
        if module[2] then
            output("  ✓ " .. module[1] .. " loaded")
        else
            output("  ✗ " .. module[1] .. " MISSING")
            allLoaded = false
        end
    end
    
    -- Test 2: Check breathing types
    output("")
    output("[TEST 2] Checking breathing types...")
    local types = BreathingSystem.GetBreathingTypes()
    local typeCount = table.Count(types)
    output("  Found " .. typeCount .. " breathing types:")
    for name, data in pairs(types) do
        output("    - " .. name)
    end
    
    -- Test 3: Check forms
    output("")
    output("[TEST 3] Checking forms...")
    local totalForms = 0
    for typeName, _ in pairs(types) do
        local forms = BreathingSystem.GetForms(typeName)
        local formCount = table.Count(forms)
        totalForms = totalForms + formCount
        output("  " .. typeName .. ": " .. formCount .. " forms")
    end
    output("  Total forms: " .. totalForms)
    
    -- Test 4: Player data test (if player available)
    if not isConsole then
        output("")
        output("[TEST 4] Testing player data...")
        local playerData = BreathingSystem.GetPlayerData(ply)
        if playerData then
            output("  ✓ Player data accessible")
            output("    - Level: " .. (playerData.level or 1))
            output("    - Stamina: " .. (playerData.stamina or 100))
            output("    - Breathing Type: " .. (playerData.breathing_type or "none"))
        else
            output("  ✗ Player data not found")
        end
    end
    
    -- Test 5: Commands test
    output("")
    output("[TEST 5] Checking commands...")
    local commands = {
        "breathingsystem_test",
        "breathingsystem_set",
        "breathingsystem_list_types",
        "breathingsystem_list_forms",
        "breathingsystem_test_damage",
        "breathingsystem_test_effects",
        "breathingsystem_autotest",
        "breathingsystem_menu"
    }
    
    for _, cmd in ipairs(commands) do
        if concommand.GetTable()[cmd] then
            output("  ✓ " .. cmd)
        else
            output("  ✗ " .. cmd .. " MISSING")
        end
    end
    
    -- Summary
    output("")
    output("========================================")
    if allLoaded and typeCount > 0 and totalForms > 0 then
        output("AUTO-TEST PASSED - System is working!")
    else
        output("AUTO-TEST FAILED - Check errors above")
    end
    output("========================================")
end

-- Register auto test command
concommand.Add("breathingsystem_autotest", function(ply, cmd, args)
    BreathingSystem.RunAutoTest(ply)
end)

-- Run auto test on server start (after a delay to ensure everything loads)
timer.Simple(5, function()
    print("[BreathingSystem] Running automatic system test...")
    BreathingSystem.RunAutoTest()
end)

print("[BreathingSystem.AutoTest] Auto test system loaded")
