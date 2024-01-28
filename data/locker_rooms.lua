local options = lib.load("data.clothing")
local menus = {}


menus["lspd"] = {
    title = "Locker room",
    groups = {"lspd"},
    locations = {
        vec3(458.14, -990.82, 30.69)
    },
    options = {
        {
            title = "Patrol",
            groups = {"lspd"},
            clothing = options.lspd_patrol
        },
        {
            title = "SWAT",
            groups = {"swat"},
            clothing = options.lspd_swat
        },
        {
            title = "K9",
            groups = {"canine"},
            clothing = options.lspd_canine
        },
    }
}




return menus
