Config = lib.load("data.config")
local activeLoop = false

AddEventHandler("ox_inventory:currentWeapon", function(weaponData)
    local ammo = weaponData?.ammo
    if not ammo or activeLoop then return end
    
    activeLoop = true

    while ammo and activeLoop do
        Wait(0)

        if IsPedShooting(cache.ped) then
            TriggerEvent("ND_Police:playerJustShot", weaponData)
        end
    end
end)

AddEventHandler("ND_Police:playerUnloaded", function()
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)
