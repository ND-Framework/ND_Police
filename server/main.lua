Ox_inventory = exports.ox_inventory
local data_jail = lib.load("data.jail")

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

RegisterServerEvent('ND_Police:deploySpikestrip', function(data)
    local count = exports.ox_inventory:Search(source, 'count', 'spikestrip')

    if count < data.size then return end

    exports.ox_inventory:RemoveItem(source, 'spikestrip', data.size)

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

    if not exports.ox_inventory:CanCarryItem(source, 'spikestrip', 1) then return end

    DeleteEntity(spike)

    exports.ox_inventory:AddItem(source, 'spikestrip', 1)
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
        Ox_inventory:ConfiscateInventory(id)
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
            local unJailCoords = data_jail.unJailCoords
            SetEntityCoords(target, unJailCoords.x, unJailCoords.y,unJailCoords.z)
            SetEntityHeading( target, unJailCoords.w)
            Ox_inventory:ReturnInventory(target)
            TriggerClientEvent('ox_lib:notify', target, {
                title = 'Jail',
                description = 'Your sentence has ended.',
                type = 'inform'
            })
		end

	end

end)

