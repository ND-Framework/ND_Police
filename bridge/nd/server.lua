local bridge = {}
local NDCore = exports["ND_Core"]

function bridge.notify(src, info)
    local player = NDCore:getPlayer(src)
    if not player then return end
    player.notify(info)
end

function bridge.shotSpotter(src, location, coords)
    if GetResourceState("ND_MDT") ~= "started" then return end

    exports["ND_MDT"]:createDispatch({
        location = location,
        callDescription = locale("shot_spotter_alert"),
        coords = coords
    })
end

function bridge.hasJobs(src, groups)
    local player = NDCore:getPlayer(src)
    if not player then return end

    for i=1, #groups do
        if player.groups[groups[i]] then
            return true
        end
    end
end

function bridge.impoundVehicle(netId, entity, impoundReclaimPrice)
    local vehicle = NDCore.getVehicle(entity)
    if not vehicle then return end
    vehicle.setMetadata("impoundReclaimPrice", impoundReclaimPrice)
    vehicle.setStatus("impounded", true)
end

return bridge
