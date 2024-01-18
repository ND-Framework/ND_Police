
local playerState = LocalPlayer.state

---@param time string
---@param id string
local function updateSentence(time, id)
    CreateThread(function()
        while Sentenced do
            Wait(60000)
            time = time - 1
            if time < 1 then
                TriggerServerEvent('updateSentence', 0 , id)
                Sentenced = false
                break
            else
                TriggerServerEvent('updateSentence', time, id)
                lib.notify({
                    title = 'Jail',
                    description = 'Only ' .. time .. ' months left',
                    type = 'inform'
                })
            end
        end
    end)
end


RegisterCommand('jail',function()
    if not InService or playerState.invBusy then return end
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local nearbyPlayers = lib.getNearbyPlayers(coords, 2.0, true)

    if #nearbyPlayers == 0 then return end

    for i = 1, #nearbyPlayers do
        local option = nearbyPlayers[i]
        option.id = GetPlayerServerId(option.id)
        option.title = Player(option.id).state.name
        option.event = 'beginJailing'
        option.args = {id = option.id, name = option.title}
        nearbyPlayers[i] = option
    end

    lib.registerContext({
        id = 'jailmenu',
        title = 'Jailing Menu',
        options = nearbyPlayers,
    })
    
    lib.showContext('jailmenu')
end)

RegisterNetEvent('beginJailing', function(data)
    if not InService or playerState.invBusy then return end
    
    local input = lib.inputDialog('Sentencing for '..data.name..'', {'Sentence Length'})
    if not input then return end
    local sentence = tonumber(input[1])
    local prisoner = PlayerPedId(data.id)

    SetEntityCoords(prisoner, Config.JailCoords.x, Config.JailCoords.y, Config.JailCoords.z)
    SetEntityHeading(prisoner, Config.JailHeading)

    Sentenced = true
    TriggerServerEvent('server:beginSentence', data.id, sentence, resume)
    updateSentence(sentence, data.id)
end)

RegisterCommand('unjail',function(source, args)
    if not InService or playerState.invBusy then return end

    TriggerServerEvent('updateSentence', 0, tonumber(args[1]))
end)

lib.onCache('playerId', function(value)
    local sentence = LocalPlayer.state.sentence
    if sentence == 0 then return end
    if sentence > 0 then
        Sentenced = true
        updateSentence(sentence, cache.serverId) 
    end
end)