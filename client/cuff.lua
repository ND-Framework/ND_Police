local isCuffed = false  -- Local tracking for the player's own cuff status
local otherPlayerCuffedStatus = {}  -- Table to track other players' cuff status
local cuffProp = nil    -- Variable to store the handcuff prop
local handsUp = false   -- Variable to track hands-up status

-- Function to check if the player is cuffed
function isPlayerCuffed()
    return isCuffed
end

function toggleHandsUp()
    local playerPed = PlayerPedId()
    
    -- Check if the player is inside a vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        
        return
    end

    if handsUp then
        -- If hands are currently up, lower them
        ClearPedTasksImmediately(playerPed)
        handsUp = false
        
    else
        -- If hands are down, raise them
        RequestAnimDict("random@mugging3")
        while not HasAnimDictLoaded("random@mugging3") do
            Citizen.Wait(0)
        end

        TaskPlayAnim(playerPed, "random@mugging3", "handsup_standing_base", 8.0, -8.0, -1, 49, 0, 0, 0, 0)
        handsUp = true
        
    end
end



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isPlayerCuffed() then
            -- Disable specific actions when the player is cuffed
            DisableControlAction(0, 323, true)  -- "Hands up" (X key)
            DisableControlAction(0, 73, true)   -- Secondary "hands up" control
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(0, 37, true)   -- Weapon select
            DisableControlAction(0, 44, true)   -- Cover
            DisableControlAction(0, 140, true)  -- Melee light attack
            DisableControlAction(0, 141, true)  -- Melee heavy attack
            DisableControlAction(0, 142, true)  -- Alt melee attack
            DisableControlAction(0, 257, true)  -- Melee attack alternate
            DisableControlAction(0, 263, true)  -- Melee alternate heavy
            DisableControlAction(0, 45, true)   -- Reload

            -- Disable movement controls (optional)
            DisableControlAction(0, 21, true)  -- Sprint
            DisableControlAction(0, 22, true)  -- Jump
            -- DisableControlAction(0, 23, true)  -- Enter vehicle
            -- DisableControlAction(0, 30, true)  -- Move Left/Right
            -- DisableControlAction(0, 31, true)  -- Move Forward/Back

            -- Prevent "hands up" emote if cuffed
            if IsControlJustPressed(0, 323) or IsControlJustPressed(0, 73) then
                ClearPedTasksImmediately(PlayerPedId())
                Citizen.Wait(100)
            end

            -- Continuously enforce the cuffed idle animation
            if not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) then
                RequestAnimDict("mp_arresting")
                while not HasAnimDictLoaded("mp_arresting") do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
            end
        else
            -- If not cuffed, allow toggle of hands up/down when pressing X
            if IsControlJustPressed(0, 323) then
                toggleHandsUp()
            end
        end
    end
end)

-- Toggle function to manage cuff status
RegisterNetEvent('customCuff:toggleCuff')
AddEventHandler('customCuff:toggleCuff', function(state)
    isCuffed = state
    if isCuffed then
        ClearPedTasksImmediately(PlayerPedId())  -- Stop all tasks when cuffed
        handsUp = false  -- Reset hands-up status when cuffed
    end
end)

-- Add cuff, uncuff, and search options
Citizen.CreateThread(function()
    exports.ox_target:addGlobalPlayer({
        {
            name = 'CuffPlayer',
            icon = 'fas fa-handcuffs',
            label = 'Cuff',
            onSelect = function(data)
                local targetPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                playCuffingAnimation(data.entity, targetPlayerId)  -- Play the animation and trigger cuff
            end,
            distance = 1.5,
            canInteract = function(entity, distance)
                local playerData = exports["ND_Core"]:getPlayer(source)
                local targetPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local isTargetCuffed = otherPlayerCuffedStatus[targetPlayerId] and otherPlayerCuffedStatus[targetPlayerId].isCuffed or false
                return playerData and playerData.job == "Police" and not isTargetCuffed and distance <= 1.5
            end
        },
        {
            name = 'UncuffPlayer',
            icon = 'fas fa-unlock',
            label = 'Uncuff',
            onSelect = function(data)
                TriggerServerEvent("customCuff:removeCuff", GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
            end,
            distance = 1.5,
            canInteract = function(entity, distance)
                local playerData = exports["ND_Core"]:getPlayer(source)
                local targetPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local isTargetCuffed = otherPlayerCuffedStatus[targetPlayerId] and otherPlayerCuffedStatus[targetPlayerId].isCuffed or false
                return playerData and playerData.job == "Police" and isTargetCuffed and distance <= 1.5
            end
        },
        {
            name = 'SearchPlayer',
            icon = 'fas fa-search',
            label = 'Search Suspect',
            onSelect = function(data)
                local targetPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent("customCuff:requestSearchConsent", targetPlayerId)
            end,
            distance = 1.5,
            canInteract = function(entity, distance)
                local playerData = exports["ND_Core"]:getPlayer(source)
                local targetPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local isTargetCuffed = otherPlayerCuffedStatus[targetPlayerId] and otherPlayerCuffedStatus[targetPlayerId].isCuffed or false
                return playerData and playerData.job == "Police" and isTargetCuffed and distance <= 1.5
            end
        }
    })
end)

function playCuffingAnimation(targetPed, targetPlayerId)
    local playerPed = PlayerPedId()
    local targetCoords = GetEntityCoords(targetPed)
    local targetHeading = GetEntityHeading(targetPed)
    local offsetCoords = GetOffsetFromEntityInWorldCoords(targetPed, 0.0, -1.0, 0.0)

    local hasGround, groundZ = GetGroundZFor_3dCoord(offsetCoords.x, offsetCoords.y, targetCoords.z + 1.0)
    offsetCoords = vector3(offsetCoords.x, offsetCoords.y, hasGround and groundZ or targetCoords.z)

    -- Position and align player behind target
    SetEntityCoords(playerPed, offsetCoords.x, offsetCoords.y, offsetCoords.z)
    SetEntityHeading(playerPed, targetHeading)
    FreezeEntityPosition(playerPed, true)

    -- Load animations
    RequestAnimDict("mp_arrest_paired")
    while not HasAnimDictLoaded("mp_arrest_paired") do
        Citizen.Wait(0)
    end

    -- Play officer's animation
    TaskPlayAnim(playerPed, "mp_arrest_paired", "cop_p2_back_right", 8.0, -8.0, 5000, 33, 0, 0, 0, 0)
    
    -- Send event to suspect's client to play their animation and freeze
    TriggerServerEvent('customCuff:playCuffAnimation', targetPlayerId)

    Citizen.Wait(5000)

    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, false)

    -- Trigger server-side cuffing event
    TriggerServerEvent("customCuff:applyCuff", targetPlayerId)
