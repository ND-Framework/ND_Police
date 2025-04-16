local isCuffed = false
local currentCuffType = "cuffs"
local npwd = GetResourceState("npwd") == "started"

local cuffSounds = {
    cuffs = {"cuff", "uncuff"},
    zipties = {"zip", "unzip"}
}
local cuffModels = {
    cuffs = `police_cuffs`,
    zipties = `police_zip_tie_positioned`
}
local cuffAnims = {
    back = {
        dict = "mp_arresting",
        name = "idle"
    },
    front = {
        dict = "anim@move_m@prisoner_cuffed",
        name = "idle"
    }
}
local cuffInfo = {
    cuffs = {
        back = {
            pos = vec3(0.0, 0.07, 0.03),
            rot = vec3(10.0, 115.0, -65.0)
        },
        front = {
            pos = vec3(-0.025, 0.0, 0.085),
            rot = vec3(10.0, 75.0, 0.0)
        }
    },
    zipties = {
        back = {
            pos = vec3(0.01, 0.06, 0.035),
            rot = vec3(-90.0, 110.0, -65.0)
        },
        front = {
            pos = vec3(-0.02, 0.0, 0.085),
            rot = vec3(100.0, 75.0, 0.0)
        }
    }
}

local handsUpStatus = false
local holdingHands = false
local handsAnimType = "hu"
local handsAnim = {
    hu = {
        dict = "missminuteman_1ig_2",
        name = "handsup_enter"
    },
    huk = {
        dict = "random@arrests@busted",
        name = "idle_c"
    },
    hukEnter = {
        dict = "random@arrests",
        name = "kneeling_arrest_idle"
    },
    hukEnter2 = {
        dict = "random@arrests@busted",
        name = "enter"
    }
}

local function handsUpGround(ped)
    if not handsUpStatus then return end
    lib.requestAnimDict("random@arrests")
    TaskPlayAnim(ped, "random@arrests", "kneeling_arrest_idle", 1.0, 1.0, -1, 2, 0, false, false, false)
    Wait(1000)

    if handsUpStatus then
        TaskPlayAnim(ped, "random@arrests@busted", "enter", 1.0, 1.0, -1, 2, 0, false, false, false)
        Wait(1000)
    end
    RemoveAnimDict("random@arrests")
end

local function toggleHandsUp(status, animType)
    local state = Player(cache.serverId).state
    if state.gettingCuffed or state.isCuffed or state.isCuffing then return end 

    if npwd then
        exports.npwd:setPhoneDisabled(status)
    end

    exports.ox_target:disableTargeting(status)
    state:set("handsUp", status, true)
    handsUpStatus = status
    local ped = cache.ped

    
    if status then
        local anim = handsAnim[animType]
        local huk = animType == "huk"
        local flag = huk and 1 or 50
        local blendIn = huk and 1.5 or 8.0
        handsAnimType = animType

        lib.requestAnimDict(anim.dict)
        if huk then handsUpGround(ped) end

        if not handsUpStatus then return end
        TaskPlayAnim(ped, anim.dict, anim.name, blendIn, 8.0, -1, flag, 0, false, false, false)

        DisablePlayerFiring(cache.playerId, true)
        lib.disableControls:Add(140, 141, 142, 25, 24, 257)
        LocalPlayer.state.invBusy = true
        
        CreateThread(function()
            while handsUpStatus do
                Wait(0)
                lib.disableControls()
            end
        end)

        return RemoveAnimDict(anim.dict)
    end

    for _, anim in pairs(handsAnim) do
        if IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
            StopAnimTask(ped, anim.dict, anim.name, 4.0)
        end
    end
    DisablePlayerFiring(cache.playerId, false)
    lib.disableControls:Remove(140, 141, 142, 25, 24, 257)
    LocalPlayer.state.invBusy = false
end

local function playsound(entity, sound)
    while not RequestScriptAudioBank("audiodirectory/nd_police", false) do Wait(0) end
    
    local soundId = GetSoundId()

    PlaySoundFromEntity(soundId, sound, entity, "nd_police_soundset", true)
    ReleaseSoundId(soundId)
    ReleaseNamedScriptAudioBank("audiodirectory/nd_police")
end

local function playAnimation(ped, dict, name)
	TaskPlayAnim(ped, dict, name, 5.0, 5.0, -1, 49, 0, 0, 0, 0)
