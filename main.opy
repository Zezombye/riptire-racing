#!include "settings.opy"

#!obfuscate

globalvar positions
globalvar spawnPositions
globalvar gameStatus
globalvar timeRemaining
globalvar winner
globalvar currentRound = 3
globalvar hasOnePlayerFinished = false
globalvar displayFinalScores = false
globalvar countdown
globalvar hasCountdownBeenEngaged

globalvar countdownHuds = [
#1
" 
  ▒
 ▒▒
  ▒
  ▒
 ▒▒▒ 
",
#2
" 
 ▒▒▒ 
   ▒
 ▒▒▒
 ▒
 ▒▒▒
",
#3
" 
 ▒▒▒ 
   ▒
  ▒▒
   ▒
 ▒▒▒
",
]

playervar currentCheckpoint
playervar hasLaunchedTire
playervar hasFinished
playervar score

subroutine displayCredits

#!define GAME_NOT_STARTED 0
#!define GAME_IN_SETUP 1
#!define GAME_STARTED 2
#!define GAME_FINISHED 3

#!define BUILD_MODE true
#!define DEBUG_MODE false
#!define generateRaycastChecks(positions) __script__("generateRaycastChecks.js")

#!define participatingPlayers() ([p for p in getAllPlayers() if p.currentCheckpoint > 0])

#!define sortedPlayersByScore() (sorted(participatingPlayers(), lambda x: -x.score))
#!define playerInSpot(nb) (sorted(participatingPlayers(), lambda x: -x.currentCheckpoint)[nb])
#!define playersInSpot(min, max) (sorted(participatingPlayers(), lambda x: -x.currentCheckpoint).slice((min), (max)-(min)))

#!define spotHud(func, nb) \
_spotHud(func, getAllPlayers().exclude(playerInSpot(nb)) if (nb) <= 2 else playerInSpot((nb)+1), nb, Color.ORANGE)\
_spotHud(func, playerInSpot(nb), nb, Color.PURPLE)
#!define _spotHud(func, visibility, nb, color) func((visibility) if gameStatus == GAME_STARTED else [], "#{} | {}".format(nb+1, playerInSpot(nb)), HudPosition.TOP, (nb)-100, color, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

#!define finishHud(nb) \
_finishHud(getAllPlayers().exclude(sortedPlayersByScore()[nb]) if displayFinalScores else getAllPlayers().exclude(playerInSpot(nb)), nb, Color.ORANGE)\
_finishHud(sortedPlayersByScore()[nb] if displayFinalScores else playerInSpot(nb), nb, Color.PURPLE)
#!define _finishHud(visibility, nb, color) hudSubtext((visibility) if gameStatus == GAME_FINISHED and len(participatingPlayers()) > (nb) else [], "{}: {}".format(sortedPlayersByScore()[nb], floor(sortedPlayersByScore()[nb].score)) if displayFinalScores else "{}: #{}".format(playerInSpot(nb), (nb)+1), HudPosition.TOP, -100-sortedPlayersByScore()[nb].score if displayFinalScores else (nb)-500, color, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

#!include "build.opy"
#!include "debug.opy"
#!include "winhud.opy"

#!include "maps/horizon.opy"
#!include "maps/kings_row.opy"

