local glm = require 'glm'

RegisterServerEvent('ND_Police:deploySpikestrip', function(data)
    local count = Ox_inventory:Search(source, 'count', 'spikestrip')

    if count < data.size then return end

    Ox_inventory:RemoveItem(source, 'spikestrip', data.size)

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

    if not Ox_inventory:CanCarryItem(source, 'spikestrip', 1) then return end

    DeleteEntity(spike)

    Ox_inventory:AddItem(source, 'spikestrip', 1)
end)