end 

local function disablePlayer(ped, animDict, animName)
    playAnimation(ped, animDict, animName)
    SetEnableHandcuffs(ped, true)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    DisablePlayerFiring(cache.playerId, true)
    Wait(1000)
end

local function enablePlayer(ped, entity)
    local sound = cuffSounds[currentCuffType]
    if sound and entity then
        playsound(entity or cache.ped, sound[2])
        DeleteEntity(entity)
    end

    SetEnableHandcuffs(ped, false)
    ClearPedTasks(ped)
    DisablePlayerFiring(cache.playerId, false)
    local state = Player(cache.serverId).state
    state:set("isCuffed", false, true)
    isCuffed = false
end

local function setCuffed(enabled, angle, cuffType)
    if not enabled or isCuffed then
        isCuffed = false
        local state = Player(cache.serverId).state
        state:set("isCuffed", false, true)
        state:set("cuffType", false, true)
        exports.ox_target:disableTargeting(false)
        return npwd and exports.npwd:setPhoneDisabled(false)
    end

    toggleHandsUp(false)

    local ped = cache.ped
    local model = cuffModels[cuffType]
    local anim = cuffAnims[angle]
    local position = cuffInfo[cuffType]?[angle]
    if not model or not anim or not position then return end
    
    currentCuffType = cuffType
    local pos, rot = position.pos, position.rot
    local state = Player(cache.serverId).state
    state:set("isCuffed", true, true)
    state:set("cuffType", cuffType, true)
    exports.ox_target:disableTargeting(true)

    if npwd then
        exports.npwd:setPhoneDisabled(true)
    end

    local entity = CreateObject(model, 0, 0, 0, true, true, true)
    AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, 0x49D9), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
    ClearPedTasksImmediately(ped)
    lib.requestAnimDict(anim.dict)

    isCuffed = true
    local veh = nil
    local preventExitVeh = false
    local sound = cuffSounds[currentCuffType]

    if sound then
        CreateThread(function()
            while not DoesEntityExist(entity) do Wait(0) end
            Wait(500)
            playsound(entity, sound[2])
        end)
    end

    CreateThread(function()
        lib.disableControls:Add(140, 141, 142, 25, 59)
        disablePlayer(ped, anim.dict, anim.name)

        while isCuffed do
            Wait(0)
            lib.disableControls()
            local vehEntering = GetVehiclePedIsEntering(ped)

            if vehEntering ~= 0 then
                local seat = GetSeatPedIsTryingToEnter(ped)
                if GetVehicleDoorAngleRatio(vehEntering, seat+1) < 0.2 then
                    ClearPedTasks(ped)
                end
            end

            if veh and preventExitVeh then
                DisableControlAction(0, 23, true)
		DisableControlAction(0, 75, true)
            end
        end
    end)

    CreateThread(function()
        while isCuffed do
            Wait(200)
            ped = cache.ped
            veh = cache.vehicle

            if veh then
                preventExitVeh = GetVehicleDoorAngleRatio(veh, cache.seat+1) < 0.2
            end

            if not IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
                disablePlayer(ped, anim.dict, anim.name)
            end
            if IsPedUsingActionMode(ped) then
                SetPedUsingActionMode(ped, false, -1, "DEFAULT_ACTION")
            end
        end

        lib.disableControls:Remove(140, 141, 142, 25, 59)
        enablePlayer(ped, entity)

        lib.requestAnimDict("mp_arresting")
        local coords = GetEntityCoords(ped)
        local rot = GetEntityRotation(ped)
        if angle == "back" then
            TaskPlayAnimAdvanced(ped, "mp_arresting", "b_uncuff", coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, 8.0, 8.0, 2500, 33, 0.6)
        else
            TaskPlayAnimAdvanced(ped, "mp_arresting", "b_uncuff", coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, 1.0, 1.0, 1300, 33, 0.68)
        end
    end)
end

local function getAngle(ped, targetPed, pedCoords, targetPedCoords)
    local targetForwardVector = GetEntityForwardVector(targetPed)
    local vectorToPed = pedCoords-targetPedCoords

    local normalizedPed = vectorToPed/#(vectorToPed)
    local normalizedTarget = targetForwardVector/#(targetForwardVector)

    local dotProduct = normalizedPed.x*normalizedTarget.x + normalizedPed.y*normalizedTarget.y + normalizedPed.z*normalizedTarget.z
    return dotProduct > 0 and "front" or "back"
