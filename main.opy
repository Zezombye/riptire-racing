#!include "settings.opy"

##!obfuscate

globalvar positions
globalvar spawnPositions
globalvar gameStatus
#globalvar winner

playervar currentCheckpoint
playervar hasLaunchedTire
playervar hasFinished

subroutine displayCredits

#!define GAME_NOT_STARTED 0
#!define GAME_IN_SETUP 1
#!define GAME_STARTED 2

#!define BUILD_MODE false
#!define generateRaycastChecks(positions) __script__("generateRaycastChecks.js")

#!define playerInSpot(nb) (sorted([p for p in getAllPlayers() if p.currentCheckpoint > 0], lambda x: -x.currentCheckpoint)[nb])
#!define spotHudHeader(nb) hudHeader(getAllPlayers() if gameStatus == GAME_STARTED and playerInSpot(nb) != null else [], "#{} | {}".format(nb+1, playerInSpot(nb)), HudPosition.TOP, nb-100, Color.PURPLE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
#!define spotHudSubheader(nb) hudSubheader(getAllPlayers() if gameStatus ==  GAME_STARTED and playerInSpot(nb) != null else [], "#{} | {}".format(nb+1, playerInSpot(nb)), HudPosition.TOP, nb-100, Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

#!include "build.opy"
##!include "winhud.opy"

#!include "maps/horizon.opy"
#!include "maps/kings_row.opy"

def displayCredits():
    hudSubtext(getAllPlayers(), "By Zezombye#9938 on Discord", HudPosition.LEFT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)


rule "init global":
    displayCredits()
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getPlayerHit())
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getHitPosition())
    hudHeader(hostPlayer if gameStatus == GAME_NOT_STARTED and not BUILD_MODE else [], "Press F to start the game", HudPosition.TOP, 1, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers() if gameStatus != GAME_NOT_STARTED else [], " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

    spotHudHeader(0)
    spotHudSubheader(1)
    spotHudSubheader(2)
    spotHudSubheader(3)
    spotHudSubheader(4)
    spotHudSubheader(5)
    spotHudSubheader(6)
    spotHudSubheader(7)
    spotHudSubheader(8)
    spotHudSubheader(9)
    spotHudSubheader(10)
    spotHudSubheader(11)
    spotHudSubheader(12)

    #print(winner == null)
    #print(winner != null)

    #debug
    for I in range(6):
        createDummy(Hero.JUNKRAT, Team.1, -1, positions[0], vect(0,0,0))
        createDummy(Hero.JUNKRAT, Team.2, -1, positions[0], vect(0,0,0))

rule "init player":
    @Event eachPlayer
    chase(eventPlayer.currentCheckpoint, 9999, rate=0.0001, ChaseReeval.NONE)

    #create beam+icon for current target checkpoint
    createBeam(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], Beam.GOOD, positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], Color.GREEN, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], (positions[eventPlayer.currentCheckpoint*2]+positions[eventPlayer.currentCheckpoint*2+1])/2-vect(0,0.3,0), Icon.RADIOACTIVE, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN, true)

    #create beam for next checkpoint
    createBeam(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], Beam.GOOD, positions[(eventPlayer.currentCheckpoint+1)*2], positions[(eventPlayer.currentCheckpoint+1)*2+1], Color.PURPLE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "host player starts the game":
    @Condition hostPlayer.isHoldingButton(Button.INTERACT)
    @Condition not BUILD_MODE
    gameStatus = GAME_IN_SETUP

rule "init player":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.hasLaunchedTire = false
    eventPlayer.hasFinished = false
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.teleport(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)))
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (positions[0]+positions[1])/2), Relativity.TO_WORLD)
    
    eventPlayer.currentCheckpoint = 0
    eventPlayer.setUltCharge(0)
    eventPlayer.setUltEnabled(true)
    #print("{} is using ultimate: {}".format(eventPlayer, eventPlayer.isUsingUltimate()))

rule "freeze":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition eventPlayer.getUltCharge() < 100
    eventPlayer.setStatusEffect(null, Status.FROZEN, 0.7)

rule "setup":
    @Condition gameStatus == GAME_IN_SETUP
    for I in range(0, 101, 0.40):
        getAllPlayers().setUltCharge(I)
        wait()
    gameStatus = GAME_STARTED

rule "set ult charge when game started":
    @Event eachPlayer
    @Condition gameStatus == GAME_STARTED
    @Condition not eventPlayer.hasFinished and not eventPlayer.isUsingUltimate()
    @Condition eventPlayer.getUltCharge() < 100
    eventPlayer.setUltCharge(100)


rule "raycast check for next checkpoint":
    @Event eachPlayer
    @Condition distance(positions[eventPlayer.currentCheckpoint*2+1], raycast(positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], eventPlayer, [], true).getHitPosition()) > 0.1
    eventPlayer.currentCheckpoint = round(eventPlayer.currentCheckpoint+1)

rule "player launched tire":
    @Event eachPlayer
    @Condition gameStatus == GAME_STARTED
    @Condition eventPlayer.isUsingUltimate()
    eventPlayer.hasLaunchedTire = true
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

rule "player tire died early":
    @Event eachPlayer
    @Condition gameStatus == GAME_STARTED
    @Condition eventPlayer.hasLaunchedTire
    @Condition not eventPlayer.isUsingUltimate()
    @Condition eventPlayer.currentCheckpoint >= 1

    #Teleport to latest checkpoint
    eventPlayer.teleport(raycast((positions[(eventPlayer.currentCheckpoint-1)*2]+positions[(eventPlayer.currentCheckpoint-1)*2+1])/2, (positions[(eventPlayer.currentCheckpoint-1)*2]+positions[(eventPlayer.currentCheckpoint-1)*2+1])/2 - vect(0,1000,0), null, null, false).getHitPosition())

    if not eventPlayer.hasFinished:
        wait(0.5)
        eventPlayer.startFacing(directionTowards((positions[(eventPlayer.currentCheckpoint-1)*2]+positions[(eventPlayer.currentCheckpoint-1)*2+1])/2, (positions[(eventPlayer.currentCheckpoint)*2]+positions[(eventPlayer.currentCheckpoint)*2+1])/2), 99999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

rule "stop facing":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate()
    eventPlayer.stopFacing()

rule "player finishes":
    @Event eachPlayer
    @Condition eventPlayer.currentCheckpoint >= len(positions)/2
    #bigMessage(getAllPlayers(), "{} wins!".format(eventPlayer))
    eventPlayer.hasFinished = true
    eventPlayer.forceButtonPress(ButtonLiteral.PRIMARY_FIRE)
    eventPlayer.setUltCharge(0)
    eventPlayer.clearStatusEffect(Status.ROOTED)

    /*if winner == null:
        winner = eventPlayer

        if eventPlayer.couldNameBeGuessed:
            displayWinHuds = true
        else:
            bigMessage(getAllPlayers(), "{} wins!".format(eventPlayer))*/
