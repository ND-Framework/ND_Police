local gear = 1
local currentVehicle = nil
local selectedMode = Config.VehicleModes[1]
local modelDictionary = {}
local playerStateInfo = LocalPlayer.state

function GetSelectedMode()
    return selectedMode
end

local function PopulateModelDictionary()
    for modelName, _ in pairs(Config.VehiclesConfig) do
        modelDictionary[GetHashKey(modelName)] = modelName
    end
end

local function ResetVehicleHandling(vehicle)
    SetVehicleModKit(vehicle, 0)

    for modIndex = 0, 35 do
        SetVehicleMod(vehicle, modIndex, GetVehicleMod(vehicle, modIndex), false)
    end

    for wheelIndex = 0, 3 do
        SetVehicleWheelIsPowered(vehicle, wheelIndex, true)
    end
end

local function RetrieveModelFromHash(hash)
    return modelDictionary[hash]
end

local function IsVehicleEligible(vehicle)
    if Config.GeneralConfig then 
        return true
    end

    return Config.VehiclesConfig[RetrieveModelFromHash(GetEntityModel(vehicle))]
end

local function ObtainHandlingConfig(vehicleHash)
    local vehicleModel = RetrieveModelFromHash(vehicleHash)
    return Config.VehiclesConfig[vehicleModel] and Config.VehiclesConfig[vehicleModel][selectedMode]
end

local function ObtainGeneralHandlingConfig()
    return Config.GeneralVehicleConfig and Config.GeneralVehicleConfig[selectedMode]
end

local function ImplementHandling(vehicle)
    local handlingConfig = ObtainHandlingConfig(GetEntityModel(vehicle))

    if Config.GeneralConfig and not handlingConfig then
        handlingConfig = ObtainGeneralHandlingConfig()
    end

    for key, value in pairs(handlingConfig) do
        local valueType = type(value)
        local handlingFunction = {
            float = SetVehicleHandlingFloat,
            integer = SetVehicleHandlingInt,
            vector3 = SetVehicleHandlingVector,
        }

        local applyHandling = handlingFunction[valueType]
        if applyHandling then
            applyHandling(vehicle, "CHandlingData", key, value)
        end
    end

    ResetVehicleHandling(vehicle)
end

local function ImplementVehicleMods(vehicle)
    local vehicleMode = Config.VehicleModes[gear]

    local function ApplyModification(modType, modIndex, configKey)
        local configValue = Config["VehicleModifications"][vehicleMode][configKey] or GetVehicleMod(vehicle, modIndex)
        ToggleVehicleMod(vehicle, modIndex, configValue)
    end

    ApplyModification("ToggleVehicleMod", 18, "Turbo") -- Turbo
    ApplyModification("ToggleVehicleMod", 22, "XenonHeadlights") -- Xenon Headlights
    ApplyModification("SetVehicleMod", 11, "Engine") -- Engine
    ApplyModification("SetVehicleMod", 12, "Brakes") -- Brakes
    ApplyModification("SetVehicleMod", 13, "Transmission") -- Transmission

    local xenonHeadlightsColor = Config["VehicleModifications"][vehicleMode]["XenonHeadlightsColor"] or GetVehicleXenonLightsColour(vehicle)
    SetVehicleXenonLightsColour(vehicle, xenonHeadlightsColor) -- Xenon Headlights Color
end

local function ResetGearIfDistinctVehicle(vehicle)
    if currentVehicle and vehicle ~= currentVehicle then
        gear = 1
    end
end

local function SwitchVehicleMode(vehicle)
    local vehicleModel = RetrieveModelFromHash(GetEntityModel(vehicle))
    repeat
        gear = (gear % #Config.VehicleModes) + 1
        selectedMode = Config.VehicleModes[gear]
    until Config.GeneralVehicleConfig[selectedMode]
    ResetGearIfDistinctVehicle(vehicle)
    currentVehicle = vehicle
end

RegisterNetEvent('ChangeMode')
AddEventHandler('ChangeMode', function()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped)
        local service = playerStateInfo.InService

        if IsVehicleEligible(vehicle) then
            ProcessVehicleModeChange(vehicle)
        end
    end
end)

function IsVehicleEligible(vehicle)
    return DoesEntityExist(vehicle) and playerStateInfo.InService
end

function ProcessVehicleModeChange(vehicle)
    SwitchVehicleMode(vehicle)
    ImplementHandling(vehicle)
    ImplementVehicleMods(vehicle)

    lib.notify({
        title = Config.Notify:format(selectedMode),
        type = 'inform'
    })
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    PopulateModelDictionary()
end)

RegisterCommand('pursuitmode', function(source)
    TriggerEvent('ChangeMode')
end, false)

RegisterKeyMapping('pursuitmode', 'Pursuit', 'keyboard', 'Y')
