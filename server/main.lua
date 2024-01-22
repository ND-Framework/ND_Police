Ox_inventory = exports.ox_inventory

RegisterServerEvent('ND_Police:setPlayerEscort', function(target, state)
    local player = NDCore.getPlayer(source)

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    target:set('isEscorted', state and source, true)
end)
