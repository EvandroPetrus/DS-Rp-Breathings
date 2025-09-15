--[[
    BreathingSystem - Admin HUD Initialization
    ==========================================
    
    Properly loads admin HUD on both client and server
]]

if SERVER then
    print("[BreathingSystem] Loading admin HUD server-side...")
    
    -- Include server-side admin HUD
    include("admin/admin_hud.lua")
    
    -- Send client file to clients
    AddCSLuaFile("admin/admin_hud_client.lua")
    
    print("[BreathingSystem] Admin HUD server-side loaded")
end

if CLIENT then
    print("[BreathingSystem] Loading admin HUD client-side...")
    
    -- Include client-side admin HUD
    include("admin/admin_hud_client.lua")
    
    print("[BreathingSystem] Admin HUD client-side loaded")
end 