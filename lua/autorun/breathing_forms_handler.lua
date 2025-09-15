--[[
    BreathingSystem - Unified Forms Handler
    =======================================
    
    Consolidates all form usage and effects in one place
]]

if SERVER then
    -- Make CreateFormEffect globally accessible
    BreathingSystem = BreathingSystem or {}
    
    -- Create form-specific effects
    function BreathingSystem.CreateFormEffect(ply, breathingType, formId)
        if not IsValid(ply) then return end
        
        print("[BreathingSystem] Creating form effect: " .. tostring(breathingType) .. " - " .. tostring(formId))
        
        -- Play sound effects based on breathing type
        local sounds = {
            water = {
                "ambient/water/water_splash1.wav",
                "ambient/water/water_splash2.wav",
                "ambient/water/water_splash3.wav"
            },
            fire = {
                "ambient/fire/gascan_ignite1.wav",
                "ambient/fire/ignite.wav",
                "ambient/fire/mtov_flame2.wav"
            },
            thunder = {
                "ambient/energy/spark1.wav",
                "ambient/energy/spark2.wav",
                "ambient/energy/zap1.wav"
            },
            stone = {
                "physics/concrete/concrete_break2.wav",
                "physics/concrete/concrete_break3.wav",
                "physics/concrete/boulder_impact_hard1.wav"
            },
            wind = {
                "ambient/wind/wind_hit1.wav",
                "ambient/wind/wind_hit2.wav",
                "ambient/wind/wind_hit3.wav"
            }
        }
        
        -- Play appropriate sound
        local typeSounds = sounds[breathingType] or sounds.water
        local sound = typeSounds[math.random(#typeSounds)]
        ply:EmitSound(sound, 85, 100, 1, CHAN_AUTO)
        
        -- Create visual effects
        local effectData = EffectData()
        effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
        effectData:SetEntity(ply)
        effectData:SetScale(2)
        effectData:SetMagnitude(100)
        effectData:SetRadius(200)
        
        -- Breathing type specific effects
        if breathingType == "water" then
            -- Water splash effect
            effectData:SetNormal(Vector(0, 0, 1))
            util.Effect("watersplash", effectData, true, true)
            
            -- Create water particles around player
            for i = 1, 10 do
                timer.Simple(i * 0.1, function()
                    if not IsValid(ply) then return end
                    local pos = ply:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), math.random(30, 80))
                    local effect = EffectData()
                    effect:SetOrigin(pos)
                    effect:SetScale(0.5)
                    util.Effect("watersplash", effect, true, true)
                end)
            end
            
        elseif breathingType == "fire" then
            -- Fire explosion effect
            effectData:SetNormal(Vector(0, 0, 1))
            util.Effect("Explosion", effectData, true, true)
            
            -- Create fire particles
            for i = 1, 15 do
                timer.Simple(i * 0.05, function()
                    if not IsValid(ply) then return end
                    local pos = ply:GetPos() + Vector(math.random(-30, 30), math.random(-30, 30), math.random(20, 100))
                    local effect = EffectData()
                    effect:SetOrigin(pos)
                    effect:SetScale(1)
                    util.Effect("MuzzleEffect", effect, true, true)
                end)
            end
            
        elseif breathingType == "thunder" then
            -- Lightning spark effects
            util.Effect("StunstickImpact", effectData, true, true)
            
            -- Create electric sparks
            for i = 1, 8 do
                timer.Simple(i * 0.05, function()
                    if not IsValid(ply) then return end
                    local pos = ply:GetPos() + Vector(math.random(-40, 40), math.random(-40, 40), math.random(30, 90))
                    local effect = EffectData()
                    effect:SetOrigin(pos)
                    effect:SetNormal((pos - ply:GetPos()):GetNormalized())
                    effect:SetMagnitude(2)
                    effect:SetScale(2)
                    util.Effect("StunstickImpact", effect, true, true)
                end)
            end
            
        elseif breathingType == "stone" then
            -- Rock impact effect
            effectData:SetNormal(Vector(0, 0, -1))
            util.Effect("Impact", effectData, true, true)
            
            -- Create dust clouds
            for i = 1, 5 do
                timer.Simple(i * 0.1, function()
                    if not IsValid(ply) then return end
                    local pos = ply:GetPos() + Vector(math.random(-40, 40), math.random(-40, 40), 0)
                    local effect = EffectData()
                    effect:SetOrigin(pos)
                    effect:SetScale(3)
                    util.Effect("ThumperDust", effect, true, true)
                end)
            end
            
        elseif breathingType == "wind" then
            -- Wind vortex effect
            util.Effect("AirboatMuzzle", effectData, true, true)
            
            -- Create swirling wind
            for i = 1, 20 do
                timer.Simple(i * 0.05, function()
                    if not IsValid(ply) then return end
                    local angle = i * 18
                    local radius = 30 + i * 2
                    local height = i * 5
                    local offset = Vector(
                        math.cos(math.rad(angle)) * radius,
                        math.sin(math.rad(angle)) * radius,
                        height
                    )
                    local pos = ply:GetPos() + offset
                    local effect = EffectData()
                    effect:SetOrigin(pos)
                    effect:SetNormal((pos - ply:GetPos()):GetNormalized())
                    effect:SetScale(0.5)
                    util.Effect("AirboatMuzzle", effect, true, true)
                end)
            end
        end
        
        -- Screen effect for the player
        if ply:IsPlayer() then
            ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 50), 0.2, 0.1)
        end
        
        -- Emit additional ambient sound
        ply:EmitSound("ambient/machines/thumper_hit.wav", 70, 150, 0.5, CHAN_BODY)
    end
    
    -- Chat command handler for !useform
    hook.Add("PlayerSay", "BreathingSystem_UseFormCommand", function(ply, text, team)
        local lowerText = string.lower(text)
        
        -- Check for !useform command
        if string.sub(lowerText, 1, 8) == "!useform" then
            local args = string.Explode(" ", text)
            local formNum = tonumber(args[2]) or 1
            
            -- Get player data
            local playerData = BreathingSystem.PlayerRegistry and 
                             BreathingSystem.PlayerRegistry.GetPlayerData and
                             BreathingSystem.PlayerRegistry.GetPlayerData(ply)
            
            if not playerData then
                ply:ChatPrint("[BreathingSystem] No player data found! Switch to a breathing type first.")
                return true
            end
            
            local breathingType = playerData.breathing_type
            if not breathingType or breathingType == "none" then
                ply:ChatPrint("[BreathingSystem] You need to select a breathing type first! Use !bs")
                return true
            end
            
            -- Check stamina
            local stamina = playerData.stamina or 100
            local staminaCost = 15 + (formNum * 5)
            
            if stamina < staminaCost then
                ply:ChatPrint("[BreathingSystem] Not enough stamina! Need " .. staminaCost .. " (Current: " .. stamina .. ")")
                ply:EmitSound("buttons/button10.wav", 75, 100)
                return true
            end
            
            -- Use stamina
            playerData.stamina = math.max(0, stamina - staminaCost)
            ply:SetNWInt("BreathingStamina", playerData.stamina)
            
            -- Announce form usage
            ply:ChatPrint("[" .. breathingType:upper() .. "] Form " .. formNum .. " activated!")
            
            -- Create effects
            BreathingSystem.CreateFormEffect(ply, breathingType, breathingType .. "_form_" .. formNum)
            
            -- Apply gameplay effects
            ApplyFormGameplayEffects(ply, breathingType, formNum)
            
            return true -- Suppress the command from chat
        end
    end)
    
    -- Apply gameplay effects based on form
    function ApplyFormGameplayEffects(ply, breathingType, formNum)
        if not IsValid(ply) then return end
        
        if breathingType == "water" then
            -- Water forms - healing and support
            if formNum == 1 then
                ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 10))
            elseif formNum == 2 then
                -- Area heal
                for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
                    if target:IsPlayer() and target:Team() == ply:Team() then
                        target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + 15))
                    end
                end
            elseif formNum == 3 then
                -- Speed boost
                ply:SetWalkSpeed(300)
                ply:SetRunSpeed(500)
                timer.Simple(5, function()
                    if IsValid(ply) then
                        ply:SetWalkSpeed(200)
                        ply:SetRunSpeed(400)
                    end
                end)
            end
            
        elseif breathingType == "fire" then
            -- Fire forms - damage
            local damage = 10 + (formNum * 10)
            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 150 + (formNum * 50))) do
                if ent:IsNPC() or (ent:IsPlayer() and ent != ply and ent:Team() != ply:Team()) then
                    ent:TakeDamage(damage, ply, ply)
                    if formNum >= 3 then
                        ent:Ignite(formNum)
                    end
                end
            end
            
        elseif breathingType == "thunder" then
            -- Thunder forms - speed and agility
            local speedMult = 1 + (formNum * 0.3)
            ply:SetWalkSpeed(200 * speedMult)
            ply:SetRunSpeed(400 * speedMult)
            ply:SetJumpPower(200 * (1 + formNum * 0.1))
            
            timer.Simple(3 + formNum, function()
                if IsValid(ply) then
                    ply:SetWalkSpeed(200)
                    ply:SetRunSpeed(400)
                    ply:SetJumpPower(200)
                end
            end)
            
        elseif breathingType == "stone" then
            -- Stone forms - defense
            ply:SetArmor(math.min(100, ply:Armor() + (formNum * 15)))
            if formNum >= 3 then
                -- Damage reduction
                ply:SetNWFloat("StoneDamageReduction", 0.5)
                timer.Simple(5, function()
                    if IsValid(ply) then
                        ply:SetNWFloat("StoneDamageReduction", 1)
                    end
                end)
            end
            
        elseif breathingType == "wind" then
            -- Wind forms - mobility
            ply:SetGravity(0.5 - (formNum * 0.08))
            ply:SetJumpPower(250 + (formNum * 30))
            
            timer.Simple(5, function()
                if IsValid(ply) then
                    ply:SetGravity(1)
                    ply:SetJumpPower(200)
                end
            end)
        end
    end
    
    -- Hook for damage reduction (stone breathing)
    hook.Add("EntityTakeDamage", "BreathingSystem_StoneDefense", function(target, dmginfo)
        if IsValid(target) and target:IsPlayer() then
            local reduction = target:GetNWFloat("StoneDamageReduction", 1)
            if reduction < 1 then
                dmginfo:ScaleDamage(reduction)
            end
        end
    end)
end

print("[BreathingSystem] Unified forms handler loaded")
print("[BreathingSystem] Use !useform [1-5] to activate forms with effects") 