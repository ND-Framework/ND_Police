local playerState = LocalPlayer.state
local lastNearbySeatCheck = 0
local nearBySeatStatus = false

local IsPedCuffed = IsPedCuffed
local IsEntityAttachedToEntity = IsEntityAttachedToEntity

function StopEscortPlayer(serverId, setIntoVeh, setIntoSeat)
    TriggerServerEvent('ND_Police:setPlayerEscort', serverId, false, setIntoVeh, setIntoSeat)
    LocalPlayer.state.blockHandsUp = false
    StopAnimTask(cache.ped, "amb@world_human_drinking@coffee@female@base", "base", 2.0)
end

local function escortPlayer(ped, id)
    lib.requestAnimDict("amb@world_human_drinking@coffee@female@base")
    TaskPlayAnim(cache.ped, "amb@world_human_drinking@coffee@female@base", "base", 8.0, 8.0, -1, 50, 0, false, false, false)
    LocalPlayer.state.blockHandsUp = true

    if not id then
        id = NetworkGetPlayerIndexFromPed(ped)
    end

    TriggerServerEvent('ND_Police:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))
end

local function nearbySeatVehicleCheck(ped)
    local time = GetCloudTimeAsInt()
    if time-lastNearbySeatCheck < 1 then
        return nearBySeatStatus
    end

    lastNearbySeatCheck = time

    local coords = GetEntityCoords(ped)
    local veh = lib.getClosestVehicle(coords, 4.0, true)
    nearBySeatStatus = DoesEntityExist(veh) and AreAnyVehicleSeatsFree(veh) and GetVehicleDoorLockStatus(veh) ~= 2

    return nearBySeatStatus
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'escort',
        icon = 'fas fa-hands-bound',
        label = 'Escort',
        distance = 1.5,
        canInteract = function(entity)
            return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped) and not playerState.invBusy
        end,
        onSelect = function(data)
            escortPlayer(data.entity)
        end
    },
    {
        name = 'release',
        icon = 'fas fa-hands-bound',
        label = 'Release',
        distance = 1.5,
        canInteract = function(entity)
            return IsPedCuffed(entity) and IsEntityAttachedToEntity(entity, cache.ped) and not playerState.invBusy
        end,
        onSelect = function(data)
            StopEscortPlayer(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
        end
    },
    {
        name = "ND_Police:vehicleEscort",
        icon = "fa-solid fa-right-to-bracket",
        label = "Place in vehicle",
        distance = 1.5,
        canInteract = function(entity)
            local ped = cache.ped
            return IsPedCuffed(entity) and IsEntityAttachedToEntity(entity, ped) and not playerState.invBusy and nearbySeatVehicleCheck(ped)
        end,
        onSelect = function(data)
            local coords = GetEntityCoords(cache.ped)
            local veh = lib.getClosestVehicle(coords, 4.0, true)
            if not DoesEntityExist(veh) or not AreAnyVehicleSeatsFree(veh) then return end

            local bones = {"seat_dside_r", "seat_pside_r"}
            local closestDist = nil
            local closestSeat = nil

            for i=1, #bones do
                local dist = #(coords - GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, bones[i])))
                if (not closestDist or not closestSeat or dist < closestDist) and IsVehicleSeatFree(veh, i) then
                    closestSeat = i
                    closestDist = dist
                end
            end

            if not closestSeat and IsVehicleSeatFree(veh, 0) then
                closestSeat = 0
            elseif not closestSeat then
                return
            end

            StopEscortPlayer(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), VehToNet(veh), closestSeat)
        end
    },
})

local isEscorted = playerState.isEscorted
local AttachEntityToEntity = AttachEntityToEntity
local IsPedWalking = IsPedWalking
local IsEntityPlayingAnim = IsEntityPlayingAnim
local IsPedRunning = IsPedRunning
local IsPedSprinting = IsPedSprinting
local TaskPlayAnim = TaskPlayAnim
local StopAnimTask = StopAnimTask

local function setEscorted(serverId)
    local dict = 'anim@move_m@prisoner_cuffed'
    local dict2 = 'anim@move_m@trash'

    while isEscorted do
        local player = GetPlayerFromServerId(serverId)
        local ped = player > 0 and GetPlayerPed(player)

        if not ped then break end

        if not IsEntityAttachedToEntity(cache.ped, ped) then
            AttachEntityToEntity(cache.ped, ped, 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
        end

        if IsPedWalking(ped) then
            if not IsEntityPlayingAnim(cache.ped, dict, 'walk', 3) then
                lib.requestAnimDict(dict)
                TaskPlayAnim(cache.ped, dict, 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
            end
        elseif IsPedRunning(ped) or IsPedSprinting(ped) then
            if not IsEntityPlayingAnim(cache.ped, dict2, 'run', 3) then
                lib.requestAnimDict(dict2)
                TaskPlayAnim(cache.ped, dict2, 'run', 8.0, -8, -1, 1, 0.0, false, false, false)
            end
        else
            StopAnimTask(cache.ped, dict, 'walk', -8.0)
            StopAnimTask(cache.ped, dict2, 'run', -8.0)
        end

        Wait(0)
    end

    RemoveAnimDict(dict)
    RemoveAnimDict(dict2)
    playerState:set('isEscorted', false, true)
end

AddStateBagChangeHandler('isEscorted', ('player:%s'):format(cache.serverId), function(_, _, value)
    isEscorted = value

    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
        StopAnimTask(cache.ped, 'anim@move_m@prisoner_cuffed', 'walk', -8.0)
        StopAnimTask(cache.ped, 'anim@move_m@trash', 'run', -8.0)
    end

    if value then setEscorted(value) end
end)

if isEscorted then
    CreateThread(function()
        setEscorted(isEscorted)
    end)
end