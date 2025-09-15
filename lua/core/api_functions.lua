-- Global API functions
function BreathingSystem.GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    if not BreathingSystem.PlayerRegistry or not BreathingSystem.PlayerRegistry.GetPlayerData then
        return nil
    end
    return BreathingSystem.PlayerRegistry.GetPlayerData(ply)
end

function BreathingSystem.SetPlayerBreathing(ply, breathingType)
    if not IsValid(ply) then return false end
    if not BreathingSystem.PlayerRegistry or not BreathingSystem.PlayerRegistry.SetPlayerBreathing then
        return false
    end
    return BreathingSystem.PlayerRegistry.SetPlayerBreathing(ply, breathingType)
end

function BreathingSystem.RegisterBreathingType(name, config)
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.RegisterType then
        return false
    end
    return BreathingSystem.BreathingTypes.RegisterType(name, config)
end

function BreathingSystem.GetBreathingTypes()
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.GetAllTypes then
        return {}
    end
    return BreathingSystem.BreathingTypes.GetAllTypes()
end

function BreathingSystem.GetForms(breathingType)
    if not BreathingSystem.BreathingTypes or not BreathingSystem.BreathingTypes.GetForms then
        return {}
    end
    return BreathingSystem.BreathingTypes.GetForms(breathingType)
end
