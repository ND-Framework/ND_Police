local cuffItems = {"cuffs", "zipties"}
local uncuffItems = {
    ["cuffs"] = "handcuffkey",
    ["zipties"] = "tools"
}

local function cuffCheck(src, target, cuffType)
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not lib.table.conains(cuffItems, cuffType) or
        Ox_inventory:GetItemCount(src, cuffType) == 0
        then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and

        targetState.handsUp and
        not targetState.gettingCuffed and
        not targetState.isCuffing and
        not targetState.isCuffed
end

local function uncuffCheck(src, target, cuffType)
    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    
    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not uncuffItems[cuffType] or
        Ox_inventory:GetItemCount(src, uncuffItems[cuffType]) == 0
        then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and
        targetState.isCuffed
end

local function isItemCorrect()
    cuffType:find("zipties")
end

RegisterNetEvent("ND_Police:syncAgressiveCuff", function(target, angle, cuffType, slot, heading)
    local src = source
    if not cuffCheck(src, target, cuffType) or not Ox_inventory:RemoveItem(src, cuffType, 1, nil, slot) then return end
    TriggerClientEvent("ND_Police:syncAgressiveCuff", target, angle, cuffType, heading)
end)

RegisterNetEvent("ND_Police:syncNormalCuff", function(target, angle, cuffType, slot)
    local src = source
    if not cuffCheck(src, target, cuffType) or not Ox_inventory:RemoveItem(src, cuffType, 1, nil, slot) then return end
    TriggerClientEvent("ND_Police:syncNormalCuff", target, angle, cuffType)
end)

RegisterNetEvent("ND_Police:uncuffPed", function(target, cuffType, slot)
    local src = source
    if not uncuffCheck(src, target, cuffType) or not Ox_inventory:RemoveItem(src, cuffType, 1, nil, slot) then return end
    TriggerClientEvent("ND_Police:uncuffPed", target)
end)
