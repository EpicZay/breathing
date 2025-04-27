--[[
    Advanced Breathing System
    Created by: Your Name
    Description: A comprehensive breathing system requiring players to manually breathe
]]

-- Main Configuration
local Config = {
    -- Breathing settings
    BreathCycle = 10000, -- Base time in ms for a full breath cycle (10 seconds)
    BreathCooldown = 1000, -- Cooldown between breaths (ms)
    
    -- Breath recovery
    BreathRecoveryAmount = 100.0, -- How much breath is recovered when breathing
    
    -- Warning thresholds
    WarningThreshold = 60.0, -- Show UI when breath is below this percentage
    CriticalThreshold = 30.0, -- Critical effects below this percentage
    DamageThreshold = 10.0, -- Start taking damage below this percentage
    
    -- Environmental factors
    UnderwaterMultiplier = 1.3, -- Breath depletes 30% faster underwater
    RunningMultiplier = 1.2, -- Breath depletes 20% faster when running
    SprintingMultiplier = 1.4, -- Breath depletes 40% faster when sprinting
    CrouchingMultiplier = 0.8, -- Breath depletes 20% slower when crouching
    
    -- Activity modifiers
    StaminaEffectThreshold = 30, -- When stamina is below this percentage, breathing is affected
    StaminaBreathMultiplier = 1.25, -- Breath depletes faster when stamina is low
    
    -- Weather effects (multipliers for how weather affects breathing)
    WeatherEffects = {
        EXTRASUNNY = 0.9,  -- Easier to breathe
        CLEAR = 0.95,
        NEUTRAL = 1.0,
        SMOG = 1.1,        -- Slightly harder to breathe
        FOGGY = 1.1,
        OVERCAST = 1.05,
        CLOUDS = 1.0,
        CLEARING = 1.0,
        RAIN = 1.05,
        THUNDER = 1.1,
        SNOW = 1.15,       -- Harder to breathe
        BLIZZARD = 1.25,   -- Much harder to breathe
        SNOWLIGHT = 1.1,
        XMAS = 1.05,
        HALLOWEEN = 1.1
    },
    
    -- Oxygen mask item (optional)
    OxygenMaskEnabled = false, -- Set to true if you have an oxygen mask item
    OxygenMaskItem = "oxygen_mask", -- Item name for oxygen mask
    OxygenMaskMultiplier = 0.6, -- Breath depletes 40% slower with mask
    
    -- Damage settings
    DamagePerTick = 1, -- Damage applied when below damage threshold
    CriticalDamagePerTick = 2, -- Damage applied when very low on breath (below 5%)
    
    -- UI settings
    UIRefreshRate = 50, -- How often UI updates (ms)
    
    -- Sound settings
    EnableSounds = true, -- Set to false to disable all sounds
    
    -- Debug mode
    DebugMode = false -- Set to true to enable debug info
}

-- Variables
local breathLevel = 100.0
local isUnderwater = false
local uiDisplayed = false
local lastBreathTime = 0
local playerPed = PlayerPedId()
local isMaskEquipped = false
local currentBreathMultiplier = 1.0
local lastBreathUpdateTime = 0
local environmentalFactorCache = {}
local isPlayerDead = false

-- Initialize
Citizen.CreateThread(function()
    lastBreathTime = GetGameTimer()
    lastBreathUpdateTime = lastBreathTime
    
    -- Load animations
    LoadAnimDict("re@construction")
    LoadAnimDict("swimming@first_person@diving")
end)

-- Main breath calculation thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UIRefreshRate)
        
        if not isPlayerDead then
            playerPed = PlayerPedId()
            
            -- Check if player is underwater
            isUnderwater = IsPedSwimmingUnderWater(playerPed)
            
            -- Calculate environmental factors
            CalculateEnvironmentalFactors()
            
            -- Calculate time since last breath and breath level
            local currentTime = GetGameTimer()
            local timeSinceLastBreath = currentTime - lastBreathTime
            local timeSinceLastUpdate = currentTime - lastBreathUpdateTime
            lastBreathUpdateTime = currentTime
            
            -- Calculate breath decrease based on environmental factors
            local breathDecreasePercentage = (timeSinceLastUpdate / Config.BreathCycle) * 100.0 * currentBreathMultiplier
            
            -- Update breath level
            breathLevel = math.max(0.0, breathLevel - breathDecreasePercentage)
            
            -- Handle UI visibility
            HandleUIVisibility()
            
            -- Apply effects when low on breath
            ApplyLowBreathEffects()
        end
    end
end)

