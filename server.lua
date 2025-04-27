-- Server-side script for the Advanced Breathing System

-- Configuration
local Config = {
    -- Oxygen mask item settings
    OxygenMaskEnabled = true, -- Set to true to enable oxygen mask item
    OxygenMaskItem = "oxygen_mask", -- Item name in your inventory system
    OxygenMaskDurability = 300, -- Seconds the mask lasts (5 minutes)
    OxygenMaskCooldown = 30 -- Seconds before the mask can be used again
}

-- Player mask states
local playerMasks = {}

-- Register usable item if enabled
if Config.OxygenMaskEnabled then
    -- Register item with ESX (if using ESX)
    if GetResourceState('es_extended') == 'started' then
        Citizen.CreateThread(function()
            local ESX = exports['es_extended']:getSharedObject()
            
            ESX.RegisterUsableItem(Config.OxygenMaskItem, function(source)
                local xPlayer = ESX.GetPlayerFromId(source)
                
                -- Check if player can use mask
                if CanPlayerUseMask(source) then
                    -- Remove item
                    xPlayer.removeInventoryItem(Config.OxygenMaskItem, 1)
                    
                    -- Set mask state
                    SetPlayerMask(source, true)
                    
                    -- Notify player
                    TriggerClientEvent('esx:showNotification', source, 'You have equipped an oxygen mask.')
                else
                    -- Notify player of cooldown
                    TriggerClientEvent('esx:showNotification', source, 'You cannot use another oxygen mask yet.')
                end
            end)
        end)
    end
    
    -- Register item with QBCore (if using QBCore)
    if GetResourceState('qb-core') == 'started' then
        Citizen.CreateThread(function()
            local QBCore = exports['qb-core']:GetCoreObject()
            
            QBCore.Functions.CreateUseableItem(Config.OxygenMaskItem, function(source, item)
                local Player = QBCore.Functions.GetPlayer(source)
                
                -- Check if player can use mask
                if CanPlayerUseMask(source) then
                    -- Remove item
                    Player.Functions.RemoveItem(Config.OxygenMaskItem, 1)
                    
                    -- Set mask state
                    SetPlayerMask(source, true)
                    
                    -- Notify player
                    TriggerClientEvent('QBCore:Notify', source, 'You have equipped an oxygen mask.', 'success')
                else
                    -- Notify player of cooldown
                    TriggerClientEvent('QBCore:Notify', source, 'You cannot use another oxygen mask yet.', 'error')
                end
            end)
        end)
    end
    
    -- Standalone implementation (for non-framework servers)
    RegisterCommand('usemask', function(source, args, rawCommand)
        -- Check if player has the item in their inventory
        -- This requires your own inventory implementation
        
        -- For demonstration purposes, we'll just allow it
        if CanPlayerUseMask(source) then
            -- Set mask state
            SetPlayerMask(source, true)
            
            -- Notify player
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"Breathing", "You have equipped an oxygen mask."}
            })
        else
            -- Notify player of cooldown
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"Breathing", "You cannot use another oxygen mask yet."}
            })
        end
    end, false)
end

-- Check if player can use a mask
function CanPlayerUseMask(playerId)
    if not playerMasks[playerId] then
        return true
    end
    
    local currentTime = os.time()
    return (currentTime - playerMasks[playerId].lastUsed) > Config.OxygenMaskCooldown
end

-- Set player mask state
function SetPlayerMask(playerId, isEquipped)
    -- Initialize player in the table if not exists
    if not playerMasks[playerId] then
        playerMasks[playerId] = {
            equipped = false,
            lastUsed = 0,
            expiryTime = 0
        }
    end
    
    local currentTime = os.time()
    
    -- Update mask state
    playerMasks[playerId].equipped = isEquipped
    playerMasks[playerId].lastUsed = currentTime
    
    if isEquipped then
        playerMasks[playerId].expiryTime = currentTime + Config.OxygenMaskDurability
        
        -- Trigger client event
        TriggerClientEvent('breathing:useOxygenMask', playerId)
        
        -- Set timer to expire mask
        SetTimeout(Config.OxygenMaskDurability * 1000, function()
            if playerMasks[playerId] and playerMasks[playerId].equipped then
                -- Expire mask
                playerMasks[playerId].equipped = false
                
                -- Notify player
                TriggerClientEvent('breathing:useOxygenMask', playerId)
                TriggerClientEvent('chat:addMessage', playerId, {
                    color = {255, 165, 0},
                    args = {"Breathing", "Your oxygen mask has expired."}
                })
            end
        end)
    else
        -- Trigger client event to remove mask
        TriggerClientEvent('breathing:useOxygenMask', playerId)
    end
end

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local source = source
    
    -- Clean up player data
    if playerMasks[source] then
        playerMasks[source] = nil
    end
end)

-- Event handler for InteractSound (if used)
RegisterServerEvent('InteractSound_SV:PlayOnSource')
AddEventHandler('InteractSound_SV:PlayOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', source, soundFile, soundVolume)
end) 