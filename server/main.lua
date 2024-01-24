Ox_inventory = exports.ox_inventory
local glm = require 'glm'

RegisterServerEvent('ND_Police:deploySpikestrip', function(data)
    local count = Ox_inventory:Search(source, 'count', 'spikestrip')

    if count < data.size then return end

    Ox_inventory:RemoveItem(source, 'spikestrip', data.size)

    local dir = glm.direction(data.segment[1], data.segment[2])

    for i = data.size, 1, -1 do
        local coords = glm.segment.getPoint(data.segment[1], data.segment[2], (i * 2 - 1) / (data.size * 2))
        local object = CreateObject(`p_ld_stinger_s`, coords.x, coords.y, coords.z, true, true, true)

        while not DoesEntityExist(object) do
            Wait(0)
        end

        SetEntityRotation(object, math.deg(-math.sin(dir.z)), 0.0, math.deg(math.atan(dir.y, dir.x)) + 90, 2, false)
        Entity(object).state:set('inScope', true, true)
        Wait(800)
    end
end)

RegisterServerEvent('ND_Police:retrieveSpikestrip', function(netId)
    local ped = GetPlayerPed(source)

    if GetVehiclePedIsIn(ped, false) ~= 0 then return end

    local pedPos = GetEntityCoords(ped)
    local spike = NetworkGetEntityFromNetworkId(netId)
    local spikePos = GetEntityCoords(spike)

    if #(pedPos - spikePos) > 5 then return end

    if not Ox_inventory:CanCarryItem(source, 'spikestrip', 1) then return end

    DeleteEntity(spike)

    Ox_inventory:AddItem(source, 'spikestrip', 1)
end)

RegisterServerEvent('ND_Police:setPlayerEscort', function(target, state)
    local player = NDCore.getPlayer(source)

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    target:set('isEscorted', state and source, true)
end)

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

RegisterNetEvent("ND_Police:shotspotter", function(location, coords)
    if GetResourceState("ND_MDT") ~= "started" then return end

    exports["ND_MDT"]:createDispatch({
        location = location,
        callDescription = "Shotspotter detected gunshot",
        coords = coords
    })
end)
