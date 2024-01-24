local shotspotter = {}

shotspotter.debug = false -- if you set it to true you will see the shotspotters on map.
shotspotter.delay = 10 -- delay for shotspotter to report a shooting.
shotspotter.cooldown = 120 -- seconds cooldown until player can trigger it again.
shotspotter.radius = 450 -- how far the shotspotter will detect shots.

shotspotter.ignoredJobs = {"sahp", "lspd", "bcso", "lsfd"}

shotspotter.locations = {
    vec3(653.4214, -648.7440, 57.1897),
    vec3(1015.9837, -255.2573, 85.5857),
    vec3(329.9973, 288.9604, 120.1029),
    vec3(-202.7689, -327.3490, 66.0497),
    vec3(31.3205, -875.2959, 31.4629),
    vec3(70.1372, -1718.3291, 34.2056),
    vec3(1196.9178, -1624.6641, 50.3403),
    vec3(-852.9095, -1215.8782, 9.2463),
    vec3(-932.7648, -448.8844, 42.9436),
    vec3(-1713.6848, 478.4267, 130.3795),
    vec3(-596.5602, 515.0753, 109.675),
    vec3(716.6274, -1958.7434, 44.7564)
}

-- weapons that won't trigger the shotspotter
shotspotter.ignoredWeapons = {
    `weapon_flaregun`,
    `weapon_stungun_mp`,
    `weapon_grenade`,
    `weapon_bzgas`,
    `weapon_molotov`,
    `weapon_stickybomb`,
    `weapon_proxmine`,
    `weapon_snowball`,
    `weapon_pipebomb`,
    `weapon_ball`,
    `weapon_smokegrenade`,
    `weapon_flare`,
    `weapon_petrolcan`,
    `weapon_fireextinguisher`,
    `weapon_hazardcan`,
    `weapon_fertilizercan`
}

shotspotter.suppresors = {
    `COMPONENT_AT_PI_SUPP_02`, -- Pistol, Pistol Mk2, SNS Pistol Mk2.
    `COMPONENT_AT_PI_SUPP`, -- Combat Pistol, AP Pistol, Heavy Pistol, Vintage Pistol, SMG, SMG Mk2, Machine Pistol.
    `COMPONENT_AT_AR_SUPP_02`, -- .50 Pistol, Micro SMG, Assault SMG, Bullpup Shotgun, Heavy Shotgun, Assault Rifle, Special Carbine, Special Carbine Mk2, Assault Rifle Mk2, Sniper Rifle.
    `COMPONENT_AT_AR_SUPP`, -- Assault Shotgun, Combat Shotgun, Carbine Rifle, Advanced Rifle, Bullpup Rifle, Bullpup Rifle Mk2, Carbine Rifle Mk2, Military Rifle, Marksman Rifle Mk2, Marksman Rifle.
    `COMPONENT_AT_SR_SUPP` -- Pump Shotgun.
}


return shotspotter
