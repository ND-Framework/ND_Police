Ox_inventory = exports.ox_inventory
local glm = require 'glm'
local config = lib.load("data.config")

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
    local src = source
    target = tonumber(target)
    if not target then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if not playerCoords or not targetCoords or #(playerCoords-targetCoords) > 5 then return end

    target = Player(target)?.state
    if not target then return end

    target:set('isEscorted', state and src, true)
end)

RegisterNetEvent('ND_Police:gsrTest', function(target)
	local src = source
	local state = Player(target).state

    if state.shot then
        return Bridge.notify(src, {
            type = 'success',
            description = 'Test comes back POSITIVE (Has Shot)'
        })
    end

    Bridge.notify(src, {
        type = 'error',
        description = 'Test comes back NEGATIVE (Has Not Shot)'
    })
end)

RegisterNetEvent("ND_Police:shotspotter", function(location, coords)
    local src = source
    Bridge.shotSpotter(src, location, coords)
end)

RegisterNetEvent("ND_Police:impoundVehicle", function(netId, impoundReclaimPrice)
    local src = source

    if not impoundReclaimPrice or impoundReclaimPrice > config.maxImpoundPrice or impoundReclaimPrice < config.minImpoundPrice then
        return Bridge.notify({
            type = "error",
            description = "Invalid impound reclaim price."
        })
    end

    if not Bridge.hasJobs(src, config.policeGroups) then
        return Bridge.notify({
            type = "error",
            description = "You don't have permission to do this."
        })
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if not DoesEntityExist(vehicle) then
        return Bridge.notify({
            type = "error",
            description = "Vehicle was not found, try again later."
        })
    end

    local vehCoords = GetEntityCoords(vehicle)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))

    if #(vehCoords-pedCoords) > 5 then
        return Bridge.notify({
            type = "error",
            description = "You're too far away from the vehicle."
        })
    end
    
    if Bridge.impoundVehicle then
        Bridge.impoundVehicle(netId, vehicle, impoundReclaimPrice)
    end
    
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)
