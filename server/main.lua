Ox_inventory = exports.ox_inventory
local data_jail = lib.load("data.jail")

RegisterServerEvent('ND_Police:setPlayerEscort', function(target, state)
    local player = NDCore.getPlayer(source)

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    target:set('isEscorted', state and source, true)
end)

AddEventHandler("ND:characterLoaded", function(player)
    local remaining = player.getMetadata("sentence")
    if not remaining or remaining == 0 then return end

    local src = player.source
    Player(src).state:set('sentence', remaining, true)
    TriggerEvent('ND_Police:beginSentence', src, remaining, true)
end)

---@param id number
---@param sentence number
---@param resume boolean
RegisterServerEvent('ND_Police:beginSentence',function(id, sentence, resume)
    if not sentence or sentence == 0 then return end
    
    local player = NDCore.getPlayer(id)

    player.setMetadata("sentence", sentence)
    player.notify({
        title = 'Jailed',
        description = 'You have been sentenced to ' .. sentence .. ' minutes.',
        type = 'inform'
    })

    if not resume then
        Ox_inventory:ConfiscateInventory(id)
    end

	TriggerClientEvent('ND_Police:sendToJail', id, sentence)
end)

---@param target number
---@param sentence number
RegisterServerEvent('ND_Police:updateSentence',function(sentence, target)
    if not target or not sentence or sentence <= 0 then return end

    local player = NDCore.getPlayer(target)

    Player(source).state:set('sentence', sentence, true)
    player.setMetadata("sentence", sentence)
    player.notify({
        title = 'Jail',
        description = 'Your sentence has ended.',
        type = 'inform'
    })

    local unJailCoords = data_jail.unJailCoords
    SetEntityCoords(target, unJailCoords.x, unJailCoords.y,unJailCoords.z)
    SetEntityHeading(target, unJailCoords.w)
    Ox_inventory:ReturnInventory(target)
end)
