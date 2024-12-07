-- Table to track each player's cuff status
local cuffedPlayers = {}

-- Function to check if a player is a police officer in ND Core
function IsPlayerPoliceNDCore(pSource)
    local player = exports["ND_Core"]:getPlayer(pSource)
    return player and player.job == "Police" -- Ensure job matches police
end

-- Apply cuff to target player and update cuffed status
RegisterNetEvent("customCuff:applyCuff")
AddEventHandler("customCuff:applyCuff", function(targetPlayerId)
    local sourcePlayer = source  -- The player initiating the cuff
    if not IsPlayerPoliceNDCore(sourcePlayer) then
        TriggerClientEvent("ox_lib:notify", sourcePlayer, {type = "error", title = "Error", description = "You are not authorized to use cuffs."})
        return
    end
    
    if cuffedPlayers[targetPlayerId] then
        TriggerClientEvent("ox_lib:notify", sourcePlayer, {type = "error", title = "Error", description = "This player is already cuffed."})
        return
    end

    cuffedPlayers[targetPlayerId] = { cuffedBy = sourcePlayer, isCuffed = true }
    TriggerClientEvent("customCuff:clientCuff", targetPlayerId)  -- Cuff target
    TriggerClientEvent("customCuff:updateCuffStatus", -1, targetPlayerId, true)  -- Notify all players
end)

-- Remove cuff from target player and update cuffed status
RegisterNetEvent("customCuff:removeCuff")
AddEventHandler("customCuff:removeCuff", function(targetPlayerId)
    local sourcePlayer = source  -- The player initiating the uncuff
    if not IsPlayerPoliceNDCore(sourcePlayer) then
        TriggerClientEvent("ox_lib:notify", sourcePlayer, {type = "error", title = "Error", description = "You are not authorized to uncuff."})
        return
    end

    if not cuffedPlayers[targetPlayerId] or not cuffedPlayers[targetPlayerId].isCuffed then
        TriggerClientEvent("ox_lib:notify", sourcePlayer, {type = "error", title = "Error", description = "This player is already uncuffed."})
        return
    end

    cuffedPlayers[targetPlayerId] = nil  -- Remove from cuffed table
    TriggerClientEvent("customCuff:clientUncuff", targetPlayerId)
    TriggerClientEvent("customCuff:updateCuffStatus", -1, targetPlayerId, false)
end)

-- Request consent for search
RegisterNetEvent("customCuff:requestSearchConsent")
AddEventHandler("customCuff:requestSearchConsent", function(targetPlayerId)
    local sourcePlayer = source
    if not IsPlayerPoliceNDCore(sourcePlayer) then
        TriggerClientEvent("ox_lib:notify", sourcePlayer, {type = "error", title = "Error", description = "You are not authorized to conduct searches."})
        return
    end

    -- Request consent from the suspect to search
    TriggerClientEvent("customCuff:searchConsentRequest", targetPlayerId, sourcePlayer)
    print("[DEBUG] Search consent requested from suspect:", targetPlayerId, "by officer:", sourcePlayer)
end)

-- Handle suspect's response to search consent
RegisterNetEvent("customCuff:respondToSearchConsent")
AddEventHandler("customCuff:respondToSearchConsent", function(officerId, consentGiven)
    local suspectId = source
    if consentGiven then
        print("[DEBUG] Consent given by suspect:", suspectId, ". Officer:", officerId, "is opening inventory.")
        TriggerClientEvent("customCuff:openDualInventory", officerId, suspectId)
    else
        TriggerClientEvent("ox_lib:notify", officerId, {type = "error", title = "Consent Denied", description = "Suspect denied the search request."})
    end
end)

-- Server event to handle opening the suspect's and officer's inventories
RegisterNetEvent("customCuff:openSuspectInventory")
AddEventHandler("customCuff:openSuspectInventory", function(suspectId)
    local officerId = source  -- Player initiating the search

    if not IsPlayerPoliceNDCore(officerId) then
        TriggerClientEvent("ox_lib:notify", officerId, {type = "error", title = "Error", description = "You are not authorized to perform this action."})
        return
    end

    if cuffedPlayers[suspectId] and cuffedPlayers[suspectId].cuffedBy == officerId then
        print("[DEBUG] Officer ID:", officerId, "accessing suspect inventory ID:", suspectId)

        -- Open both the officer's and suspect's inventories side-by-side
        TriggerClientEvent("ox_inventory:openInventory", officerId, { type = 'player', id = suspectId })  -- Suspect’s inventory
        TriggerClientEvent("ox_inventory:openInventory", officerId, { type = 'player', id = officerId })  -- Officer’s inventory
    else
        TriggerClientEvent("ox_lib:notify", officerId, {type = "error", title = "Access Denied", description = "Suspect is not cuffed or denied access."})
    end
end)


RegisterNetEvent('customCuff:playCuffAnimation')
AddEventHandler('customCuff:playCuffAnimation', function(targetPlayerId)
    local sourcePlayer = source  -- Officer's server ID
    TriggerClientEvent('customCuff:clientPlayCuffAnimation', targetPlayerId)
end)