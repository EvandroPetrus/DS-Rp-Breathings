--[[
    BreathingSystem Core - Forms Module
    ==================================
    
    This module handles breathing forms (techniques) definitions and registration.
    
    Responsibilities:
    - Store and manage breathing form definitions
    - Provide form registration helper functions
    - Handle form validation and lookup
    - Manage form categories and metadata
    
    Public API:
    - BreathingSystem.Forms.Forms - Table of registered forms
    - BreathingSystem.Forms.RegisterForm(id, data) - Register new form
    - BreathingSystem.Forms.GetForm(id) - Get form data
    - BreathingSystem.Forms.GetAll() - Get all forms
    - BreathingSystem.Forms.GetFormsByCategory(category) - Get forms by category
    
    Example Usage:
    - BreathingSystem.Forms.RegisterForm("box_breathing", {name = "Box Breathing", ...})
    - local form = BreathingSystem.Forms.GetForm("box_breathing")
    - local allForms = BreathingSystem.Forms.GetAll()
]]

-- Initialize forms module
BreathingSystem.Forms = BreathingSystem.Forms or {}

-- Forms registry
BreathingSystem.Forms.Forms = BreathingSystem.Forms.Forms or {}

-- Form categories
BreathingSystem.Forms.Categories = {
    "meditation",
    "combat",
    "relaxation",
    "focus",
    "recovery",
    "custom"
}

-- Register a new breathing form
function BreathingSystem.Forms.RegisterForm(id, data)
    if not id or type(id) ~= "string" then
        print("[BreathingSystem.Forms] Error: Invalid form ID")
        return false
    end
    
    if not data or type(data) ~= "table" then
        print("[BreathingSystem.Forms] Error: Invalid form data")
        return false
    end
    
    -- Validate the form data
    if not BreathingSystem.Forms.ValidateForm(data) then
        print("[BreathingSystem.Forms] Error: Invalid form data for '" .. id .. "'")
        return false
    end
    
    -- Set default values
    data.id = id
    data.name = data.name or "Unnamed Form"
    data.description = data.description or "No description available"
    data.category = data.category or "custom"
    data.difficulty = data.difficulty or 1 -- 1-5 scale
    data.duration = data.duration or 0 -- 0 = indefinite
    data.instructions = data.instructions or {}
    data.requirements = data.requirements or {}
    
    -- Register the form
    BreathingSystem.Forms.Forms[id] = data
    
    print("[BreathingSystem.Forms] Registered form: " .. id .. " (" .. data.name .. ")")
    return true
end

-- Get form data
function BreathingSystem.Forms.GetForm(id)
    if not id or type(id) ~= "string" then
        return nil
    end
    
    return BreathingSystem.Forms.Forms[id]
end

-- Get all forms
function BreathingSystem.Forms.GetAll()
    return BreathingSystem.Forms.Forms
end

-- Get forms by category
function BreathingSystem.Forms.GetFormsByCategory(category)
    if not category or type(category) ~= "string" then
        return {}
    end
    
    local forms = {}
    for id, form in pairs(BreathingSystem.Forms.Forms) do
        if form.category == category then
            forms[id] = form
        end
    end
    
    return forms
end

-- Check if form exists
function BreathingSystem.Forms.FormExists(id)
    return BreathingSystem.Forms.Forms[id] ~= nil
end

-- Validate form data
function BreathingSystem.Forms.ValidateForm(data)
    if not data or type(data) ~= "table" then
        return false
    end
    
    -- Validate category
    if data.category and not table.HasValue(BreathingSystem.Forms.Categories, data.category) then
        print("[BreathingSystem.Forms] Warning: Unknown category '" .. data.category .. "'")
    end
    
    -- Validate difficulty
    if data.difficulty and (type(data.difficulty) ~= "number" or data.difficulty < 1 or data.difficulty > 5) then
        return false
    end
    
    -- Validate duration
    if data.duration and (type(data.duration) ~= "number" or data.duration < 0) then
        return false
    end
    
    -- Validate instructions
    if data.instructions and type(data.instructions) ~= "table" then
        return false
    end
    
    -- Validate requirements
    if data.requirements and type(data.requirements) ~= "table" then
        return false
    end
    
    return true
end

-- Get form categories
function BreathingSystem.Forms.GetCategories()
    return BreathingSystem.Forms.Categories
end

-- Search forms by name or description
function BreathingSystem.Forms.SearchForms(query)
    if not query or type(query) ~= "string" then
        return {}
    end
    
    local results = {}
    local lowerQuery = string.lower(query)
    
    for id, form in pairs(BreathingSystem.Forms.Forms) do
        local name = string.lower(form.name or "")
        local description = string.lower(form.description or "")
        
        if string.find(name, lowerQuery) or string.find(description, lowerQuery) then
            results[id] = form
        end
    end
    
    return results
end

-- Initialize default forms
if SERVER then
    timer.Simple(0, function()
        -- Box Breathing
        BreathingSystem.Forms.RegisterForm("box_breathing", {
            name = "Box Breathing",
            description = "A simple 4-4-4-4 breathing pattern for relaxation and focus",
            category = "meditation",
            difficulty = 1,
            duration = 300, -- 5 minutes
            instructions = {
                "Inhale for 4 counts",
                "Hold for 4 counts", 
                "Exhale for 4 counts",
                "Hold for 4 counts",
                "Repeat"
            },
            requirements = {}
        })
        
        -- Combat Breathing
        BreathingSystem.Forms.RegisterForm("combat_breathing", {
            name = "Combat Breathing",
            description = "Quick breathing technique for high-stress situations",
            category = "combat",
            difficulty = 2,
            duration = 60, -- 1 minute
            instructions = {
                "Quick inhale through nose",
                "Sharp exhale through mouth",
                "Maintain steady rhythm",
                "Focus on control"
            },
            requirements = {}
        })
        
        -- Deep Breathing
        BreathingSystem.Forms.RegisterForm("deep_breathing", {
            name = "Deep Breathing",
            description = "Slow, deep breaths for maximum relaxation",
            category = "relaxation",
            difficulty = 1,
            duration = 0, -- Indefinite
            instructions = {
                "Breathe in slowly and deeply",
                "Fill your lungs completely",
                "Exhale slowly and completely",
                "Focus on the breath"
            },
            requirements = {}
        })
        
        -- Focus Breathing
        BreathingSystem.Forms.RegisterForm("focus_breathing", {
            name = "Focus Breathing",
            description = "Breathing technique to improve concentration and mental clarity",
            category = "focus",
            difficulty = 3,
            duration = 600, -- 10 minutes
            instructions = {
                "Inhale for 6 counts",
                "Hold for 2 counts",
                "Exhale for 8 counts",
                "Focus on a single point",
                "Maintain steady rhythm"
            },
            requirements = {}
        })
        
        print("[BreathingSystem.Forms] Default forms registered")
    end)
end

print("[BreathingSystem.Forms] Forms module loaded")
