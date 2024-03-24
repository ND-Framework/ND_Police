local shotspotter = {}

shotspotter.debug = false -- if you set it to true you will see the shotspotters on map.
shotspotter.delay = 1 -- delay in seconds for shotspotter to report a shooting.
shotspotter.cooldown = 120 -- seconds cooldown until player can trigger it again.
shotspotter.radius = 550 -- how far the shotspotter will detect shots.

shotspotter.ignoredJobs = {"sahp", "lspd", "bcso", "lsfd"}

shotspotter.locations = {
    vec3(653.42, -648.74, 57.18),
    vec3(1015.98, -255.25, 85.58),
    vec3(329.99, 288.96, 120.10),
    vec3(-202.76, -327.34, 66.04),
    vec3(31.32, -875.29, 31.46),
    vec3(70.1372, -1718.3291, 34.2056),
    vec3(1196.9178, -1624.6641, 50.3403),
    vec3(-852.9095, -1215.8782, 9.2463),
    vec3(-932.7648, -448.8844, 42.9436),
    vec3(-1713.6848, 478.4267, 130.3795),
    vec3(-596.5602, 515.0753, 109.675),
    vec3(716.6274, -1958.7434, 44.7564),
    vec3(-1889.92, -351.62, 49.31),
    vec3(-978.85, -2089.64, 10.19),
    vec3(-1169.81, -2763.41, 13.95),
    vec3(-96.09, 6377.95, 31.48),
    vec3(1415.54, 2695.04, 37.42),
    vec3(-3069.58, 735.29, 21.70),
    vec3(-2729.48, 3.24, 15.51),
    vec3(74.06, -2644.79, 21.90),
    vec3(984.14, -3117.20, 5.90),
    vec3(236.19, 1240.05, 229.83),
    vec3(1806.03, 3705.84, 33.96),
    vec3(1702.34, 4881.44, 42.03),
    vec3(2868.15, 3567.91, 53.38),
    vec3(2566.92, 383.00, 108.46),
    vec3(1358.59, -942.04, 69.29),
    vec3(-1591.69, -1140.81, 2.15),
    vec3(-2380.90, 2136.90, 88.54),
    vec3(375.02, 2778.28, 55.97)
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
