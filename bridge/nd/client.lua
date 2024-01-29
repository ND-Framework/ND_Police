local bridge = {}
local NDCore = exports["ND_Core"]

function brdige.notify(...)
    NDCore:notify(...)
end

function bridge.hasGroup(groups)
    if not groups then return end

    local player = NDCore.getPlayer()
    for i=1, #groups do
        if player.groups[groups[i]] then
            return true
        end
    end
end

function bridge.getPlayer()
    return NDCore:getPlayer()
end

function brdige.doesPlayerHaveJob(player, job)
    return player.groups[job]
end


AddEventHandler("ND:characterUnloaded", function()
    TriggerEvent("ND_Police:playerUnloaded")
end)

return bridge
