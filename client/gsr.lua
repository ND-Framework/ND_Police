local timeEnteredWater = 0

local function checkGsr(state)
    local shot, lastShot = state.shot, state.lastShot
    if not shot then return end

    local time = GetCloudTimeAsInt()

    local inWater = IsEntityInWater(cache.ped)
    if not inWater then
        timeEnteredWater = time
        inWater = true
    end

    if inWater and time-timeEnteredWater > (Config.clearGSRinWater*60) then
        local ped = cache.ped
        ClearPedBloodDamage(ped)
        ClearPedEnvDirt(ped)
        ResetPedVisibleDamage(ped)
        lib.notify({
            type = 'inform',
            description = 'GSR Washed off'
        })
        state:set('shot', false, true)
    end

    if time-lastShot > (Config.clearGSR*60) then
        lib.notify({
            type = 'inform',
            description = 'GSR has faded'
        })
        state:set('shot', false, true)
    end
end

CreateThread(function()
	while true do
        Wait(1000)
        local state = Player(cache.serverId).state
        checkGsr(state)
    end
end)

exports.ox_target:addGlobalPlayer({
    {
        icon = 'fa-solid fa-gun',
        label = 'GSR Test',
        groups = Config.policeGroups,
	    distance = 1.5,
        onSelect = function(data)
            TriggerServerEvent('ND_Police:gsrTest', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
        end
    }
})
