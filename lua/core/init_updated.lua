--[[
    BreathingSystem Core - Main Entry Point
]]

-- Global table initialization
BreathingSystem = BreathingSystem or {}

-- Version info
BreathingSystem.Version = "1.0.0"
BreathingSystem.Author = "Your Name"

print("[BreathingSystem] Initializing core system...")

-- Load core modules (server-side only)
if SERVER then
    -- Core modules first
    include("core/config.lua")
    include("core/breathing_types_manager.lua")
    include("core/player_registry.lua")
    include("core/forms.lua")
    include("core/autotest.lua")      -- Add auto test system
    include("core/quickmenu.lua")     -- Add quick menu system
    
    -- Load breathing types (they will self-register)
    include("breathing_types/water.lua")
    -- include("breathing_types/fire.lua")     -- Uncomment when ready
    -- include("breathing_types/thunder.lua")  -- Uncomment when ready
    -- include("breathing_types/stone.lua")    -- Uncomment when ready
    -- include("breathing_types/wind.lua")     -- Uncomment when ready
    
    -- Load mechanics modules
    include("mechanics/stamina.lua")
    include("mechanics/cooldowns.lua")
    include("mechanics/prerequisites.lua")
    include("mechanics/damage.lua")
    
    -- Load progression modules
    include("progression/training.lua")
    include("progression/levels.lua")
    include("progression/concentration.lua")
    
    -- Load effects modules
    include("effects/particles.lua")
    include("effects/sounds.lua")
    include("effects/animations.lua")
    
    -- Load combat modules
    include("combat/pvp_integration.lua")
    include("combat/status_effects.lua")
    
    -- Load admin modules
    include("admin/balance_tools.lua")
    include("admin/logging.lua")
    
    -- Load UI modules (client-side)
    AddCSLuaFile("ui/hud.lua")
    AddCSLuaFile("ui/menus.lua")
    
    print("[BreathingSystem] All modules loaded successfully!")
end

-- Rest of the file remains the same...
