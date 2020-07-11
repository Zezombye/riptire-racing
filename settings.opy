#!mainFile "main.opy"

settings {
    "main": {
        "description": "Zez's Rip-Tire Racing | BETA do not copy!"
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                #"horizonLunarColony",
                "kingsRowWinter",
            ]
        },
        "general": {
            "heroLimit": "off",
            "roleLimit": "off",
            "enableRandomHeroes": true,
            "respawnTime%": 30
        }
    },
    "heroes": {
        "allTeams": {
            "junkrat": {
                "enableAbility1": true,
                "ability1Cooldown%": 0,
                "damageDealt%": 10,
                "damageReceived%": 10,
                "enableInfiniteUlt": true,
                "enablePrimaryFire": false,
                "enableMelee": false,
                "enableAbility2": false,
                "enableUlt": true,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "ultGen%": 10,
            },
            "enabledHeroes": [
                "junkrat"
            ]
        }
    }
}
