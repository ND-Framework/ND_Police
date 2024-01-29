local data_shotspotter = lib.load("data.shotspotter")
local lastTrigger = 0

local function hasIgnoredJob()
    local player = Bridge.getPlayer()
    for i=1, #data_shotspotter.ignoredJobs do
        local job = data_shotspotter.ignoredJobs[i]
        if Bridge.doesPlayerHaveJob(player, job) then
            return true
        end
    end
end

local function getPlayerPostal()
    if GetResourceState("ModernHUD") == "started" then
        return exports["ModernHUD"]:getPostal()
    elseif GetResourceState("nearest-postal") == "started" then
        return exports["nearest-postal"]:getPostal()
    end
end

local function isPlayerNearShotspotter(coords)
    for i=1, #data_shotspotter.locations do
        local loc = data_shotspotter.locations[i]
        if #(coords.xy-loc.xy) < data_shotspotter.radius then
            return true
        end
    end
end

local function isWeaponIgnored(weapon)
    for i=1, #data_shotspotter.ignoredWeapons do
        local ignoredWeapon = data_shotspotter.ignoredWeapons[i]
        if ignoredWeapon == weapon then
            return true
        end
    end
end

local function usingSuppressor(ped, weapon)
    for i=1, #data_shotspotter.suppresors do
        local suppresor = data_shotspotter.suppresors[i]
        if HasPedGotWeaponComponent(ped, weapon, suppresor) then
            return true
        end
    end
end

local function triggerShotSpotter()
    if hasIgnoredJob() then return end

    local ped = cache.ped
    local time = GetCloudTimeAsInt()

    if time-lastTrigger < data_shotspotter.cooldown then return end
    lastTrigger = time
    
    local coords = GetEntityCoords(ped)
    local weapon = cache.weapon
    if not isPlayerNearShotspotter(coords) or isWeaponIgnored(weapon) or usingSuppressor(ped, weapon) then return end
    
    local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local postal = getPlayerPostal()
    local location = postal and ("%s %s (%s)"):format(street, zoneName, postal) or ("%s %s"):format(street, zoneName)
    
    Wait(data_shotspotter.delay * 1000)
    TriggerServerEvent("ND_Police:shotspotter", location, coords)
end

AddEventHandler("ND_Police:playerJustShot", function(weaponData)
    triggerShotSpotter()
end)

if data_shotspotter.debug then
    for i=1, #data_shotspotter.locations do
        local loc = data_shotspotter.locations[i]
        local blip = AddBlipForRadius(loc.x, loc.y, loc.z, data_shotspotter.radius)
        SetBlipAlpha(blip, 100)
    end
end
