RegisterNetEvent("ND_Police:syncAgressiveCuff", function(target, angle, cuffType, heading)
    TriggerClientEvent("ND_Police:syncAgressiveCuff", target, angle, cuffType, heading)
end)

RegisterNetEvent("ND_Police:syncNormalCuff", function(target, angle, cuffType)
    TriggerClientEvent("ND_Police:syncNormalCuff", target, angle, cuffType)
end)

-- todo: add checks if player if player has the item and distance checks between players and if player using cuffs isn't cuffed themselves and check if they're in a car or not.
-- also remove their item and then sync.
