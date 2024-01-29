local bridge = {}
local NDCore = exports["ND_Core"]

function bridge.notify(src, info)
    local player = NDCore:getPlayer(src)
    if not player then return end
    player.notify(info)
end

function brdige.shotSpotter(src, location, coords)
    if GetResourceState("ND_MDT") ~= "started" then return end

    exports["ND_MDT"]:createDispatch({
        location = location,
        callDescription = "Shotspotter detected gunshot",
        coords = coords
    })
end

return bridge
