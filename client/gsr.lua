
local ped = cache.ped
local shot = false
local lastShot = 0
local timeInWater = 0
local beenInWater = false
local GetGameTimer = GetGameTimer
local inWater = false

if LocalPlayer.state.shot then
    shot = true 
    lastShot = LocalPlayer.state.lastShot
end

CreateThread(function()
	while true do
        Wait(100)
        local shot = LocalPlayer.state.shot
        if shot == true then
            if IsEntityInWater(ped) then
                if inWater == false then
                    timeInWater = GetGameTimer()
                end
                beenInWater = true
                inWater = true
            else
                inWater = false
                beenInWater = false
                timeInWater = 0
            end
        end
        local timer = GetGameTimer()
        local lastShot = LocalPlayer.state.lastShot
        if shot and beenInWater and timer - timeInWater >= (Config.clearGSRinWater * 60 * 1000) then
            ClearPedBloodDamage(ped)
            ClearPedEnvDirt(ped)
            ResetPedVisibleDamage(ped)
            lib.notify({
                description = 'GSR Washed off',
                type = 'error'
            })
            LocalPlayer.state:set('shot', false, true)
            shot = false
        end
        if shot and timer - lastShot >= (Config.clearGSR * 60 * 1000) then
            lib.notify({
                description = 'GSR has faded',
                type = 'error'
            })
            LocalPlayer.state:set('shot', false, true)
            shot = false
        end 
    end
end)

exports.ox_target:addGlobalPlayer({
    {
        icon = 'fa-solid fa-gun',
        label = 'GSR Test',
        groups = 'police',
	    distance = 1.5,
        onSelect = function(data)
            TriggerServerEvent('gsrTest', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
        end
    }
})

