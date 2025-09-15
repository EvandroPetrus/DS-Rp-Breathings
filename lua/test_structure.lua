-- Simple test to verify addon structure
print("[BreathingSystem] Testing addon structure...")

-- Test if core modules exist
if file.Exists("lua/core/init.lua", "GAME") then
    print("[BreathingSystem] ✓ Core init found")
else
    print("[BreathingSystem] ✗ Core init missing")
end

if file.Exists("lua/breathing_types/water.lua", "GAME") then
    print("[BreathingSystem] ✓ Water breathing type found")
else
    print("[BreathingSystem] ✗ Water breathing type missing")
end

if file.Exists("lua/effects/particles.lua", "GAME") then
    print("[BreathingSystem] ✓ Particle effects found")
else
    print("[BreathingSystem] ✗ Particle effects missing")
end

print("[BreathingSystem] Structure test complete!")
