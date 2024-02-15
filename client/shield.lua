local holdingShield = false
local shield = nil
local ox_inventory = exports.ox_inventory

local function shieldOnBack(status)
    if not status then
        SetPlayerSprint(cache.playerId, true)
        return DoesEntityExist(shield) and DeleteEntity(shield)
    end
    
    local ped = cache.ped
    local coords = GetEntityCoords(ped)

    lib.requestModel(`prop_ballistic_shield`)
    shield = CreateObject(`prop_ballistic_shield`, coords.x, coords.y, coords.z, true, false, false)
    while not DoesEntityExist(shield) do Wait(0) end

    AttachEntityToEntity(shield, ped, GetPedBoneIndex(ped, 0x60F2), 0.0, -0.25, 0.0, -10.0, 90.0, 0.0, true, true, false, true, 1, true)
    SetEntityNoCollisionEntity(ped, shield, false)
    SetPlayerSprint(cache.playerId, false)
end

local function disableShield()
    local ped = cache.ped
    StopAnimTask(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 2.0)

    lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
    TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-180", 8.0, -8.0, -1, 50, 0.0, false, false, false)

    Wait(500)
    StopAnimTask(ped, "combat@gestures@gang@pistol_1h@beckon", "-180", 2.0)
    Wait(200)
    SetPlayerSprint(cache.playerId, true)
    
    LocalPlayer.state.blockHandsUp = false
    holdingShield = false

    if DoesEntityExist(shield) then
        DeleteEntity(shield)
    end

    SetTimeout(50, function()
        ClearPedTasks(ped)
        SetControlNormal(0, 36, 1.0)
    end)

    return ox_inventory:Search("count", "shield") > 0 and shieldOnBack(true)
end

local function enableShield()
    if holdingShield then
        return disableShield()
    end

    local ped = cache.ped
    local hasWeapon, weaponHash = GetCurrentPedWeapon(ped, true)
    if not hasWeapon or GetWeapontypeGroup(weaponHash) ~= 416676503 then
        return Bridge.notify({
            title = "You must hold a handgun",
            type = "inform"
        })
    end

    LocalPlayer.state.blockHandsUp = true
    holdingShield = true
    local coords = GetEntityCoords(ped)

    lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
    TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 8.0, -8.0, -1, 50, 0.0, false, false, false)
    Wait(600)
    shieldOnBack(false)
    
    lib.requestModel(`prop_ballistic_shield`)
    shield = CreateObject(`prop_ballistic_shield`, coords.x, coords.y, coords.z, true, false, false)
    while not DoesEntityExist(shield) do Wait(0) end

    AttachEntityToEntity(shield, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), -0.05, -0.06, -0.09, -35.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetEntityNoCollisionEntity(ped, shield, false)
    SetPlayerSprint(cache.playerId, false)
    
    CreateThread(function()
        while holdingShield do
            Wait(0)
            DisableControlAction(0, 186, true)
            DisableControlAction(0, 36, true)

            local weapon = cache.weapon

            if not weapon or IsDisabledControlJustPressed(0, 186) then
                return disableShield()
            end

            if weapon and not IsEntityPlayingAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 3) then
                lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
                TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 8.0, -8.0, -1, 50, 0.0, false, false, false)
            end

            if not GetPedStealthMovement(ped) then
                ForcePedMotionState(ped, 0x422d7a25, true, 1, false)
            end
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    local count = ox_inventory:Search("count", "shield")
    return count > 0 and shieldOnBack(true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    local count = ox_inventory:Search("count", "shield")
    return count > 0 and shieldOnBack(false)
end)

exports("hasShield", shieldOnBack)

exports("useShield", function(data, slot)
    ox_inventory:useItem(data, function(data)
        if not data then return end
        enableShield()
    end)
end)