def displayCredits():
    hudSubtext(getAllPlayers(), "By Zezombye#9938 on Discord", HudPosition.LEFT, 0, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

rule "init global":
    displayCredits()
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getPlayerHit())
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getHitPosition())
    hudHeader(hostPlayer if gameStatus == GAME_NOT_STARTED and not BUILD_MODE else [], "Press F to start the game", HudPosition.TOP, 1, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

    #hide objective description
    hudSubtext(getAllPlayers() if gameStatus != GAME_NOT_STARTED else [], " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

    spotHud(hudHeader, 0)
    spotHud(hudSubtext, 1)
    spotHud(hudSubtext, 2)
    spotHud(hudSubheader, 3)
    spotHud(hudSubheader, 4)
    spotHud(hudSubheader, 5)
    spotHud(hudSubheader, 6)
    spotHud(hudSubheader, 7)
    spotHud(hudSubheader, 8)
    spotHud(hudSubheader, 9)
    spotHud(hudSubheader, 10)
    spotHud(hudSubheader, 11)
    
    #countdown hud
    hudSubtext(getAllPlayers() if countdown > 0 else [], " \n\n\n\n\n\n", HudPosition.TOP, -20, Color.RED, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudHeader(getAllPlayers() if countdown > 0 else [], countdownHuds[floor(countdown)], HudPosition.TOP, -10, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

rule "init huds for game end":
    
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n\n\n\n\n\n\n", HudPosition.TOP, -750, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudHeader(getAllPlayers() if gameStatus == GAME_FINISHED else [], "Final Rankings" if displayFinalScores else "Place for this round", HudPosition.TOP, -740, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n", HudPosition.TOP, -730, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    finishHud(0)
    finishHud(1)
    finishHud(2)
    finishHud(3)
    finishHud(4)
    finishHud(5)
    finishHud(6)
    finishHud(7)
    finishHud(8)
    finishHud(9)
    finishHud(10)
    finishHud(11)

    #black background for finish huds
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n\n\n\n\n\n", HudPosition.RIGHT, -75, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudText(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n                                           \n\n\n\n\n\n\n\n\n\n\n\n\n", "                          ", null, HudPosition.RIGHT, -50, Color.LIME_GREEN, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)

    #remaining time hud
    hudSubtext(getAllPlayers() if timeRemaining > 0 and gameStatus == GAME_STARTED else [], " \n\nGame ends in {} second{}".format(ceil(timeRemaining), "" if timeRemaining <= 1 else "s"), HudPosition.TOP, -10, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)


rule "init player":
    @Event eachPlayer

    #create beam+icon for current target checkpoint
    createBeam(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], Beam.GOOD, positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], Color.GREEN, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], (positions[eventPlayer.currentCheckpoint*2]+positions[eventPlayer.currentCheckpoint*2+1])/2-vect(0,0.3,0), Icon.RADIOACTIVE, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN, true)

    #create beam for next checkpoint
    createBeam(eventPlayer if gameStatus != GAME_NOT_STARTED and not eventPlayer.hasFinished else [], Beam.GOOD, positions[(eventPlayer.currentCheckpoint+1)*2], positions[(eventPlayer.currentCheckpoint+1)*2+1], Color.PURPLE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    eventPlayer.setRespawnTime(999999)

    if not BUILD_MODE:
        eventPlayer.setPrimaryFireEnabled(false)
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.setAbility1Enabled(false)
        eventPlayer.setAbility2Enabled(false)
        eventPlayer.setUltEnabled(false)

rule "host player starts the game":
    @Condition hostPlayer.isHoldingButton(Button.INTERACT)
    @Condition not BUILD_MODE
    gameStatus = GAME_IN_SETUP

rule "init player - setup":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.hasLaunchedTire = false
    eventPlayer.hasFinished = false
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.teleport(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)))
    eventPlayer.startForcingPosition(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)), false)
    eventPlayer.resurrect()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (positions[0]+positions[1])/2), Relativity.TO_WORLD)
    
    eventPlayer.currentCheckpoint = 0
    chase(eventPlayer.currentCheckpoint, 9999, rate=0.0001, ChaseReeval.NONE)
    eventPlayer.setUltCharge(0)
    eventPlayer.setUltEnabled(true)
    eventPlayer.disallowButton(Button.ULTIMATE)
    wait(0.25)
    eventPlayer.stopForcingPosition()

rule "freeze":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    eventPlayer.setStatusEffect(null, Status.FROZEN, 0.7)

rule "setup":
    @Condition gameStatus == GAME_IN_SETUP
    bigMessage(getAllPlayers(), "Round {}/3".format(currentRound+1))
    stopChasingVariable(timeRemaining)
    hasOnePlayerFinished = false
    displayFinalScores = false
    for I in range(0, 101, 0.6):
        getAllPlayers().setUltCharge(I)
        wait()
    wait(0.5)
    countdown = 2.99
    chase(countdown, -1, rate=1, ChaseReeval.NONE)
    hasCountdownBeenEngaged = true

