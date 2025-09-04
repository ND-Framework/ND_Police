local options = lib.load("data.clothing")
local menus = {}


menus["lspd"] = {
    title = "Locker room",
    groups = {"lspd", "police"},
    locations = {
        vec3(458.14, -990.82, 30.69)
    },
    options = {
        {
            title = "Patrol uniform (long sleeve)",
            groups = {"lspd", "police"},
            clothing = options.lspd_patrol
        },
        {
            title = "Patrol uniform (short sleeve)",
            groups = {"lspd", "police"},
            clothing = options.lspd_patrol2
        },
        {
            title = "Patrol uniform (vest) (long sleeve)",
            groups = {"lspd", "police"},
            clothing = options.lspd_patrol3
        },
        {
            title = "Patrol uniform (vest) (short sleeve)",
            groups = {"lspd", "police"},
            clothing = options.lspd_patrol4
        },
        {
            title = "K9 uniform",
            groups = {"canine"},
            clothing = options.lspd_canine
        },
        {
            title = "SWAT (black)",
            groups = {"swat"},
            clothing = options.lspd_swat
        },
        {
            title = "SWAT (tan)",
            groups = {"swat"},
            clothing = options.lspd_swat2
        },
        {
            title = "SWAT Pilot",
            groups = {"swat"},
            clothing = options.lspd_swat3
        },
    }
}




return menus
