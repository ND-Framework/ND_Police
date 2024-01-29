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
            title = "Patrol uniform",
            groups = {"lspd"},
            clothing = options.lspd_patrol
        },
        {
            title = "SWAT uniform",
            groups = {"swat"},
            clothing = options.lspd_swat
        },
        {
            title = "K9 uniform",
            groups = {"canine"},
            clothing = options.lspd_canine
        },
        {
            title = "Pilot uniform",
            groups = {"police_pilot"},
            clothing = options.lspd_pilot
        }
    }
}




return menus
