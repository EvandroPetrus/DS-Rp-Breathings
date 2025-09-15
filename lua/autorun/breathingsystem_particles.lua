--[[
    BreathingSystem - Visual Particle Effects
    =========================================
    Creates actual particle effects when using breathing forms
]]

if SERVER then
    -- Particle effect configurations for each breathing type
    local ParticleEffects = {
        water = {
            color = Color(0, 150, 255),
            material = "effects/splash2",
            size = 30,
            lifetime = 2,
            count = 20
        },
        fire = {
            color = Color(255, 100, 0),
            material = "effects/fire_cloud1",
            size = 40,
            lifetime = 1.5,
            count = 15
        },
        thunder = {
            color = Color(255, 255, 0),
            material = "effects/spark",
            size = 20,
            lifetime = 0.5,
            count = 30
        },
        stone = {
            color = Color(128, 128, 128),
            material = "effects/fleck_cement2",
            size = 25,
            lifetime = 3,
            count = 25
        },
        wind = {
            color = Color(200, 200, 255),
            material = "effects/splash4",
            size = 35,
            lifetime = 1.8,
            count = 18
        }
    }
    
    -- Function to create particle effect
    local function CreateBreathingParticles(ply, breathingType)
        if not IsValid(ply) then return end
        
        local config = ParticleEffects[breathingType]
        if not config then
            config = ParticleEffects.water -- Default to water
        end
        
        local pos = ply:GetPos() + Vector(0, 0, 40)
        local effectdata = EffectData()
        
        -- Create main burst effect
        effectdata:SetOrigin(pos)
        effectdata:SetNormal(ply:GetAimVector())
        effectdata:SetScale(config.size)
        effectdata:SetRadius(config.size * 2)
        effectdata:SetMagnitude(config.count)
        
        -- Use different effects based on breathing type
        if breathingType == "fire" then
            util.Effect("Explosion", effectdata)
            
            -- Add fire particles
            for i = 1, 10 do
                timer.Simple(i * 0.1, function()
                    if not IsValid(ply) then return end
                    local firePos = ply:GetPos() + Vector(math.random(-30, 30), math.random(-30, 30), 40)
                    local fire = EffectData()
                    fire:SetOrigin(firePos)
                    fire:SetScale(10)
                    util.Effect("MuzzleFlash", fire)
                end)
            end
        elseif breathingType == "thunder" then
            util.Effect("StunstickImpact", effectdata)
            
            -- Add lightning sparks
            for i = 1, 5 do
                local sparkPos = pos + Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 50))
                local spark = EffectData()
                spark:SetOrigin(sparkPos)
                spark:SetNormal(Vector(0, 0, 1))
                spark:SetMagnitude(5)
                spark:SetScale(5)
                spark:SetRadius(10)
                util.Effect("Sparks", spark)
            end
            
            -- Screen flash for nearby players
            for _, target in ipairs(player.GetAll()) do
                if target:GetPos():Distance(ply:GetPos()) < 300 then
                    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 100, 50), 0.1, 0)
                end
            end
        elseif breathingType == "water" then
            util.Effect("watersplash", effectdata)
            
            -- Add water droplets
            for i = 1, 15 do
                timer.Simple(i * 0.05, function()
                    if not IsValid(ply) then return end
                    local waterPos = ply:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), 30 + i * 5)
                    local water = EffectData()
                    water:SetOrigin(waterPos)
                    water:SetScale(3)
                    util.Effect("waterripple", water)
                end)
            end
        elseif breathingType == "stone" then
            util.Effect("GlassImpact", effectdata)
            
            -- Add dust and debris
            local dust = EffectData()
            dust:SetOrigin(ply:GetPos())
            dust:SetNormal(Vector(0, 0, 1))
            dust:SetScale(100)
            util.Effect("ThumperDust", dust)
            
            -- Screen shake for nearby players
            util.ScreenShake(ply:GetPos(), 5, 5, 1, 300)
        elseif breathingType == "wind" then
            -- Create swirling effect
            for i = 1, 20 do
                timer.Simple(i * 0.05, function()
                    if not IsValid(ply) then return end
                    local angle = (i * 18) % 360
                    local radius = 30 + i * 2
                    local windPos = ply:GetPos() + Vector(math.cos(math.rad(angle)) * radius, math.sin(math.rad(angle)) * radius, 20 + i * 3)
                    
                    local wind = EffectData()
                    wind:SetOrigin(windPos)
                    wind:SetNormal((windPos - ply:GetPos()):GetNormalized())
                    wind:SetScale(5)
                    util.Effect("AirboatMuzzle", wind)
                end)
            end
        end
        
        -- Add colored smoke for all types
        local smoke = EffectData()
        smoke:SetOrigin(pos)
        smoke:SetScale(20)
        smoke:SetMagnitude(10)
        smoke:SetColor(config.color.r)
        util.Effect("bloodspray", smoke)
        
        -- Emit sound
        ply:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 75, math.random(90, 110))
    end
    
    -- Enhanced bs_use command with particles
    concommand.Add("bs_use_form", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local breathingType = ply:GetNWString("BreathingType", "water")
        local currentStamina = ply:GetNWInt("BreathingStamina", 100)
        local cost = 25
        
        -- Check which form to use (if specified)
        local formNumber = tonumber(args[1]) or 1
        
        if currentStamina >= cost then
            -- Drain stamina
            ply:SetNWInt("BreathingStamina", currentStamina - cost)
            
            -- Create particle effects
            CreateBreathingParticles(ply, breathingType)
            
            -- Apply form effects based on type
            if breathingType == "fire" then
                -- Fire damage to nearby enemies
                for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
                    if ent:IsNPC() or (ent:IsPlayer() and ent != ply) then
                        ent:Ignite(3)
                        ent:TakeDamage(10, ply, ply)
                    end
                end
                ply:ChatPrint("[Fire Form " .. formNumber .. "] Unleashed flames!")
                
            elseif breathingType == "thunder" then
                -- Speed boost
                ply:SetWalkSpeed(400)
                ply:SetRunSpeed(600)
                timer.Simple(3, function()
                    if IsValid(ply) then
                        ply:SetWalkSpeed(200)
                        ply:SetRunSpeed(400)
                    end
                end)
                ply:ChatPrint("[Thunder Form " .. formNumber .. "] Lightning speed activated!")
                
            elseif breathingType == "water" then
                -- Healing
                ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 20))
                ply:ChatPrint("[Water Form " .. formNumber .. "] Healing waters flow!")
                
            elseif breathingType == "stone" then
                -- Damage reduction
                ply:SetArmor(math.min(100, ply:Armor() + 25))
                ply:ChatPrint("[Stone Form " .. formNumber .. "] Stone skin activated!")
                
            elseif breathingType == "wind" then
                -- Launch upward
                ply:SetVelocity(Vector(0, 0, 400))
                ply:ChatPrint("[Wind Form " .. formNumber .. "] Wind burst!")
            end
            
            -- Visual feedback on HUD
            ply:SetNWFloat("LastFormUse", CurTime())
            ply:SetNWInt("LastFormNumber", formNumber)
            
        else
            ply:ChatPrint("[BreathingSystem] Not enough stamina! Need " .. cost .. ", have " .. currentStamina)
            ply:EmitSound("buttons/button10.wav", 75, 100)
        end
    end)
    
    -- Quick switch breathing type command
    concommand.Add("bs_switch", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local types = {"water", "fire", "thunder", "stone", "wind"}
        local newType = args[1]
        
        if not newType then
            -- Cycle to next type
            local current = ply:GetNWString("BreathingType", "water")
            local index = table.KeyFromValue(types, current) or 1
            index = (index % #types) + 1
            newType = types[index]
        end
        
        if table.HasValue(types, newType) then
            ply:SetNWString("BreathingType", newType)
            
            -- Update player data if system exists
            if BreathingSystem and BreathingSystem.GetPlayerData then
                local data = BreathingSystem.GetPlayerData(ply)
                if data then
                    data.breathing_type = newType
                end
            end
            
            -- Create switch effect
            CreateBreathingParticles(ply, newType)
            
            ply:ChatPrint("[BreathingSystem] Switched to " .. newType:upper() .. " breathing!")
        else
            ply:ChatPrint("Invalid type! Use: water, fire, thunder, stone, or wind")
        end
    end)
    
    print("[BreathingSystem] Particle effects system loaded")
    print("  Commands:")
    print("    bs_use_form [number] - Use a breathing form with effects")
    print("    bs_switch [type] - Switch breathing type")
    print("    G key - Quick use form")
end

-- Update the G key to use the new command
if CLIENT then
    hook.Add("PlayerButtonDown", "BreathingSystem_FormKey", function(ply, button)
        if button == KEY_G then
            RunConsoleCommand("bs_use_form", "1")
        elseif button == KEY_H then
            RunConsoleCommand("bs_switch")
        end
    end)
    
    print("[BreathingSystem] Client keys bound:")
    print("  G - Use breathing form")
    print("  H - Switch breathing type")
end