end

local function normalCuffPlayer(ped, targetPed, targetPlayer, cuffType, slot)
    local dict = "mp_arresting"
    local coords = GetEntityCoords(ped)
    local targetState = Player(targetPlayer).state
    if targetState.gettingCuffed or targetState.isCuffing or targetState.isCuffed then return end

    local angle = getAngle(ped, targetPed, coords, GetEntityCoords(targetPed))
    TriggerServerEvent("ND_Police:syncNormalCuff", targetPlayer, angle, cuffType, slot)
    Wait(100)

    lib.requestAnimDict(dict)
    playAnimation(ped, dict, "a_uncuff")
    Wait(1000)
    ClearPedTasks(ped)
end

local function agressiveCuffPlayer(ped, targetPed, targetPlayer, cuffType, slot)
    local dict = "mp_arrest_paired"
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local targetState = Player(targetPlayer).state
    if targetState.gettingCuffed or targetState.isCuffing or targetState.isCuffed then return end

    local playerState = Player(cache.serverId).state
    playerState:set("isCuffing", true, true)

    TriggerServerEvent("ND_Police:syncAgressiveCuff", targetPlayer, "back", cuffType, slot, heading)
    Wait(100)

    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, "cop_p2_back_left", 8.0, -8.0, 4000, 33, 0, false, false, false)

    while not targetState.gettingCuffed do
        targetState = Player(targetPlayer).state
        Wait(10)
    end

    AttachEntityToEntity(ped, targetPed, 11816, -0.1, -0.55, 0.0, 0.0, 0.0, -20.0, false, false, false, false, 20, false)

    while targetState.gettingCuffed do
        targetState = Player(targetPlayer).state
        Wait(100)
    end

    DetachEntity(ped)
    playerState:set("isCuffing", false, true)

    if IsEntityPlayingAnim(ped, dict, "cop_p2_back_left", 3) then
        StopAnimTask(ped, dict, "cop_p2_back_left", 2.0)
    end
end

local function IsPedCuffed(ped)
    local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    local targetState = Player(targetPlayer).state
    return targetState.isCuffed
end

local function canCuffPed(ped, cuffType)
    local anim = handsAnim["hu"]
    if IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
        return true, false
    end

    anim = handsAnim["huk"]
    if IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) or cuffType == "cuffs" then
        return true, true
    end
end

local function uncuffPed(ped, cuffType)
    if not ped or not DoesEntityExist(ped) then return end

    lib.requestAnimDict("mp_arresting")
    playAnimation(cache.ped, "mp_arresting", "a_uncuff")
    Wait(1000)
    ClearPedTasks(cache.ped)

    local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    TriggerServerEvent("ND_Police:uncuffPed", serverId, cuffType)
    StopEscortPlayer(serverId)
end

local function cuffPed(ped, cuffType, slot)
    if not ped or not DoesEntityExist(ped) then return end

    local allow, agressive = canCuffPed(ped, cuffType)
    if not allow then return end

    local player = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    if agressive then
        agressiveCuffPlayer(cache.ped, ped, player, cuffType, slot)
    else
        normalCuffPlayer(cache.ped, ped, player, cuffType, slot)
    end
end

local function getTargetPed()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(coords, 1.5, false)
    return player and GetPlayerPed(player)
end

lib.callback.register("ND_Police:syncAgressiveCuff", function(angle, cuffType, heading)
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local dict = "mp_arrest_paired"
    local escaped = false

    SetEntityHeading(ped, heading)
    Wait(10)
    
    local state = Player(cache.serverId).state
    state:set("gettingCuffed", true, true)

    lib.requestAnimDict(dict)
	TaskPlayAnim(ped, dict, "crook_p2_back_left", 8.0, -8.0, 4500, 33, 0, false, false, false)
    
    SetTimeout(4500, function()
        if escaped then return end
        state:set("gettingCuffed", false, true)
        setCuffed(true, angle, cuffType)
    end)

    escaped = lib.skillCheck("hard")
    if escaped then
        state:set("gettingCuffed", false, true)
        StopAnimTask(ped, dict, "crook_p2_back_left", 2.0)
    end

    return escaped
end)

