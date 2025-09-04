local bridge = {}
local Ox = require '@ox_core/lib/init'

function bridge.notify(src, info)
    local player = Ox.GetPlayer(src)
    if not player then return end
    TriggerClientEvent('ox_lib:notify', src, info)
    -- player.notify(info)
end

function bridge.shotSpotter(src, location, coords)
    if GetResourceState("ND_MDT") ~= "started" then return end

    exports["ND_MDT"]:createDispatch({
        location = location,
        callDescription = "Shotspotter detected gunshot",
        coords = coords
    })
end

function bridge.hasJobs(src, groups)
    local player = Ox.GetPlayer(src)
    if not player then return end

    for i=1, #groups do
        if player.getGroup(groups[i]) then
            return true
        end
    end
end

function bridge.impoundVehicle(netId, entity, impoundReclaimPrice)
    local vehicle = Ox.GetVehicle(entity)
    if not vehicle then return end
    vehicle.set("impoundReclaimPrice", impoundReclaimPrice)
    vehicle.setStored("impound", true)
end

return bridge