-- Calculate all environmental factors that affect breathing
function CalculateEnvironmentalFactors()
    -- Reset to base value
    currentBreathMultiplier = 1.0
    
    -- Underwater effect
    if isUnderwater then
        currentBreathMultiplier = currentBreathMultiplier * Config.UnderwaterMultiplier
    end
    
    -- Movement effects
    local multiplier = GetMovementBreathMultiplier()
    currentBreathMultiplier = currentBreathMultiplier * multiplier
    
    -- Stamina effect
    local staminaMultiplier = GetStaminaBreathMultiplier()
    currentBreathMultiplier = currentBreathMultiplier * staminaMultiplier
    
    -- Weather effect
    local weatherMultiplier = GetWeatherBreathMultiplier()
    currentBreathMultiplier = currentBreathMultiplier * weatherMultiplier
    
    -- Mask effect
    if Config.OxygenMaskEnabled and isMaskEquipped then
        currentBreathMultiplier = currentBreathMultiplier * Config.OxygenMaskMultiplier
    end
    
    -- Debug output
    if Config.DebugMode then
        print("Breath multiplier: " .. currentBreathMultiplier)
    end
end

-- Get movement-based breath multiplier
function GetMovementBreathMultiplier()
    local multiplier = 1.0
    
    if IsPedSprinting(playerPed) then
        multiplier = Config.SprintingMultiplier
    elseif IsPedRunning(playerPed) then
        multiplier = Config.RunningMultiplier
    elseif IsPedCrouching(playerPed) then
        multiplier = Config.CrouchingMultiplier
    end
    
    return multiplier
end

-- Get stamina-based breath multiplier
function GetStaminaBreathMultiplier()
    local stamina = GetPlayerStamina()
    
    if stamina < Config.StaminaEffectThreshold then
        -- Scale the effect based on how low stamina is
        local staminaFactor = 1.0 + ((Config.StaminaEffectThreshold - stamina) / Config.StaminaEffectThreshold) * (Config.StaminaBreathMultiplier - 1.0)
        return staminaFactor
    end
    
    return 1.0
end

-- Get player stamina (0-100)
function GetPlayerStamina()
    return 100 - GetPlayerSprintStaminaRemaining(PlayerId())
end

-- Get weather-based breath multiplier
function GetWeatherBreathMultiplier()
    -- Only update weather occasionally to save resources
    if environmentalFactorCache.lastWeatherCheck and GetGameTimer() - environmentalFactorCache.lastWeatherCheck < 5000 then
        return environmentalFactorCache.weatherMultiplier or 1.0
    end
    
    local weather = GetCurrentWeather()
    local multiplier = Config.WeatherEffects[weather] or 1.0
    
    -- Cache the result
    environmentalFactorCache.lastWeatherCheck = GetGameTimer()
    environmentalFactorCache.weatherMultiplier = multiplier
    
    return multiplier
end

-- Get current weather
function GetCurrentWeather()
    local _, weather = GetPrevWeatherTypeHashName()
    return weather
end

-- Handle UI visibility based on breath level
function HandleUIVisibility()
    -- Calculate time since last breath
    local timeSinceLastBreath = GetGameTimer() - lastBreathTime
    local secondsLeft = math.max(0, math.ceil((Config.BreathCycle - timeSinceLastBreath) / 1000))
    
    -- Show UI when breath is below threshold
    if breathLevel <= Config.WarningThreshold and not uiDisplayed then
        SendNUIMessage({
            type = "showBreathWarning",
            breathLevel = breathLevel,
            isUnderwater = isUnderwater,
            secondsLeft = secondsLeft,
            multiplier = currentBreathMultiplier,
            hasMask = Config.OxygenMaskEnabled and isMaskEquipped
        })
        uiDisplayed = true
    elseif breathLevel > (Config.WarningThreshold + 10.0) and uiDisplayed then
        SendNUIMessage({
            type = "hideBreathWarning"
        })
        uiDisplayed = false
    end
    
    -- Update UI if displayed
    if uiDisplayed then
        SendNUIMessage({
            type = "updateBreathLevel",
            breathLevel = breathLevel,
            isUnderwater = isUnderwater,
            secondsLeft = secondsLeft,
            multiplier = currentBreathMultiplier,
            hasMask = Config.OxygenMaskEnabled and isMaskEquipped
        })
    end
end

-- Apply effects when breath is low
function ApplyLowBreathEffects()
    -- Visual effects based on breath level
    if breathLevel <= Config.CriticalThreshold then
        local intensity = (Config.CriticalThreshold - breathLevel) / Config.CriticalThreshold
        
        -- Apply visual effects
        if intensity > 0.6 then
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', intensity * 0.3)
            SetTimecycleModifier("damage")
            SetTimecycleModifierStrength(intensity * 0.7)
            
            -- Occasional gasping sound when critically low
            if Config.EnableSounds and math.random() < 0.03 then
                PlaySound("gasp", 0.3 + (intensity * 0.2))
            end
        elseif intensity > 0.3 then
            SetTimecycleModifier("drug_flying_base")
            SetTimecycleModifierStrength(intensity * 0.5)
        end
    else
        -- Clear effects when breath is sufficient
        ClearTimecycleModifier()
    end
    
    -- Apply damage when breath is very low
    if breathLevel <= Config.DamageThreshold then
        if breathLevel <= 5.0 then
            -- Critical damage when extremely low
            ApplyDamageToPed(playerPed, Config.CriticalDamagePerTick, false)
        else
            -- Regular damage
            ApplyDamageToPed(playerPed, Config.DamagePerTick, false)
        end
    end
    
    -- Check if player died
    if IsEntityDead(playerPed) and not isPlayerDead then
        isPlayerDead = true
        -- Hide UI if displayed
        if uiDisplayed then
            SendNUIMessage({
                type = "hideBreathWarning"
            })
            uiDisplayed = false
        end
    elseif not IsEntityDead(playerPed) and isPlayerDead then
        -- Player revived
        isPlayerDead = false
        breathLevel = 100.0
        lastBreathTime = GetGameTimer()
    end
