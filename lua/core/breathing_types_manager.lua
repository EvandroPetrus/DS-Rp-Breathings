--[[
    BreathingSystem - Breathing Types Manager
    =========================================
    
    This module manages all breathing types and their forms.
]]

-- Initialize breathing types module
BreathingSystem.BreathingTypes = BreathingSystem.BreathingTypes or {}

-- Storage for breathing types and forms
BreathingSystem.BreathingTypes.Types = BreathingSystem.BreathingTypes.Types or {}
BreathingSystem.BreathingTypes.Forms = BreathingSystem.BreathingTypes.Forms or {}

-- Register a breathing type
function BreathingSystem.BreathingTypes.RegisterType(id, data)
    if not id or not data then
        print("[BreathingSystem.BreathingTypes] Error: Invalid type registration")
        return false
    end
    
    -- Store the type
    BreathingSystem.BreathingTypes.Types[id] = data
    
    -- Also register with Config if it exists
    if BreathingSystem.Config and BreathingSystem.Config.RegisterBreathingType then
        BreathingSystem.Config.RegisterBreathingType(id, data)
    end
    
    print("[BreathingSystem.BreathingTypes] Registered breathing type: " .. id .. " (" .. (data.name or id) .. ")")
    
    return true
end

-- Register a form
function BreathingSystem.BreathingTypes.RegisterForm(breathingType, formData)
    if not breathingType or not formData then
        print("[BreathingSystem.BreathingTypes] Error: Invalid form registration")
        return false
    end
    
    -- Initialize forms table for this breathing type if needed
    if not BreathingSystem.BreathingTypes.Forms[breathingType] then
        BreathingSystem.BreathingTypes.Forms[breathingType] = {}
    end
    
    -- Store the form
    local formId = formData.id or (breathingType .. "_form_" .. table.Count(BreathingSystem.BreathingTypes.Forms[breathingType]))
    BreathingSystem.BreathingTypes.Forms[breathingType][formId] = formData
    
    -- Also register with Forms module if it exists
    if BreathingSystem.Forms and BreathingSystem.Forms.RegisterForm then
        BreathingSystem.Forms.RegisterForm(formId, formData)
    end
    
    return true
end

-- Get all breathing types
function BreathingSystem.BreathingTypes.GetAllTypes()
    return BreathingSystem.BreathingTypes.Types or {}
end

-- Get a specific breathing type
function BreathingSystem.BreathingTypes.GetType(id)
    if not id then return nil end
    return BreathingSystem.BreathingTypes.Types[id]
end

-- Get forms for a breathing type
function BreathingSystem.BreathingTypes.GetForms(breathingType)
    if not breathingType then return {} end
    return BreathingSystem.BreathingTypes.Forms[breathingType] or {}
end

-- Get a specific form
function BreathingSystem.BreathingTypes.GetForm(breathingType, formId)
    if not breathingType or not formId then return nil end
    
    local forms = BreathingSystem.BreathingTypes.GetForms(breathingType)
    return forms[formId]
end

print("[BreathingSystem.BreathingTypes] Breathing types manager loaded")