rule "countdown is 3":
    @Condition countdown > 2.5
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, (spawnPositions[0]+spawnPositions[1])/2, 200)
rule "countdown is 2":
    @Condition countdown > 1.5 and countdown <= 2
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, (spawnPositions[0]+spawnPositions[1])/2, 200)
rule "countdown is 1":
    @Condition countdown > 0.5 and countdown <= 1
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, (spawnPositions[0]+spawnPositions[1])/2, 200)

rule "countdown is 0 - start game":
    @Condition hasCountdownBeenEngaged
    @Condition countdown <= 0
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, (spawnPositions[0]+spawnPositions[1])/2, 200)
    getAllPlayers().allowButton(Button.ULTIMATE)
    gameStatus = GAME_STARTED
    wait(1)
    stopChasingVariable(countdown)

rule "quick start":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate()
    @Condition countdown < 0 and countdown >= -0.15
    bigMessage(eventPlayer, "Turbo Boost!")
    eventPlayer.setMoveSpeed(150)
    wait(3.5)
    eventPlayer.setMoveSpeed(100)

rule "set ult charge when game started":
    @Event eachPlayer
    @Condition gameStatus == GAME_STARTED
    @Condition not eventPlayer.hasFinished and not eventPlayer.isUsingUltimate()
    @Condition eventPlayer.getUltCharge() < 100
    do:
        eventPlayer.setUltCharge(100)
        wait()
    while RULE_CONDITION

rule "kill players joining mid-game":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    if gameStatus != GAME_NOT_STARTED:
        kill(eventPlayer, null)
        bigMessage(eventPlayer, "You will respawn next round")

rule "raycast check for next checkpoint":
    @Event eachPlayer
    @Condition distance(positions[eventPlayer.currentCheckpoint*2+1], raycast(positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], eventPlayer, [], true).getHitPosition()) > 0.1
    eventPlayer.currentCheckpoint = round(eventPlayer.currentCheckpoint+1)
    playEffect(eventPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 99999)
    smallMessage(eventPlayer, "{}/{}".format(floor(eventPlayer.currentCheckpoint), len(positions)/2))

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

rule "player has finished":
    @Event eachPlayer
    @Condition eventPlayer.hasFinished
    eventPlayer.forceButtonPress(ButtonLiteral.PRIMARY_FIRE)
    eventPlayer.setUltCharge(0)
    eventPlayer.clearStatusEffect(Status.ROOTED)

    if not hasOnePlayerFinished:
        bigMessage(getAllPlayers(), "{} wins this round!".format(eventPlayer))
        hasOnePlayerFinished = true
        timeRemaining = 5
        chase(timeRemaining, 0, rate=1, ChaseReeval.NONE)

        /*if eventPlayer.couldNameBeGuessed:
            displayWinHuds = true
        else:
            bigMessage(getAllPlayers(), "{} wins!".format(eventPlayer))*/

rule "set game to finished":
    @Condition hasOnePlayerFinished
    @Condition timeRemaining <= 0
    getAllPlayers().hasFinished = true
    stopChasingVariable(getAllPlayers().currentCheckpoint)
    wait(1)
    gameStatus = GAME_FINISHED
    wait(5)
    displayFinalScores = true
    wait(7)
    if currentRound < 2:
        gameStatus = GAME_IN_SETUP
        currentRound++
    else:
        winner = sortedPlayersByScore()[0]
        if winner.couldNameBeGuessed:
            displayWinHuds = true
        else:
            bigMessage(getAllPlayers(), "{} wins!".format(winner))
        setSlowMotion(33)
        wait(3)
        setMatchTime(0)


rule "increase player scores":
    @Event eachPlayer
    @Condition displayFinalScores
    wait(1)
    #floor((L-X)/(L-1) * 100)
    chase(eventPlayer.score, eventPlayer.score + floor(
        (len([p for p in getAllPlayers() if p.currentCheckpoint > 0])-(1+sorted([p for p in getAllPlayers() if p.currentCheckpoint > 0], lambda x: -x.currentCheckpoint).index(eventPlayer)))
        / (len([p for p in getAllPlayers() if p.currentCheckpoint > 0])-1)*100
    ), duration=1.5, ChaseReeval.NONE)

