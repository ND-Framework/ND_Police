local createdEvidence = {}
local glm = require 'glm'
local activeLoop = false
local evidence = {}
local evidenceMetadata = lib.load("data.evidence")

CreateThread(function()
    while true do
        Wait(1000)

        if next(createdEvidence) then
            TriggerServerEvent('ND_Police:distributeEvidence', createdEvidence)

            table.wipe(createdEvidence)
        end
    end
end)


local function createNode(ammo, item, coords, entity)
    if entity then
        coords = glm.snap(GetOffsetFromEntityGivenWorldCoords(entity, coords.x, coords.y, coords.z), vec3(1 / 2 ^ 4))
        coords = vec4(coords, NetworkGetNetworkIdFromEntity(entity))
    else
        coords = glm.snap(coords, vec3(1 / 2 ^ 4))
    end

    local entry = {
        [item] = {
            [ammo] = 1
        }
    }

    if createdEvidence[coords] then
        lib.table.merge(createdEvidence[coords], entry)
    else
        createdEvidence[coords] = entry
    end
end

local function startPedShooting(ammo)
    local hit, entityHit, endCoords = lib.raycast.cam(tonumber('000111111', 2), 7, 50)
    if not hit then goto skip end
    
    local evidenceInfo = evidenceMetadata[ammo]
    if not evidenceInfo then
        goto skip
    elseif not evidenceInfo.projectile then
        goto next
    end
    
    if GetEntityType(entityHit) == 0 then
        createNode(ammo, 'projectile', endCoords)
    elseif NetworkGetEntityIsNetworked(entityHit) then
        createNode(ammo, 'projectile', endCoords, entityHit)
    end

    Wait(100)
    ::next::

    if not evidenceInfo.casing then goto skip end

    local pedCoords = GetEntityCoords(cache.ped)
    local direction = math.rad(math.random(360))
    local magnitude = math.random(100) / 20
    local coords = vec3(pedCoords.x + math.sin(direction) * magnitude, pedCoords.y + math.cos(direction) * magnitude, pedCoords.z)
    local success, impactZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)

    if success then
        createNode(ammo, 'casing', vector3(coords.xy, impactZ))
    end

    ::skip::
end

AddEventHandler("ND_Police:playerJustShot", function(weaponData)
    local ammo = weaponData?.ammo
    return ammo and startPedShooting(ammo)
end)

local function removeNode(coords)
    if evidence[coords] then
        if coords.w then
            exports.ox_target:removeEntity(coords.w, ('evidence_%s'):format(coords))
        else
            exports.ox_target:removeZone(evidence[coords])
        end

        evidence[coords] = nil
    end
end

RegisterNetEvent('ND_Police:updateEvidence', function(addEvidence, clearEvidence)
    for coords in pairs(addEvidence) do
        if not evidence[coords] then
            local target = {
                coords = coords,
                radius = 1 / 2 ^ 4,
                drawSprite = true,
                options = {
                    {
                        name = ('evidence_%s'):format(coords),
                        icon = 'fa-solid fa-magnifying-glass',
                        label = 'Collect evidence',
                        offsetSize = 1 / 2 ^ 3,
                        absoluteOffset = true,
                        offset = coords.w and coords.xyz,
                        onSelect = function(data)
                            local nodes = {}
                            local targetCoords = data.coords

                            for k in pairs(evidence) do
                                if #(targetCoords - (k.w and GetOffsetFromEntityInWorldCoords(NetworkGetEntityFromNetworkId(k.w), k.x, k.y, k.z) or k)) < 1 then
                                    removeNode(k)
                                    nodes[#nodes + 1] = k
                                end
                            end

                            TriggerServerEvent('ND_Police:collectEvidence', nodes)
                        end
                    }
                }
            }

            if coords.w then
                exports.ox_target:addEntity(coords.w, target.options)
                evidence[coords] = coords
            else
                evidence[coords] = exports.ox_target:addSphereZone(target)
            end
        end
    end

    -- for coords in pairs(clearEvidence) do
    --     removeNode(coords)
    -- end
end)