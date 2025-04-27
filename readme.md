# FiveM Advanced Breathing System

A standalone breathing system for FiveM that requires players to manually breathe both above water and underwater. Features a sleek UI with a progress bar indicating breath level and numerous environmental factors affecting breathing rate.

## Features

- **Manual Breathing Mechanic**: Players must press a key to breathe regularly
- **10-Second Breathing Cycle**: Breath depletes over 10 seconds, requiring regular breathing
- **Environmental Factors**: Various elements affect breathing rate:
  - Underwater breathing (depletes faster)
  - Movement type (running, sprinting, crouching)
  - Weather conditions
  - Player stamina
- **Visual UI**:
  - Circular progress bar showing breath percentage
  - Status messages with breathing reminders
  - Countdown indicators for when to breathe next
  - Environmental factor icons
- **Oxygen Mask System**:
  - Optional item for easier breathing
  - Compatible with ESX and QBCore frameworks
  - Configurable durability and cooldown
- **Immersive Effects**:
  - Screen effects when low on breath
  - Camera shake at critical levels
  - Damage system when oxygen is critically low
  - Different animations for underwater vs above-water breathing

## Installation

1. Download or clone this repository
2. Place the folder in your FiveM server's resources directory
3. Add `ensure advanced_breathing` to your server.cfg
4. Configure settings in `config.lua` to match your server's needs
5. Restart your server

## Configuration

The system is highly configurable through the `config.lua` file:

```lua
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
}
```

## Usage

### Player Controls

- Press `B` (default) to take a breath
- Remember to breathe every 10 seconds to avoid damage
- Pay attention to the UI warnings and indicators

### Admin Commands

- `/breathingdebug` - Toggle debug mode to see breathing statistics (admin only)

### Framework Integration

The system supports ESX and QBCore frameworks for the oxygen mask item:

#### ESX
The oxygen mask is registered as a usable item automatically if ESX is detected.

#### QBCore
The oxygen mask is registered as a usable item automatically if QBCore is detected.

#### Standalone
For servers without frameworks, use the `/usemask` command if you have the item.

## Customization

### UI Customization

The UI is built with HTML/CSS and can be easily customized:
- Modify `html/style.css` to change colors, sizes, and animations
- Edit `html/index.html` to alter the layout

### Sound Effects

The system uses the `InteractSound` resource for sound effects. Add these files to your InteractSound resource:
- `breath.ogg` - Normal breathing sound
- `deep_breath.ogg` - Taking a deep breath
- `underwater_breath.ogg` - Underwater breathing sound
- `gasp.ogg` - Gasping when low on breath
- `heartbeat.ogg` - Heartbeat when breath is critically low

## Exports

The system provides exports for other resources to integrate with:

```lua
-- Get current breath level (0-100)
exports['advanced_breathing']:GetBreathLevel()

-- Get current breath multiplier (how fast breath is depleting)
exports['advanced_breathing']:GetBreathMultiplier()
```

## Events

### Client Events

```lua
-- Set a custom breath multiplier (e.g., from another script)
TriggerEvent('breathing:setMultiplier', 1.5) -- 1.5x faster breathing

-- Toggle oxygen mask
TriggerEvent('breathing:useOxygenMask')
```

### Server Events

```lua
-- Give a player an oxygen mask
TriggerServerEvent('breathing:giveMask', playerId)
```

## Compatibility

- Designed for FiveM
- Tested on OneSync servers
- Compatible with most HUD and UI resources
- Works with popular frameworks (ESX, QBCore) or standalone

## Requirements

- FiveM server
- InteractSound (optional, for sound effects)

## Performance

The resource is optimized for performance with:
- Efficient UI updates
- Minimal resource usage
- Caching of environmental calculations

## License

[MIT License](LICENSE)

## Credits

- Created by kanyelover1337 [Sportman's Solutions]
- Inspired by real-life breathing mechanics
- Thanks to the FiveM community for support and feedback

## Support

For support, bug reports, or feature requests:
- Open an issue on GitHub
- Contact me on Discord: kanyelover1337

---

Enjoy having to remember to breathe in your FiveM server!
