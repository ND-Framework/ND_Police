local playerState = LocalPlayer.state

function StopEscortPlayer(serverId)
    TriggerServerEvent('ND_Police:setPlayerEscort', serverId, false)
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

local IsPedCuffed = IsPedCuffed
local IsEntityAttachedToEntity = IsEntityAttachedToEntity

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
            AttachEntityToEntity(cache.ped, ped, 11816, 0.4, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
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