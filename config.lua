Config = {}

Config.PoliceGroups = { 'police' }

Config.clearGSR = 15 -- time in minutes
Config.clearGSRinWater = 1 --minutes

Config.JailCoords = vector3(459.13,-1001.70,24.91)
Config.JailHeading = 266.1116

Config.unJailCoords = vector3(489.7115,-1002.5173,27.8378)
Config.unJailHeading = 266.1116

Config.Notify = "Changed mode to %s" -- %s will be replaced with the vehicle mode, e.g. S+
Config.VehicleModes = { "B+", "A", "A+", "S", "S+" }
Config.VehicleModifications = {
    ["B+"] = { Turbo = false, XenonHeadlights = false, Engine = -1, Brakes = -1, Transmission = -1, XenonHeadlightsColor = 0 },
    ["A"] = { Turbo = false, XenonHeadlights = false, Engine = -1, Brakes = -1, Transmission = -1, XenonHeadlightsColor = -1 },
    ["A+"] = { Turbo = false, XenonHeadlights = false, Engine = -1, Brakes = -1, Transmission = -1, XenonHeadlightsColor = 2 },
    ["S"] = { Turbo = false, XenonHeadlights = false, Engine = -1, Brakes = -1, Transmission = -1, XenonHeadlightsColor = 1 },
    ["S+"] = { Turbo = true, XenonHeadlights = false, Engine = -1, Brakes = -1, Transmission = -1, XenonHeadlightsColor = 12 }
}

-- Vehicle configurations
Config.VehiclesConfig = {
    ["polbuffalor"] = {
        ["B+"] = { fInitialDragCoeff = 4.0, fDriveInertia = 1.0, fBrakeForce = 0.95, fInitialDriveMaxFlatVel = 171.0, fSteeringLock = 44.0, fInitialDriveForce = 0.23 },
        ["A"] = { fInitialDragCoeff = 3.5, fDriveInertia = 1.0, fBrakeForce = 1.1, fInitialDriveMaxFlatVel = 174.0, fSteeringLock = 44.0, fInitialDriveForce = 0.245 },
        ["A+"] = { fInitialDragCoeff = 3.3, fDriveInertia = 1.0, fBrakeForce = 1.15, fInitialDriveMaxFlatVel = 175.0, fSteeringLock = 44.0, fInitialDriveForce = 0.265 },
        ["S"] = { fInitialDragCoeff = 3.0, fDriveInertia = 1.0, fBrakeForce = 1.295, fInitialDriveMaxFlatVel = 178.0, fSteeringLock = 43.0, fInitialDriveForce = 0.285 },
        ["S+"] = { fInitialDragCoeff = 2.9, fDriveInertia = 1.0, fBrakeForce = 1.325, fInitialDriveMaxFlatVel = 182.0, fSteeringLock = 43.0, fInitialDriveForce = 0.31 }
    },
    -- Add configurations for other vehicles as needed
}

-- General vehicle configurations
Config.GeneralConfig = true
Config.GeneralVehicleConfig = {
    ["B+"] = { fInitialDragCoeff = 4.0, fDriveInertia = 1.0, fBrakeForce = 1.7, fInitialDriveMaxFlatVel = 168.0, fSteeringLock = 44.5, fInitialDriveForce = 0.23 },
    ["A"] = { fInitialDragCoeff = 3.6, fDriveInertia = 1.0, fBrakeForce = 1.175, fInitialDriveMaxFlatVel = 173.0, fSteeringLock = 44.0, fInitialDriveForce = 0.245 },
    ["A+"] = { fInitialDragCoeff = 3.3, fDriveInertia = 1.1, fBrakeForce = 1.25, fInitialDriveMaxFlatVel = 176.0, fSteeringLock = 44.0, fInitialDriveForce = 0.27 },
    ["S"] = { fInitialDragCoeff = 3.1, fDriveInertia = 1.0, fBrakeForce = 1.35, fInitialDriveMaxFlatVel = 179.0, fSteeringLock = 43.0, fInitialDriveForce = 0.3 },
    ["S+"] = { fInitialDragCoeff = 3.0, fDriveInertia = 1.0, fBrakeForce = 1.4, fInitialDriveMaxFlatVel = 182.0, fSteeringLock = 43.0, fInitialDriveForce = 0.325 }
}
