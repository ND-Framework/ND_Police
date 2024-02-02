local bridge = {}
local ESX = exports["es_extended"]:getSharedObject()

function bridge.notify(info)
    lib.notify(info)
end

function bridge.hasGroup(groups)
    if not groups then return end

    local player = ESX.GetPlayerData()
    for i=1, #groups do
        if player.job.name == groups[i] then
            return true
        end
    end
end

function bridge.getPlayer()
    return ESX.GetPlayerData()
end

function bridge.doesPlayerHaveJob(player, job)
    return player.job.name == job
end

return bridge