end

-- Register command to breathe
RegisterCommand('breathe', function()
    local currentTime = GetGameTimer()
    
    -- Skip if player is dead
    if isPlayerDead then return end
    
    -- Check cooldown
    if currentTime - lastBreathTime > Config.BreathCooldown then
        -- Update last breath time
        lastBreathTime = currentTime
        
        -- Play appropriate animation
        PlayBreathingAnimation()
        
        -- Reset visual effects
        ClearTimecycleModifier()
        
        -- Play sound
        if Config.EnableSounds then
            if isUnderwater then
                PlaySound("underwater_breath", 0.3)
            else
                PlaySound("deep_breath", 0.4)
            end
        end
        
        -- Restore breath
        breathLevel = math.min(100.0, breathLevel + Config.BreathRecoveryAmount)
        
        -- UI feedback
        SendNUIMessage({
            type = "deepBreath",
            isUnderwater = isUnderwater,
            secondsLeft = 10,
            hasMask = Config.OxygenMaskEnabled and isMaskEquipped
        })
    else
        -- Notify player of cooldown
        local message = isUnderwater and "You need to wait before taking another breath!" or "You're still catching your breath!"
        
        Notify(message)
    end
end, false)

-- Register key mapping
RegisterKeyMapping('breathe', 'Take a breath', 'keyboard', 'b')

-- Play breathing animation based on player's situation
function PlayBreathingAnimation()
    if isUnderwater then
        PlayAnimationIfLoaded("swimming@first_person@diving", "dive_up_01", 8.0, 1.0, 900)
    else
        -- Above water animation
        PlayAnimationIfLoaded("re@construction", "out_of_breath", 8.0, 3.0, 900)
    end
end

-- Util function to play animation and clear after duration
function PlayAnimationIfLoaded(dict, anim, speed, speedMulti, duration)
    LoadAnimDict(dict)
    
    if HasAnimDictLoaded(dict) then
        TaskPlayAnim(playerPed, dict, anim, speed, speedMulti, -1, 0, 0, false, false, false)
        
        -- Clear after duration
        SetTimeout(duration, function()
            ClearPedTasks(playerPed)
        end)
    end
end

-- Util function to load animation dictionary
function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(5)
        end
    end
end

-- Util function to play sound
function PlaySound(soundName, volume)
    if Config.EnableSounds then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", soundName, volume or 0.3)
    end
end

-- Notification function (can be replaced with your own notification system)
function Notify(message)
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        args = {"Breathing", message}
    })
end

-- Initial notification when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(2000)
    TriggerEvent('chat:addMessage', {
        color = {65, 105, 225},
        args = {"Breathing System", "Remember to breathe every 10 seconds by pressing B!"}
    })
end)

-- Timer reminders
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(8000) -- Check after 8 seconds
        
        if not isPlayerDead then
            local currentTime = GetGameTimer()
            local timeSinceLastBreath = currentTime - lastBreathTime
            
            -- Remind player if they haven't breathed in ~8 seconds
            if timeSinceLastBreath > 8000 and timeSinceLastBreath < 9000 then
                TriggerEvent('chat:addMessage', {
                    color = {255, 165, 0},
                    args = {"Breathing", "You need to breathe soon!"}
                })
                
                -- Subtle audio cue
                if Config.EnableSounds then
                    PlaySound("heartbeat", 0.2)
                end
            end
        end
    end
end)

-- Oxygen mask item usage (if enabled)
if Config.OxygenMaskEnabled then
    -- Register usable item
    RegisterNetEvent('breathing:useOxygenMask')
    AddEventHandler('breathing:useOxygenMask', function()
        isMaskEquipped = not isMaskEquipped
        
        if isMaskEquipped then
            Notify("You put on an oxygen mask. Breathing is easier now.")
        else
            Notify("You removed the oxygen mask.")
        end
    end)
end

-- Export functions for other resources to use
exports('GetBreathLevel', function()
    return breathLevel
end)

exports('GetBreathMultiplier', function()
    return currentBreathMultiplier
end)

-- Event handlers
RegisterNetEvent('breathing:setMultiplier')
AddEventHandler('breathing:setMultiplier', function(multiplier)
    if multiplier and type(multiplier) == "number" then
        currentBreathMultiplier = multiplier
    end
end) 