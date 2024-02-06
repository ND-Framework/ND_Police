local data_lockers = lib.load("data.locker_rooms")

local clothingComponents = {
    face = 0,
    mask = 1,
    hair = 2,
    torso = 3,
    leg = 4,
    bag = 5,
    shoes = 6,
    accessory = 7,
    undershirt = 8,
    kevlar = 9,
    badge = 10,
    torso2 = 11
}

local clothingProps = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelets = 7
}

local function setClothing(ped, clothing)
    if not clothing then return end

    for name, number in pairs(clothingProps) do
        if clothing[name] and clothing[name].drawable < 0 then
            ClearPedProp(ped, number)
        end
    end

    for component, clothingInfo in pairs(clothing) do
        if clothingComponents[component] then
            SetPedComponentVariation(ped, clothingComponents[component], clothingInfo.drawable, clothingInfo.texture, 0)
        elseif clothingProps[component] then
            SetPedPropIndex(ped, clothingProps[component], clothingInfo.drawable, clothingInfo.texture, true)
        end
    end
end

local function getLockerOptions(lockerOptions, menu)
    local options = {}

    if GetResourceState("ND_AppearanceShops") == "started" then
        options[#options+1] = {
            title = "View saved outfits",
            icon = "fa-solid fa-shirt",
            onSelect = function()
                exports["ND_AppearanceShops"]:openWardrobe(menu)
            end
        }
    end

    for i=1, #lockerOptions do
        local opt = lockerOptions[i]
        options[#options+1] = {
            title = opt.title,
            icon = "fa-solid fa-shirt",
            disabled = not Bridge.hasGroup(opt.groups),
            onSelect = function()
                local ped = cache.ped
                local model = GetEntityModel(ped)
                if model ~= `mp_m_freemode_01` and model ~= `mp_f_freemode_01` then
                    return Bridge.notify({
                        title = "Unable to set otufit",
                        description = "Your player model is not supported.",
                        type = "error",
                        duration = 5000
                    })
                end

                local clothing = opt.clothing[model == `mp_m_freemode_01` and "male" or "female"]
                if not clothing then
                    return Bridge.notify({
                        title = "Unable to set otufit",
                        description = "Your player model is not supported.",
                        type = "error",
                        duration = 5000
                    })
                end

                setClothing(ped, clothing)
            end
        }
    end

    return options
end

for locker, info in pairs(data_lockers) do
    for i=1, #info.locations do
        local location = info.locations[i]

        local point = lib.points.new({
            coords = location,
            distance = 10
        })

        function point:onEnter()
            self.canEnter = Bridge.hasGroup(info.groups)
        end
         
        function point:nearby()
            if not self.canEnter then return end

            DrawMarker(
                1, -- type
                location.x, location.y, location.z-1.0, -- position
                0.0, 0.0, 0.0, -- direction
                0.0, 0.0, 0.0, -- rotation
                1.5, 1.5, 0.4, -- scale
                0, 70, 255, 150, -- rgba
                false, false, 2, false, nil, nil, false -- bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts
            )

            if self.currentDistance < 1 and IsControlJustReleased(0, 51) then
                local id = ("ND_Police:locker_rooms_%s"):format(locker)
                lib.registerContext({
                    id = id,
                    title = info.title,
                    options = getLockerOptions(info.options, id)
                })
                lib.showContext(id)
            end
        end
    end
end
