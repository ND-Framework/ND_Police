RegisterNetEvent('ND_Police:gsrTest', function(target)
	local src = source
	local state = Player(target).state
    local player = NDCore.getPlayer(src)

    if state.shot then
        return player.notify({
            type = 'success',
            description = 'Test comes back POSITIVE (Has Shot)'
        })
    end

    player.notify({
        type = 'error',
        description = 'Test comes back NEGATIVE (Has Not Shot)'
    })
end)
