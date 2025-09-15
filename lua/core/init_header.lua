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
    include("core/network_sync.lua")  -- Add network syncing
    
    -- Load breathing types (they will self-register)
    include("breathing_types/water.lua")
    
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
    
    -- Load testing modules AFTER everything else
    include("core/autotest.lua")
    include("core/quickmenu.lua")
    
    -- Load UI modules (send to client)
    AddCSLuaFile("ui/hud.lua")
    AddCSLuaFile("ui/menus.lua")
    
    print("[BreathingSystem] All modules loaded successfully!")
end
