local bridge = {}
local Ox = require '@ox_core/lib/init'

function bridge.notify(...)
    lib.notify(...)
end

function bridge.hasGroup(groups)
    if not groups then return end

    local player = Ox.GetPlayer()
    for i=1, #groups do
        if player.getGroup(groups[i]) then
            return true
        end
    end
end

function bridge.getPlayer()
    return Ox.GetPlayer()
end

function bridge.doesPlayerHaveJob(player, job)
    return player.getGroup[job]
end


AddEventHandler("ox:playerLogout", function()
    TriggerEvent("ND_Police:playerUnloaded")
end)

return bridge
