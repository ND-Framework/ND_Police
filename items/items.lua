return {
    ["shield"] = {
        label = "Police shield",
        weight = 8000,
        stack = false,
        consume = 0,
        client = {
            export = "ND_Police.useShield",
            add = function(total)
                if total > 0 then
                        pcall(function() return exports["ND_Police"]:hasShield(true) end)
                    end
                end,
            remove = function(total)
                if total < 1 then
                    pcall(function() return exports["ND_Police"]:hasShield(false) end)
                end
            end
        }
    },
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