local table = lib.table
InService = player?.inService and player.job == "lspd"

RegisterCommand('duty', function()
    local wasInService = InService
    local player = NDCore.getPlayer()
    InService = not InService and player.job == 'lspd' or false
    print('InService')
    if not wasInService and not InService then
        lib.notify({
            description = 'Service not available',
            type = 'error'
        })
    else
        TriggerServerEvent('ND:setPlayerInService', InService)
        lib.notify({
            description = InService and 'In Service' or 'Out of Service',
            type = 'success'
        })
    end
end)


AddEventHandler("ND:characterUnloaded", function()
    InService = false
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)



