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
            "roleLimit": "off",
            "enableRandomHeroes": true,
            "respawnTime%": 30
        }
    },
    "heroes": {
        "allTeams": {
            "junkrat": {
                "enableInfiniteUlt": true,
                #"enableSpawningWithUlt": true,
                "damageDealt%": 10,
                "damageReceived%": 10,
                "passiveUltGen%": 500,
                "ultGen%": 500,
                "enableUlt": false,
            },
            "enabledHeroes": [
                "junkrat"
            ]
        }
    }
}

#!obfuscate

globalvar positions
globalvar spawnPositions
globalvar gameStatus

playervar currentCheckpoint

subroutine displayCredits

#!define GAME_NOT_STARTED 0
#!define GAME_IN_SETUP 1
#!define GAME_STARTED 2

#!define BUILD_MODE false
#!define generateRaycastChecks(positions) __script__("generateRaycastChecks.js")

#!define playerInSpot(nb) (sorted([p for p in getAllPlayers() if p.currentCheckpoint > 0], lambda x: -x.currentCheckpoint))
#!define spotHudHeader(nb) hudHeader(getAllPlayers(), playerInSpot(nb), HudPosition.TOP, nb-100, Color.GREEN, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
#!define spotHudSubtext(nb) hudSubtext(getAllPlayers(), playerInSpot(nb), HudPosition.TOP, nb-100, Color.LIME_GREEN, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

#!include "build.opy"

def displayCredits():
    hudSubtext(getAllPlayers(), "By Zezombye#9938 on Discord", HudPosition.LEFT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

rule "init global":
    positions = [
        vect(-17.518, 5.598, -149.622), vect(-20.109, 5.598, -148.449), 
        vect(-38.189, 6.296, -117.085), vect(-40.425, 6.304, -121.377), 
        vect(-41.700, 8.001, -102.607), vect(-41.741, 10, -102.626), 
        vect(-30.603, 5.098,-93.974), vect(-32.902, 5.100, -98.234),
        vect(-8.924, 6.602,-91.725), vect(-11.391, 6.596, -87.810), 
        vect(22.769, 12.254, -87.584), vect(22.996, 12.248, -91.409),
        vect(86.829,14.496, -69.005), vect(87.139, 14.503, -74.395), 
        vect(77.712, 7.448, -39.723), vect(80.589, 7.454, -44.050), 
        vect(48.646, 12.620, -33.210), vect(44.456, 12.613, -35.939), 
        vect(35.302, 14.295, -19.841), vect(31.374, 14.300, -22.441),
        vect(15.763, 9.605, -8.187), vect(13.325, 9.600, -12.916),
    ]
    spawnPositions = [
        vect(-23.30, 5, -161.14),
        vect(-27.88, 5, -158.75),
    ]
    displayCredits()
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getPlayerHit())
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getHitPosition())
    hudHeader(hostPlayer if gameStatus == GAME_NOT_STARTED and not BUILD_MODE else [], "Press F to start the game", HudPosition.TOP, 1, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers() if gameStatus == GAME_STARTED else [], "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

    #debug
    /*for I in range(6):
        createDummy(Hero.JUNKRAT, Team.1, -1, positions[0], vect(0,0,0))
        createDummy(Hero.JUNKRAT, Team.2, -1, positions[0], vect(0,0,0))*/

rule "host player starts the game":
    @Condition hostPlayer.isHoldingButton(Button.INTERACT)
    @Condition not BUILD_MODE
    gameStatus = GAME_IN_SETUP

rule "init player":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.teleport(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)))
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (positions[0]+positions[1])/2), Relativity.TO_WORLD)
    
    eventPlayer.currentCheckpoint = 0
    eventPlayer.setUltCharge(0)
    eventPlayer.setUltEnabled(true)
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

