#!mainFile "main.opy"

settings {
    "main": {
        "description": "Zez's Rip-Tire Racing | BETA version but still playable :) | workshop.codes/GGFYC"
    },
    "lobby": {
        "mapRotation": "afterGame",
        "returnToLobby": "never",
        "team1Slots": 6,
        "team2Slots": 6,
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "horizonLunarColony",
                "kingsRowWinter",
            ]
        },
        "general": {
            "heroLimit": "off",
            "roleLimit": "off",
            "enableRandomHeroes": false,
            "respawnTime%": 30,
            "gamemodeStartTrigger": "immediately",
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
