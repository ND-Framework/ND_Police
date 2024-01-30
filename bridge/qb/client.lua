local bridge = {}
local QBCore = exports["qb-core"]:GetCoreObject()

function bridge.notify(info)
    lib.notify(info)
end

function bridge.hasGroup(groups)
    if not groups then return end

    local player = QBCore.Functions.GetPlayerData()
    local jobName = player and player.job.name

    for i=1, #groups do
        if jobName == groups[i] then
            return true
        end
    end
end

function bridge.getPlayer()
    return QBCore.Functions.GetPlayerData()
end

function bridge.doesPlayerHaveJob(player, job)
    return player and player.job.name == job
end

return bridge
