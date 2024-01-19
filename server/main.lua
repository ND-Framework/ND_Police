local players = {}
local table = lib.table

CreateThread(function()
    for _, player in pairs(NDCore.getPlayers("job", "lspd", true)) do
        local inService = Player(source).state.InServic
        print(inService)
        if inService then
            players[player.source] = player
        end
    end
end)

RegisterNetEvent('ND:setPlayerInService', function(group)
    local player = NDCore.getPlayer(source)
    local service = Player(source).state.InServic
    print(group)
    if player then
        if group == false then
            players[source] = player
       
            Player(source).state.InService = group
        else

            Player(source).state.InService = group
        end
        print(service)
    end

    players[source] = nil
end)

AddEventHandler("ND:characterUnloaded", function(source, target)
    players[source] = nil
end)

AddEventHandler("ND:characterLoaded", function(character)
    Player(character).state.InService = false
end)

lib.callback.register('ND_Police:isPlayerInService', function(source, target)
    return players[target or source]
end)


lib.callback.register('ND_Police:setPlayerCuffs', function(source, target)
    local player = NDCore.getPlayer(source)

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    local state = not target.isCuffed

    target:set('isCuffed', state, true)

    return state
end)

RegisterServerEvent('ND_Police:setPlayerEscort', function(target, state)
    local player = NDCore.getPlayer(source)

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    target:set('isEscorted', state and source, true)
end)

local evidence = {}
local addEvidence = {}
local clearEvidence = {}

CreateThread(function()
    while true do
        Wait(1000)

        if next(addEvidence) or next(clearEvidence) then
            TriggerClientEvent('ND_Police:updateEvidence', -1, addEvidence, clearEvidence)

            table.wipe(addEvidence)
            table.wipe(clearEvidence)
        end
    end
end)

RegisterServerEvent('ND_Police:distributeEvidence', function(nodes)
    for coords, items in pairs(nodes) do
        if evidence[coords] then
            lib.table.merge(evidence[coords], items)
        else
            evidence[coords] = items
            addEvidence[coords] = true
        end
    end
end)

RegisterServerEvent('ND_Police:collectEvidence', function(nodes)
    local items = {}

    for i = 1, #nodes do
        local coords = nodes[i]

        table.merge(items, evidence[coords])

        clearEvidence[coords] = true
        evidence[coords] = nil
    end

    for item, data in pairs(items) do
        for type, count in pairs(data) do
            exports.ND_inventory:AddItem(source, item, count, type)
        end
    end

    lib.notify(source, {type = 'success', title = 'Evidence collected'})
end)

RegisterServerEvent('ND_Police:deploySpikestrip', function(data)
    local count = exports.ND_inventory:Search(source, 'count', 'spikestrip')

    if count < data.size then return end

    exports.ND_inventory:RemoveItem(source, 'spikestrip', data.size)

    local dir = glm.direction(data.segment[1], data.segment[2])

    for i = 1, data.size do
        local coords = glm.segment.getPoint(data.segment[1], data.segment[2], (i * 2 - 1) / (data.size * 2))
        local object = CreateObject(`p_ld_stinger_s`, coords.x, coords.y, coords.z, true, true, true)

        while not DoesEntityExist(object) do
            Wait(0)
        end

        SetEntityRotation(object, math.deg(-math.sin(dir.z)), 0.0, math.deg(math.atan(dir.y, dir.x)) + 90, 2, false)
        Entity(object).state:set('inScope', true, true)
    end
end)

RegisterServerEvent('ND_Police:retrieveSpikestrip', function(netId)
    local ped = GetPlayerPed(source)

    if GetVehiclePedIsIn(ped, false) ~= 0 then return end

    local pedPos = GetEntityCoords(ped)
    local spike = NetworkGetEntityFromNetworkId(netId)
    local spikePos = GetEntityCoords(spike)

    if #(pedPos - spikePos) > 5 then return end

    if not exports.ND_inventory:CanCarryItem(source, 'spikestrip', 1) then return end

    DeleteEntity(spike)

    exports.ND_inventory:AddItem(source, 'spikestrip', 1)
end)

AddEventHandler('ND:playerLoaded', function(source, userid, charid) 
    local playerId = NDCore.getPlayer(source)
	MySQL.query('SELECT sentence FROM characters WHERE charid = @charid', {
		['@charid'] = charid,
	}, function (result)
		local remaining = result[1].sentence
        Player(source).state:set('sentence', remaining, true)
        TriggerEvent('server:beginSentence', playerId.source , remaining, true )
	end)

end)

---@param id string
---@param sentence string
---@param resume boolean
RegisterServerEvent('server:beginSentence',function(id, sentence, resume)
    if sentence == 0 then return end
    local playerId = ND.GetPlayer(id)
    
	MySQL.update.await('UPDATE characters SET sentence = @sentence WHERE charid = @charid', {
		['@sentence'] = sentence,		
		['@charid']   = playerId.charid,
	}, function(rowsChanged)
	end)

    TriggerClientEvent('ox_lib:notify', id, {
        title = 'Jailed',
        description = 'You have been sentenced to ' .. sentence .. ' minutes.',
        type = 'inform'
    })
    if not resume then
        exports.ND_inventory:ConfiscateInventory(id)
    end

	TriggerClientEvent('sendToJail', id, sentence)
end)

---@param target string
---@param sentence string
RegisterServerEvent('updateSentence',function(sentence, target)
    local playerId = ND.GetPlayer(target)

	MySQL.update.await('UPDATE characters SET sentence = @sentence WHERE charid = @charid', {
		['@sentence'] = sentence,		
		['@charid']   = playerId.charid,
	}, function(rowsChanged)
        Player(source).state:set('sentence', sentence, true)
	end)

	if sentence <= 0 then
		if target ~= nil then
            SetEntityCoords(target, Config.unJailCoords.x, Config.unJailCoords.y, Config.unJailCoords.z)
            SetEntityHeading( target, Config.unJailHeading)
            exports.ND_inventory:ReturnInventory(target)
            TriggerClientEvent('ox_lib:notify', target, {
                title = 'Jail',
                description = 'Your sentence has ended.',
                type = 'inform'
            })
		end

	end

end)

RegisterNetEvent('gsrTest', function(target)
	local src = source
	local ply = Player(target)
	if ply.state.shot == true then
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Test comes back POSITIVE (Has Shot)'})
	else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Test comes back NEGATIVE (Has Not Shot)'})
	end
end)

