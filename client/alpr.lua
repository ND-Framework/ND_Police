local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestCapsule = StartShapeTestCapsule
local GetShapeTestResult = GetShapeTestResult
local GetEntitySpeed = GetEntitySpeed
local playerState = LocalPlayer.state

local vehicleData = setmetatable({}, {
	__index = function(self, index)
		local data = lib.getVehicleProperties(index, model)
        print(json.encode(data))
		if data then
			data = {
				name = data.name,
				make = data.make,
			}

			self[index] = data
			return data
		end
	end
})

local function updateTextUI()
    local hit, entity = lib.raycast.cam(tonumber('000111111', 2), 0, 50)

    if hit and IsEntityAVehicle(entity) then
        local speed = math.floor(GetEntitySpeed(entity) * 2.23)
        local data = vehicleData[GetEntityArchetypeName(entity)]

        lib.showTextUI(('Speed: %s MPH  \nPlate: %s '):format(speed, GetVehicleNumberPlateText(entity)))
    end
end

local active = false

RegisterCommand('alpr', function()
    local player = NDCore.getPlayer()
    local service = playerState.InService
    print(service)
    if service == false or playerState.invBusy then return end

    active = not active

    while cache.vehicle and active do
        updateTextUI()
        Wait(500)
    end

    lib.hideTextUI()
end)
