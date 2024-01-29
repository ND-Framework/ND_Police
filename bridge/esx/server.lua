local bridge = {}

function bridge.notify(src, info)
    TriggerClientEvent("ox_lib:notify", src, info)
end

function bridge.shotSpotter(src, location, coords)
    -- note: add integration for dispatch resources
end

return bridge
