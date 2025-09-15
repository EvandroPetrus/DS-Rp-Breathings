--[[
    BreathingSystem - Enhanced Effects System
    ==========================================
    Uses Garry's Mod default effects, sounds, and animations
]]

if SERVER then
    -- Enhanced particle configuration with GMod defaults
    local ParticleEffects = {
        water = {
            color = Color(0, 150, 255, 255),
            effects = {
                "WheelDust",           -- Water spray effect
                "watersplash",         -- Water splash
                "water_splash_01",     -- Water impact
            },
            sounds = {
                "ambient/water/water_splash1.wav",
                "ambient/water/water_splash2.wav",
                "ambient/water/water_splash3.wav",
                "ambient/water/water_spray1.wav",
                "ambient/water/wave1.wav",
            },
            ambientSound = "ambient/water/underwater.wav"
        },
        fire = {
            color = Color(255, 100, 0, 255),
            effects = {
                "fire_medium_01",      -- Medium fire effect
                "fire_large_01",       -- Large fire effect
                "burning_character",   -- Burning effect
                "Sparks",             -- Spark effect
            },
            sounds = {
                "ambient/fire/fire_small1.wav",
                "ambient/fire/fire_med_loop1.wav",
                "ambient/fire/ignite.wav",
                "ambient/fire/mtov_flame2.wav",
            },
            ambientSound = "ambient/fire/fire_small_loop2.wav"
        },
        thunder = {
            color = Color(255, 255, 0, 255),
            effects = {
                "StunstickImpact",    -- Electric impact
                "TeslaHitboxes",      -- Tesla effect
                "TeslaZap",           -- Electric zap
                "cball_explode",      -- Energy explosion
                "cball_bounce",       -- Energy bounce
            },
            sounds = {
                "ambient/energy/spark1.wav",
                "ambient/energy/spark2.wav",
                "ambient/energy/spark3.wav",
                "ambient/energy/zap1.wav",
                "ambient/energy/zap2.wav",
                "ambient/energy/zap3.wav",
                "ambient/atmosphere/thunder1.wav",
                "ambient/atmosphere/thunder2.wav",
            },
            ambientSound = "ambient/energy/electric_loop.wav"
        },
        stone = {
            color = Color(139, 90, 43, 255),
            effects = {
                "GlassImpact",        -- Stone impact
                "Impact",             -- Heavy impact
                "WheelDust",          -- Dust effect
                "smoke_medium_02b",   -- Dust cloud
            },
            sounds = {
                "ambient/materials/rock1.wav",
                "ambient/materials/rock2.wav",
                "ambient/materials/rock3.wav",
                "physics/concrete/concrete_impact_hard1.wav",
                "physics/concrete/concrete_impact_hard2.wav",
            },
            ambientSound = "ambient/atmosphere/cave_hit1.wav"
        },
        wind = {
            color = Color(150, 255, 150, 255),
            effects = {
                "AirboatMuzzle",      -- Air blast
                "ChopperMuzzleFlash", -- Wind burst
                "HelicopterMegaBomb", -- Wind explosion
                "smoke_small_01b",    -- Wind smoke
            },
            sounds = {
                "ambient/wind/wind_hit1.wav",
                "ambient/wind/wind_hit2.wav",
                "ambient/wind/wind_hit3.wav",
                "ambient/atmosphere/hole_hit1.wav",
                "ambient/levels/canals/tunnel_wind_loop1.wav",
            },
            ambientSound = "ambient/wind/wind_med1.wav"
        }
    }
    
    -- Create breathing particles with multiple effects
    local function CreateBreathingParticles(ply, breathingType)
        if not IsValid(ply) then return end
        
        local config = ParticleEffects[breathingType]
        if not config then 
            config = ParticleEffects["water"] -- Default to water
        end
        
        local pos = ply:GetPos()
        local forward = ply:GetForward()
        
        -- Create multiple particle effects
        for i, effectName in ipairs(config.effects) do
            timer.Simple(i * 0.1, function()
                if not IsValid(ply) then return end
                
                local effectData = EffectData()
                effectData:SetOrigin(pos + Vector(0, 0, 40) + forward * (20 + i * 10))
                effectData:SetNormal(forward)
                effectData:SetScale(1 + (i * 0.5))
                effectData:SetMagnitude(100)
                effectData:SetRadius(50)
                effectData:SetAngles(ply:GetAngles())
                effectData:SetEntity(ply)
                
                -- Add color if supported
                if config.color then
                    effectData:SetColor(config.color.r)
                end
                
                util.Effect(effectName, effectData, true, true)
            end)
        end
        
        -- Play random sound effect
        if config.sounds and #config.sounds > 0 then
            local sound = config.sounds[math.random(#config.sounds)]
            ply:EmitSound(sound, 75, math.random(90, 110), 0.8)
        end
        
        -- Create ambient effect
        CreateAmbientEffect(ply, breathingType)
    end
    
    -- Create ambient effects around the player
    local function CreateAmbientEffect(ply, breathingType)
        if not IsValid(ply) then return end
        
        local config = ParticleEffects[breathingType]
        if not config then return end
        
        -- Create surrounding particles
        for i = 1, 8 do
            local angle = (i - 1) * 45
            local offset = Vector(math.cos(math.rad(angle)) * 50, math.sin(math.rad(angle)) * 50, 20)
            
            timer.Simple(i * 0.05, function()
                if not IsValid(ply) then return end
                
                local effectData = EffectData()
                effectData:SetOrigin(ply:GetPos() + offset)
                effectData:SetNormal(Vector(0, 0, 1))
                effectData:SetScale(0.5)
                effectData:SetMagnitude(50)
                
                -- Use a subtle effect for ambient
                if breathingType == "water" then
                    util.Effect("watersplash", effectData, true, true)
                elseif breathingType == "fire" then
                    util.Effect("Sparks", effectData, true, true)
                elseif breathingType == "thunder" then
                    util.Effect("StunstickImpact", effectData, true, true)
                elseif breathingType == "stone" then
                    util.Effect("WheelDust", effectData, true, true)
                elseif breathingType == "wind" then
                    util.Effect("AirboatMuzzle", effectData, true, true)
                end
            end)
        end
    end
    
    -- Create form-specific effects
    local function CreateFormEffect(ply, breathingType, formName)
        if not IsValid(ply) then return end
        
        local config = ParticleEffects[breathingType]
        if not config then return end
        
        -- Form-specific enhanced effects
        local formEffects = {
            -- Water forms
            water_surface_slash = function()
                -- Create water slash effect
                local pos = ply:GetPos() + ply:GetForward() * 50
                for i = 1, 5 do
                    timer.Simple(i * 0.05, function()
                        local effectData = EffectData()
                        effectData:SetOrigin(pos + Vector(i * 10, 0, 40))
                        effectData:SetNormal(ply:GetForward())
                        effectData:SetScale(2)
                        util.Effect("watersplash", effectData, true, true)
                    end)
                end
                ply:EmitSound("ambient/water/water_splash1.wav", 80, 100)
            end,
            
            -- Fire forms
            fire_unknowing = function()
                -- Create fire explosion
                local effectData = EffectData()
                effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
                effectData:SetNormal(Vector(0, 0, 1))
                effectData:SetScale(3)
                effectData:SetMagnitude(200)
                util.Effect("Explosion", effectData, true, true)
                ply:EmitSound("ambient/fire/gascan_ignite1.wav", 85, 100)
            end,
            
            -- Thunder forms
            thunder_clap_flash = function()
                -- Create lightning effect
                local effectData = EffectData()
                effectData:SetOrigin(ply:GetPos())
                effectData:SetNormal(Vector(0, 0, 1))
                effectData:SetScale(5)
                effectData:SetMagnitude(500)
                effectData:SetRadius(200)
                util.Effect("TeslaZap", effectData, true, true)
                
                -- Thunder sound
                ply:EmitSound("ambient/atmosphere/thunder1.wav", 90, 100)
                
                -- Screen flash for nearby players
                for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 500)) do
                    if target:IsPlayer() and target != ply then
                        target:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 128), 0.1, 0)
                    end
                end
            end,
            
            -- Stone forms
            stone_fortress = function()
                -- Create stone wall effect
                for i = 1, 8 do
                    local angle = (i - 1) * 45
                    local offset = Vector(math.cos(math.rad(angle)) * 100, math.sin(math.rad(angle)) * 100, 0)
                    
                    local effectData = EffectData()
                    effectData:SetOrigin(ply:GetPos() + offset)
                    effectData:SetNormal(Vector(0, 0, 1))
                    effectData:SetScale(2)
                    util.Effect("Impact", effectData, true, true)
                end
                ply:EmitSound("ambient/materials/rock1.wav", 85, 80)
            end,
            
            -- Wind forms
            wind_typhoon = function()
                -- Create tornado effect
                for i = 1, 20 do
                    timer.Simple(i * 0.1, function()
                        if not IsValid(ply) then return end
                        
                        local angle = i * 36
                        local radius = 30 + i * 5
                        local height = i * 10
                        local offset = Vector(
                            math.cos(math.rad(angle)) * radius,
                            math.sin(math.rad(angle)) * radius,
                            height
                        )
                        
                        local effectData = EffectData()
                        effectData:SetOrigin(ply:GetPos() + offset)
                        effectData:SetNormal((ply:GetPos() - (ply:GetPos() + offset)):GetNormalized())
                        effectData:SetScale(1)
                        util.Effect("AirboatMuzzle", effectData, true, true)
                    end)
                end
                ply:EmitSound("ambient/wind/wind_hit1.wav", 85, 100)
            end
        }
        
        -- Execute form effect if it exists
        local effectFunc = formEffects[formName]
        if effectFunc then
            effectFunc()
        else
            -- Default form effect
            CreateBreathingParticles(ply, breathingType)
        end
    end
    
    -- Enhanced use form command with effects
    concommand.Add("bs_use_form", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        -- Get player data
        local playerData = BreathingSystem and BreathingSystem.PlayerRegistry and 
                          BreathingSystem.PlayerRegistry.GetPlayerData and
                          BreathingSystem.PlayerRegistry.GetPlayerData(ply)
        
        if not playerData then
            ply:ChatPrint("[BreathingSystem] No player data found!")
            return
        end
        
        local breathingType = playerData.breathing_type or "water"
        local stamina = playerData.stamina or 100
        
        -- Check stamina
        if stamina < 25 then
            ply:ChatPrint("[BreathingSystem] Not enough stamina! (Need 25)")
            ply:EmitSound("buttons/button10.wav", 75, 100)
            return
        end
        
        -- Get form number
        local formNum = tonumber(args[1]) or 1
        local forms = BreathingSystem and BreathingSystem.BreathingTypes and
                     BreathingSystem.BreathingTypes.GetForms and
                     BreathingSystem.BreathingTypes.GetForms(breathingType) or {}
        
        if #forms == 0 then
            ply:ChatPrint("[BreathingSystem] No forms available for " .. breathingType)
            return
        end
        
        -- Clamp form number
        formNum = math.Clamp(formNum, 1, #forms)
        local form = forms[formNum]
        
        if not form then
            ply:ChatPrint("[BreathingSystem] Form " .. formNum .. " not found!")
            return
        end
        
        -- Use stamina
        playerData.stamina = math.max(0, stamina - 25)
        ply:SetNWInt("BreathingStamina", playerData.stamina)
        
        -- Announce form usage
        ply:ChatPrint("[" .. breathingType:upper() .. "] " .. form.name .. "!")
        
        -- Create form-specific effect
        CreateFormEffect(ply, breathingType, form.id)
        
        -- Apply gameplay effects based on breathing type
        ApplyBreathingEffects(ply, breathingType, form)
        
        -- Trigger animation
        ply:DoAnimationEvent(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
        
        -- Screen effect for the player
        ply:ScreenFade(SCREENFADE.IN, ParticleEffects[breathingType].color, 0.2, 0.1)
    end)
    
    -- Apply gameplay effects
    local function ApplyBreathingEffects(ply, breathingType, form)
        if not IsValid(ply) then return end
        
        -- Type-specific buffs
        if breathingType == "water" then
            -- Water: Healing and speed in water
            ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 10))
            if ply:WaterLevel() > 0 then
                ply:SetWalkSpeed(400)
                ply:SetRunSpeed(600)
                timer.Simple(5, function()
                    if IsValid(ply) then
                        ply:SetWalkSpeed(200)
                        ply:SetRunSpeed(400)
                    end
                end)
            end
            
        elseif breathingType == "fire" then
            -- Fire: Damage boost and fire resistance
            ply:Ignite(0.1) -- Brief visual fire
            ply:SetNWFloat("BreathingDamageMultiplier", 1.5)
            timer.Simple(10, function()
                if IsValid(ply) then
                    ply:SetNWFloat("BreathingDamageMultiplier", 1.0)
                end
            end)
            
        elseif breathingType == "thunder" then
            -- Thunder: Speed boost
            ply:SetWalkSpeed(350)
            ply:SetRunSpeed(700)
            ply:SetJumpPower(300)
            timer.Simple(8, function()
                if IsValid(ply) then
                    ply:SetWalkSpeed(200)
                    ply:SetRunSpeed(400)
                    ply:SetJumpPower(200)
                end
            end)
            
        elseif breathingType == "stone" then
            -- Stone: Damage resistance
            ply:SetArmor(50)
            ply:SetNWFloat("BreathingDamageReduction", 0.5)
            timer.Simple(10, function()
                if IsValid(ply) then
                    ply:SetNWFloat("BreathingDamageReduction", 1.0)
                end
            end)
            
        elseif breathingType == "wind" then
            -- Wind: Jump boost and fall damage immunity
            ply:SetJumpPower(400)
            ply:SetNWBool("BreathingNoFallDamage", true)
            timer.Simple(10, function()
                if IsValid(ply) then
                    ply:SetJumpPower(200)
                    ply:SetNWBool("BreathingNoFallDamage", false)
                end
            end)
        end
    end
    
    -- Switch breathing type with effects
    concommand.Add("bs_switch", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local types = {"water", "fire", "thunder", "stone", "wind"}
        local newType = args[1]
        
        if not newType then
            -- Cycle to next type
            local playerData = BreathingSystem and BreathingSystem.PlayerRegistry and 
                              BreathingSystem.PlayerRegistry.GetPlayerData and
                              BreathingSystem.PlayerRegistry.GetPlayerData(ply)
            
            if playerData then
                local current = playerData.breathing_type or "water"
                local currentIndex = 1
                for i, t in ipairs(types) do
                    if t == current then
                        currentIndex = i
                        break
                    end
                end
                newType = types[(currentIndex % #types) + 1]
            else
                newType = "water"
            end
        end
        
        -- Validate type
        local validType = false
        for _, t in ipairs(types) do
            if t == newType then
                validType = true
                break
            end
        end
        
        if not validType then
            ply:ChatPrint("[BreathingSystem] Invalid type! Use: water, fire, thunder, stone, wind")
            return
        end
        
        -- Set new type
        if BreathingSystem and BreathingSystem.PlayerRegistry and 
           BreathingSystem.PlayerRegistry.SetPlayerBreathing then
            BreathingSystem.PlayerRegistry.SetPlayerBreathing(ply, newType)
        end
        
        ply:SetNWString("BreathingType", newType)
        ply:ChatPrint("[BreathingSystem] Switched to " .. newType:upper() .. " breathing!")
        
        -- Play switch effect
        CreateBreathingParticles(ply, newType)
        
        -- Play transition sound
        ply:EmitSound("ambient/energy/whiteflash.wav", 75, 100)
        
        -- Screen flash
        local config = ParticleEffects[newType]
        if config and config.color then
            ply:ScreenFade(SCREENFADE.IN, config.color, 0.5, 0.2)
        end
    end)
    
    -- Hook for damage modification
    hook.Add("EntityTakeDamage", "BreathingSystem_DamageModifier", function(target, dmginfo)
        if not IsValid(target) or not target:IsPlayer() then return end
        
        -- Check damage reduction (Stone)
        local reduction = target:GetNWFloat("BreathingDamageReduction", 1.0)
        if reduction < 1.0 then
            dmginfo:ScaleDamage(reduction)
            
            -- Stone impact effect
            local effectData = EffectData()
            effectData:SetOrigin(target:GetPos())
            effectData:SetNormal(Vector(0, 0, 1))
            util.Effect("Impact", effectData, true, true)
        end
        
        -- Check fall damage immunity (Wind)
        if dmginfo:IsFallDamage() and target:GetNWBool("BreathingNoFallDamage", false) then
            dmginfo:ScaleDamage(0)
            
            -- Wind cushion effect
            local effectData = EffectData()
            effectData:SetOrigin(target:GetPos())
            effectData:SetNormal(Vector(0, 0, 1))
            effectData:SetScale(2)
            util.Effect("AirboatMuzzle", effectData, true, true)
            target:EmitSound("ambient/wind/wind_hit1.wav", 75, 100)
        end
        
        -- Check damage boost (Fire)
        local attacker = dmginfo:GetAttacker()
        if IsValid(attacker) and attacker:IsPlayer() then
            local multiplier = attacker:GetNWFloat("BreathingDamageMultiplier", 1.0)
            if multiplier > 1.0 then
                dmginfo:ScaleDamage(multiplier)
                
                -- Fire impact effect
                local effectData = EffectData()
                effectData:SetOrigin(target:GetPos())
                effectData:SetNormal(Vector(0, 0, 1))
                util.Effect("Sparks", effectData, true, true)
            end
        end
    end)
    
    -- Test command for effects
    concommand.Add("bs_test_effects", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local effectType = args[1] or "all"
        
        if effectType == "all" then
            local types = {"water", "fire", "thunder", "stone", "wind"}
            for i, breathingType in ipairs(types) do
                timer.Simple((i - 1) * 2, function()
                    if IsValid(ply) then
                        ply:ChatPrint("[BreathingSystem] Testing " .. breathingType:upper() .. " effects...")
                        CreateBreathingParticles(ply, breathingType)
                    end
                end)
            end
        else
            CreateBreathingParticles(ply, effectType)
        end
    end)
    
    print("[BreathingSystem] Enhanced effects system loaded!")
    print("  Commands:")
    print("    bs_use_form [1-5] - Use breathing form with effects")
    print("    bs_switch [type] - Switch breathing type")
    print("    bs_test_effects [type/all] - Test particle effects")
end
