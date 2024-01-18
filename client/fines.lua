local ped = cache.ped
local playerState = LocalPlayer.state

RegisterCommand('fine',function()
    if not InService or playerState.invBusy then return end
    
    local coords = GetEntityCoords(ped)
    local nearbyPlayers = lib.getNearbyPlayers(coords, 2.0, true)

    if #nearbyPlayers == 0 then return end
    
    for i = 1, #nearbyPlayers do
        local option = nearbyPlayers[i]
        option.id = GetPlayerServerId(option.id)
        option.title = Player(option.id).state.name
        option.event = 'writeFine'
        option.args = {id = option.id, name = option.title}
        nearbyPlayers[i] = option
    end

    lib.registerContext({
        id = 'finemenu',
        title = 'Fine Menu',
        options = nearbyPlayers,
    })
    
    lib.showContext('finemenu')
end)

RegisterNetEvent('writeFine', function(data)
    local input = lib.inputDialog('Fine for '..data.name..'', {'Fine Amount', 'Citation'})
    print(data.id)
    if not input then return end
    local fine = tonumber(input[1])
    local message = input[2]
    TriggerServerEvent('confirmation', fine, data.id, message)
end)

RegisterNetEvent('sendConfirm', function(fine, officer, message)
    print(message)
    local alert = lib.alertDialog({
        header = 'You have been fined',
        content = 'Please pay in the amount of '..fine,
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('acceptedFine', fine, officer , message)
    else
        TriggerServerEvent('refusedFine', officer)
    end
end)
