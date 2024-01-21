return {
    ["spikestrip"] = {
        label = "Spikestrip",
        weight = 500,
        client = {
            export = "ND_Police.deploySpikestrip"
        }
    },
    ["cuffs"] = {
        labal = "Handcuffs",
        weight = 150,
        client = {
            export = "ND_Police.cuff"
        }
    },
    ["zipties"] = {
        labal = "Zipties",
        weight = 10,
        client = {
            export = "ND_Police.ziptie"
        }
    },
    ["tools"] = {
		label = "Tools",
        description = "Can be used to hotwire vehicles.",
		weight = 800,
		consume = 1,
        stack = true,
        close = true,
		client = {
            export = "ND_Core.hotwire",
            event = "ND_Police:unziptie"
		}
	},
    ["handcuffkey"] = {
        label = "Handcuff key",
        weight = 10,
        client = {
            export = "ND_Police.uncuff"
        }
    },
    ["casing"] = {
        label = "Bullet Casing"
    },
    ["projectile"] = {
        label = "Projectile"
    },
}