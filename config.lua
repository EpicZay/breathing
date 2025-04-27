Config = {
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
    OxygenMaskEnabled = true, -- Set to true if you have an oxygen mask item
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