RegisterNetEvent("ND_Police:syncNormalCuff", function(angle, cuffType)
    setCuffed(true, angle, cuffType)
end)

RegisterNetEvent("ND_Police:uncuffPed", function()
    setCuffed(false)
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    enablePlayer(cache.ped)

    local pool = GetGamePool("CObject")
    for i=1, #pool do
        local obj = pool[i]
        local model = GetEntityModel(obj)
        for _, cuffModel in pairs(cuffModels) do
            if model == cuffModel and NetworkGetEntityOwner(obj) == cache.playerId then
                DeleteEntity(obj)
            end
        end
    end
end)

AddEventHandler("ND_Police:unziptie", function()
    if cache.vehicle then return end
    local targetPed = getTargetPed()
    uncuffPed(targetPed, "zipties")
end)

exports("ziptie", function(data, slot)
    if cache.vehicle then return end
    local targetPed = getTargetPed()
    cuffPed(targetPed, "zipties", slot)
end)

exports("uncuff", function(data, slot)
    if cache.vehicle then return end
    local targetPed = getTargetPed()
    uncuffPed(targetPed, "cuffs")
end)

exports("cuff", function(data, slot)
    if cache.vehicle then return end
    local targetPed = getTargetPed()
    cuffPed(targetPed, "cuffs", slot)
end)

lib.addKeybind({
    name = "handsup",
    description = "Hands up",
    defaultKey = "X",
    onPressed = function(self)
        if not handsUpStatus and cache.vehicle or not handsUpStatus and LocalPlayer.state.blockHandsUp or GetPedParachuteState(cache.ped) > 0 then return end

        holdingHands = true
        local time = GetCloudTimeAsInt()

        while holdingHands and GetCloudTimeAsInt()-time < 2 do Wait(0) end
        
        if GetCloudTimeAsInt()-time >= 2 then
            return holdingHands and toggleHandsUp(not handsUpStatus, "huk")
        end

        toggleHandsUp(not handsUpStatus, "hu")
    end,
    onReleased = function(self)
        holdingHands = false
    end
})

exports.ox_target:addGlobalPlayer({
    {
        name = "ND_Police:cuff",
        icon = "fas fa-handcuffs",
        label = "Cuff player",
        distance = 1.5,
        items = "cuffs",
        canInteract = function(entity)
            return canCuffPed(entity, "cuffs") and not IsPedCuffed(entity)
        end,
        onSelect = function(data)
            local ped = data.entity
            cuffPed(ped, "cuffs")
        end
    },
    {
        name = "ND_Police:ziptie",
        icon = "fas fa-handcuffs",
        label = "Ziptie player",
        distance = 1.5,
        items = "zipties",
        canInteract = function(entity)
            return canCuffPed(entity, "zipties") and not IsPedCuffed(entity)
        end,
        onSelect = function(data)
            local ped = data.entity
            cuffPed(ped, "zipties")
        end
    },
    {
        name = "ND_Police:uncuff",
        icon = "fas fa-handcuffs",
        label = "Remove handcuffs",
        distance = 1.5,
        items = "handcuffkey",
        canInteract = function(entity)
            return IsPedCuffed(entity) and Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.cuffType == "cuffs"
        end,
        onSelect = function(data)
            uncuffPed(data.entity, "cuffs")
        end
    },
    {
        name = "ND_Police:unziptie",
        icon = "fas fa-handcuffs",
        label = "Remove zipties",
        distance = 1.5,
        items = "tools",
        canInteract = function(entity)
            return IsPedCuffed(entity) and Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.cuffType == "zipties"
        end,
        onSelect = function(data)
            uncuffPed(data.entity, "zipties")
        end
    },
    {
        name = "ND_Police:searchPlayer",
        icon = "fa-solid fa-magnifying-glass",
        label = "Search",
        distance = 1.5,
        canInteract = function(entity)
            if handsUpStatus or LocalPlayer.state.invBusy then return end
            local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
            local state = Player(targetPlayer).state
            return state.isCuffed or state.handsUp
        end,
        onSelect = function(data)
            local targetPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            if not targetPlayer then return end
            
            exports.ox_inventory:openInventory("player", targetPlayer)
        end
    }
})
