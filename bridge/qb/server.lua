local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()

function bridge.notify(src, info)
    TriggerClientEvent("ox_lib:notify", src, info)
end

function bridge.shotSpotter(src, location, coords)
    -- note: add integration for dispatch resources
end

function bridge.hasJobs(src, groups)
    if not groups then return end

    local player = QBCore.Functions.GetPlayer(src)
    local job = player.PlayerData.job.name

    for i=1, #groups do
        if job == groups[i] then
            return true
        end
    end
end

return bridge
