settings {
    "main": {
        "description": "Zez's Rip-Tire Racing | BETA do not copy!"
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "horizonLunarColony"
            ]
        },
        "general": {
            "heroLimit": "off",
            "roleLimit": "off"
        }
    },
    "heroes": {
        "allTeams": {
            "junkrat": {
                "enableInfiniteUlt": true,
                "enableSpawningWithUlt": true
            }
        }
    }
}

##!obfuscate

globalvar positions

playervar currentCheckpoint

subroutine displayCredits

#!define BUILD_MODE false
#!define generateRaycastChecks(positions) __script__("generateRaycastChecks.js")

#!include "build.opy"

def displayCredits():
    hudSubtext(getAllPlayers(), "By Zezombye#9938 on Discord", HudPosition.LEFT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

rule "init global":
    positions = [
        vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), 
        vect(-40.437, 5.714, -121.371), vect(-38.189, 5.771, -117.084),
        vect(-41.498, 8.001, -102.709), vect(-41.504, 10, -102.716),
        vect(-30.602, 5.874, -93.975), vect(-32.839, 5.798, -98.267),
        vect(-8.908, 7.235, -91.696), vect(-11.528, 7.308, -87.894),
        vect(23.01, 11.911, -91.539), vect(22.794, 12.006, -87.487),
        vect(86.884, 15.167, -68.733), vect(87.101, 15.158, -74.568),
        vect(77.597, 8.147, -39.429), vect(80.737, 8.115, -44.256),
        vect(48.662, 13, -33.235), vect(44.474, 13, -35.966),
        vect(35.282, 13, -19.81), vect(31.227, 13, -22.453),
        vect(15.791, 10.415, -8.202), vect(13.345, 10.291, -12.926)
    ]
    displayCredits()
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getPlayerHit())
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getHitPosition())


rule "init player":
    @Event eachPlayer
    
    eventPlayer.currentCheckpoint = 0
    createBeam(eventPlayer, Beam.GOOD, positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], Color.GREEN, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(eventPlayer, (positions[eventPlayer.currentCheckpoint*2]+positions[eventPlayer.currentCheckpoint*2+1])/2-vect(0,0.3,0), Icon.RADIOACTIVE, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN, true)
    print("{} is at checkpoint {}".format(eventPlayer, eventPlayer.currentCheckpoint))


rule "raycast check for next checkpoint":
    @Event eachPlayer
    @Condition distance(positions[eventPlayer.currentCheckpoint*2+1], raycast(positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], eventPlayer, [], true).getHitPosition()) > 0.1
    eventPlayer.currentCheckpoint++




rule "player wins":
    @Event eachPlayer
    @Condition eventPlayer.currentCheckpoint >= len(positions)/2
    bigMessage(getAllPlayers(), "{} wins!".format(eventPlayer))
    eventPlayer.forceButtonPress(ButtonLiteral.PRIMARY_FIRE)