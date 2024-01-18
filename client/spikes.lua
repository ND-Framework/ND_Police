exports.ox_target:addModel('p_ld_stinger_s', {
    {
        icon = 'fa-solid fa-lock',
        label = 'Pick up spike strip',
        onSelect = function(data)
            if lib.progressBar({
                duration = 1500,
                label = 'Picking up spike strips',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                },
                anim = {
                    dict = 'amb@prop_human_bum_bin@idle_b',
                    clip = 'idle_d'
                },
            }) then
                TriggerServerEvent('ND_Police:retrieveSpikestrip', ObjToNet(data.entity))
            end
        end
    },
})

local glm = require 'glm'

exports('deploySpikestrip', function()
    if cache.vehicle then
        lib.notify({title = 'Cannot deploy a spikestrip while in a vehicle', type = 'error'})
        return
    end

    local count = exports.ox_inventory:Search('count', 'spikestrip')
    local options = {}
    local size

    if count < 1 then
        return
    elseif count > 1 then
        for i = 1, count do
            options[i] = {
                value = tostring(i),
                label = tostring(i)
            }

            if i == 4 then break end
        end

        size = lib.inputDialog('Deploy Spikestrip', {
            { type = 'select', label = 'Size', options = options }
        })

        if not size then return end

        size = tonumber(size[1])
    else
        size = 1
    end

    if lib.progressBar({
        duration = 1000 * size,
        label = 'Placing Spikestrip',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d'
        },
    }) then
        local segment = {
            GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, 0.0),
            GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 4.15 * size - 1, 0.0)
        }
        local length = glm.snap(#(segment[1] - segment[2]), 0.01)

        for i = 1, 2 do
            while true do
                ---@diagnostic disable-next-line: redundant-parameter
                local retrieval, groundZ = GetGroundZFor_3dCoord_2(segment[i].x, segment[i].y, segment[i].z, false, true)
                segment[i] = vec3(segment[i].x, segment[i].y, retrieval and groundZ or segment[i].z + 1)

                if retrieval then
                    break
                end
            end
        end

        segment[2] = segment[1] - glm.clampLength(segment[1] - segment[2], length)

        TriggerServerEvent('ND_Police:deploySpikestrip', {
            segment = segment,
            size = size
        })
    end
end)

local wheelBones = {
    standard = {
        [0] = 'wheel_lf',
        'wheel_rf',
        'wheel_lm1',
        'wheel_rm1',
        'wheel_lr',
        'wheel_rr',
        [547] = 'wheel_lm2',
        [549] = 'wheel_rm2',
    },
    halftrack = {
        [0] = 'wheel_lf',
        'wheel_rf',
    },
}

local flags = tonumber('11111000100001111111', 2)
local GetEntityModel = GetEntityModel
local GetClosestVehicle = GetClosestVehicle
local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local IsEntityTouchingEntity = IsEntityTouchingEntity
local GetVehicleNumberOfWheels = GetVehicleNumberOfWheels
local IsVehicleTyreBurst = IsVehicleTyreBurst
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local SetVehicleTyreBurst = SetVehicleTyreBurst

AddStateBagChangeHandler('inScope', '', function(bagName, key, value, reserved, replicated)
    if value then
        local entity = GetEntityFromStateBagName(bagName)

        if GetEntityModel(entity) ~= `p_ld_stinger_s` then
            return
        end

        local coords = GetEntityCoords(entity)
        local segment

        while DoesEntityExist(entity) do
            local sleep = 500
            local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 10.0, 0, flags)

            if vehicle ~= 0 then
                sleep = 0
                local model = GetEntityModel(vehicle)

                if model ~= `monster4` and (GetVehicleNumberOfWheels(vehicle) < 10 or model == `halftrack`) then
                    local newCoords = GetEntityCoords(entity)

                    if coords ~= newCoords or not segment then
                        coords = newCoords
                        segment = {
                            GetOffsetFromEntityInWorldCoords(entity, 0.0, -1.84, 0.0),
                            GetOffsetFromEntityInWorldCoords(entity, 0.0, 1.84, 0.0)
                        }
                    end

                    if IsEntityTouchingEntity(entity, vehicle) then
                        local bones = model == `halftrack` and wheelBones.halftrack or wheelBones.standard

                        for k, v in pairs(bones) do
                            if not IsVehicleTyreBurst(vehicle, k, false) and glm.segment.distance(segment[1], segment[2], GetEntityBonePosition_2(vehicle, GetEntityBoneIndexByName(vehicle, v))) < 1 then
                                if math.random(10) > 7 then
                                    SetVehicleTyreBurst(vehicle, k, false, 500.0)
                                end

                                break
                            end
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end
end)