end

-- Show consent request to suspect with notification
RegisterNetEvent("customCuff:searchConsentRequest")
AddEventHandler("customCuff:searchConsentRequest", function(officerId)
    -- Notify for search request
    exports['ox_lib']:notify({
        title = "Search Request",
        description = "An officer wants to search you. Press E to Accept or X to Deny.",
        type = "info",
        duration = 10000
    })

    -- Await suspect's response
    Citizen.CreateThread(function()
        local responded = false
        while not responded do
            Citizen.Wait(0)
            if IsControlJustReleased(0, 38) then -- E key to accept
                TriggerServerEvent("customCuff:respondToSearchConsent", officerId, true)
                responded = true
            elseif IsControlJustReleased(0, 73) then -- X key to deny
                TriggerServerEvent("customCuff:respondToSearchConsent", officerId, false)
                responded = true
            end
        end
    end)
end)

-- Client-side event to open both officer's and suspect's inventories
RegisterNetEvent("customCuff:openDualInventory")
AddEventHandler("customCuff:openDualInventory", function(suspectId)
    print("[DEBUG] Requesting to open dual inventory for suspect ID:", suspectId)
    exports.ox_inventory:openInventory('player', suspectId)  -- Suspect's inventory
  
end)

-- Client-side event to apply cuff restrictions and lock animations
RegisterNetEvent("customCuff:clientCuff")
AddEventHandler("customCuff:clientCuff", function()
    local playerPed = PlayerPedId()
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do
        Citizen.Wait(0)
    end

    -- Start and loop the cuffing animation to prevent cancellation
    TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    SetEnableHandcuffs(playerPed, true)
    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
    isCuffed = true

    -- Disable ragdoll while cuffed
    SetPedCanRagdoll(playerPed, false)

    -- Create and attach the handcuff prop to one hand
    local cuffModel = GetHashKey("p_cs_cuffs_02_s")  -- The model for handcuffs
    RequestModel(cuffModel)
    while not HasModelLoaded(cuffModel) do
        Citizen.Wait(0)
    end

    -- Attach to right hand (adjust offsets as needed)
    cuffProp = CreateObject(cuffModel, 0, 0, 0, true, true, false)
    AttachEntityToEntity(
        cuffProp,
        playerPed,
        GetPedBoneIndex(playerPed, 60309), -- Right Wrist (Bone ID 60309)
        -0.08, 0.08, 0.07,   -- Positional offsets
        0.0, 90.0, 120.0,    -- Rotational offsets
        true, true, false, true, 1, true
    )
end)

RegisterNetEvent("customCuff:clientUncuff")
AddEventHandler("customCuff:clientUncuff", function()
    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    SetEnableHandcuffs(playerPed, false)
    EnableControlAction(0, 24, true)  -- Re-enable weapon firing control

    -- Re-enable ragdoll when uncuffed
    SetPedCanRagdoll(playerPed, true)
	
    -- Check and remove cuff prop if it exists
    if cuffProp and DoesEntityExist(cuffProp) then
        DeleteObject(cuffProp)
        cuffProp = nil
        print("[DEBUG] Handcuff prop removed successfully.")
    else
        print("[DEBUG] No handcuff prop found to remove.")
    end

    isCuffed = false
end)

RegisterNetEvent("customCuff:updateCuffStatus")
AddEventHandler("customCuff:updateCuffStatus", function(playerId, cuffed)
    otherPlayerCuffedStatus[playerId] = { isCuffed = cuffed }
end)

-- Event for suspect to play cuffing animation and freeze movement
RegisterNetEvent('customCuff:clientPlayCuffAnimation')
AddEventHandler('customCuff:clientPlayCuffAnimation', function()
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)

    -- Load animation
    RequestAnimDict("mp_arrest_paired")
    while not HasAnimDictLoaded("mp_arrest_paired") do
        Citizen.Wait(0)
    end

    -- Play suspect's animation
    TaskPlayAnim(playerPed, "mp_arrest_paired", "crook_p2_back_right", 8.0, -8.0, 5000, 33, 0, 0, 0, 0)
    Citizen.Wait(5000)

    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, false)
end)
