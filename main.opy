#!include "settings.opy"

##!obfuscate noRuleFilling noStringObfuscation noNameObfuscation

globalvar positions
globalvar spawnPositions
globalvar gameStatus
globalvar timeRemaining
globalvar winner
globalvar currentRound
globalvar hasOnePlayerFinished = false
globalvar displayFinalScores = false
globalvar countdown
globalvar hasCountdownBeenEngaged

globalvar winPosition
globalvar winFacing

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
playervar isPlayer = true #detect specs

subroutine displayCredits

#!define GAME_NOT_STARTED 0
#!define GAME_IN_SETUP 1
#!define GAME_STARTED 2
#!define GAME_FINISHED 3

#!define BUILD_MODE false
#!define DEBUG_MODE false
#!define generateRaycastChecks(positions) __script__("generateRaycastChecks.js")

globalvar NB_ROUNDS = createWorkshopSetting(int<1:10>, "", "Number of rounds", 10, 1)
#The time remaining has a 2.5 delay.
globalvar TIME_REMAINING_ON_FINISH = createWorkshopSetting(float<2.5:1000>, "", "Time remaining when first player finishes", 15, 2)

#!define participatingPlayers() ([p for p in getAllPlayers() if p.currentCheckpoint > 0])

#!define sortedPlayersByScore() (sorted(participatingPlayers(), lambda x: -x.score))
#!define playerInSpot(nb) (sorted(participatingPlayers(), lambda x: -x.currentCheckpoint)[nb])
#!define playersInSpot(min, max) (sorted(participatingPlayers(), lambda x: -x.currentCheckpoint).slice((min), (max)-(min)))

#!define spotHud(func, nb) \
_spotHud(func, getAllPlayers().exclude(playerInSpot(nb)) if (nb) <= 2 else playerInSpot((nb)+1), nb, Color.ORANGE)\
_spotHud(func, playerInSpot(nb), nb, Color.PURPLE)
#!define _spotHud(func, visibility, nb, color) func((visibility) if gameStatus == GAME_STARTED else [], "#{} | {}".format(nb+1, playerInSpot(nb)), HudPosition.TOP, (nb)-100, color, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)

#!define finishHud(nb) \
_finishHud(getAllPlayers().exclude(sortedPlayersByScore()[nb]) if displayFinalScores else getAllPlayers().exclude(playerInSpot(nb)), nb, Color.ORANGE)\
_finishHud(sortedPlayersByScore()[nb] if displayFinalScores else playerInSpot(nb), nb, Color.PURPLE)
#!define _finishHud(visibility, nb, color) hudSubtext((visibility) if gameStatus == GAME_FINISHED and len(participatingPlayers()) > (nb) else [], "{}: {}".format(sortedPlayersByScore()[nb], floor(sortedPlayersByScore()[nb].score)) if displayFinalScores else "{}: #{}".format(playerInSpot(nb), (nb)+1), HudPosition.TOP, -100-sortedPlayersByScore()[nb].score if displayFinalScores else (nb)-500, color, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)

#!include "build.opy"
#!include "debug.opy"
#!include "winhud.opy"

#!include "maps/horizon.opy"
#!include "maps/kings_row.opy"

rule "wrong map":
    if getCurrentMap() not in [
        Map.KINGS_ROW_WINTER,
        Map.HORIZON_LUNAR_COLONY,
    ]/* or getCurrentGamemode() != Gamemode.SKIRMISH*/:
        hudHeader(getAllPlayers(), " \n\nThe map {} is not supported!\nSupported maps:\n- {}\n- {}".format(getCurrentMap(), Map.KINGS_ROW_WINTER, Map.HORIZON_LUNAR_COLONY), HudPosition.TOP, -99999, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

def displayCredits():
    hudSubtext(getAllPlayers(), "By Zezombye#9938 on Discord\ncode: GGFYC", HudPosition.LEFT, 0, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "assembling heroes":
    @Condition isAssemblingHeroes()
    setMatchTime(1)

rule "game in actual setup":
    @Condition isInSetup()
    setMatchTime(9999999)

rule "init global":
    displayCredits()
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getPlayerHit())
    #print(raycast(vect(-17.551, 6, -149.685), vect(-20.05, 6, -148.335), getAllPlayers(), [], true).getHitPosition())
    hudHeader(hostPlayer if gameStatus == GAME_NOT_STARTED and not BUILD_MODE else [], "Press {} to start the game".format(buttonString(Button.INTERACT)) if localPlayer.isPlayer else "Press Move Up / E to start the game", HudPosition.TOP, 1, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers().exclude(hostPlayer) if gameStatus == GAME_NOT_STARTED and not BUILD_MODE else [], "Waiting for host to start", HudPosition.TOP, 1, Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)

    #hide objective description
    hudSubtext(getAllPlayers() if gameStatus != GAME_NOT_STARTED else [], " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)

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
    hudSubtext(getAllPlayers() if countdown > 0 else [], " \n\n\n\n\n\n", HudPosition.TOP, -20, Color.RED, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers() if countdown > 0 else [], countdownHuds[floor(countdown)], HudPosition.TOP, -10, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "init huds for game end":
    
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n\n\n\n\n\n\n", HudPosition.TOP, -750, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers() if gameStatus == GAME_FINISHED else [], "Final Rankings" if displayFinalScores and currentRound >= NB_ROUNDS-1 else "Rankings so far" if displayFinalScores else "Place for this round", HudPosition.TOP, -740, rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ) if displayFinalScores and currentRound >= NB_ROUNDS-1 else Color.SKY_BLUE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n", HudPosition.TOP, -730, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
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
    hudSubtext(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n\n\n\n\n\n", HudPosition.RIGHT, -75, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudText(getAllPlayers() if gameStatus == GAME_FINISHED else [], " \n\n                                           \n\n\n\n\n\n\n\n\n\n\n\n\n", "                          ", null, HudPosition.RIGHT, -50, rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ) if displayFinalScores and currentRound >= NB_ROUNDS-1 else Color.BLUE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_COLOR, SpecVisibility.DEFAULT)

    #remaining time hud
    hudSubtext(getAllPlayers() if timeRemaining > 0 and timeRemaining <= TIME_REMAINING_ON_FINISH - 2.5 and gameStatus == GAME_STARTED else [], " \n\n\n\n\n\nGame ends in {} second{}".format(ceil(timeRemaining), "" if timeRemaining <= 1 else "s"), HudPosition.TOP, -10, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


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

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableMessages()
    eventPlayer.disableGamemodeInWorldUi()

rule "player died in setup":
    @Event playerDied
    @Condition gameStatus == GAME_NOT_STARTED
    wait(3, Wait.ABORT_WHEN_FALSE)
    eventPlayer.respawn()

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
    #eventPlayer.teleport(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)))
    eventPlayer.teleport((spawnPositions[0] + spawnPositions[1]) /2)
    #eventPlayer.startForcingPosition(spawnPositions[0] + directionTowards(spawnPositions[0], spawnPositions[1])*eventPlayer.getSlot()*(distance(spawnPositions[0], spawnPositions[1])/6) + (vect(0,2,0) if eventPlayer.getTeam() == Team.2 else vect(0,0,0)), false)
    eventPlayer.startForcingPosition((spawnPositions[0] + spawnPositions[1]) /2, false)
    eventPlayer.resurrect()
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (positions[0]+positions[1])/2), Relativity.TO_WORLD)
    
    eventPlayer.currentCheckpoint = 0
    chase(eventPlayer.currentCheckpoint, 9999, rate=0.0001, ChaseReeval.NONE)
    eventPlayer.setUltCharge(0)
    eventPlayer.setUltEnabled(true)
    eventPlayer.disallowButton(Button.ULTIMATE)
    wait(0.25)
    eventPlayer.stopForcingPosition()

rule "setup":
    @Condition gameStatus == GAME_IN_SETUP
    bigMessage(getAllPlayers(), "Round {}/{}".format(currentRound+1, NB_ROUNDS))
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

rule "countdown almost 0 - re-enable ult to account for lag":
    @Condition countdown > 0 and countdown < 0.3
    getAllPlayers().allowButton(Button.ULTIMATE)

rule "countdown is 0 - start game":
    @Condition hasCountdownBeenEngaged
    @Condition countdown <= 0
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, (spawnPositions[0]+spawnPositions[1])/2, 200)
    gameStatus = GAME_STARTED
    wait(1)
    stopChasingVariable(countdown)

rule "turbo boost":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate()
    @Condition countdown < 0 and countdown >= -0.1
    bigMessage(eventPlayer, "Turbo Boost!")
    eventPlayer.setMoveSpeed(110)
    wait(3.5)
    eventPlayer.setMoveSpeed(100)

rule "freeze if pressing ult early":
    @Event eachPlayer
    @Condition gameStatus == GAME_IN_SETUP
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    eventPlayer.setStatusEffect(null, Status.FROZEN, 0.7)

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
    @Condition gameStatus == GAME_STARTED
    @Condition distance(positions[eventPlayer.currentCheckpoint*2+1], raycast(positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], eventPlayer, [], true).getHitPosition()) > 0.1
    playEffect(eventPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, raycast(positions[eventPlayer.currentCheckpoint*2], positions[eventPlayer.currentCheckpoint*2+1], eventPlayer, [], true).getHitPosition(), 99999)
    eventPlayer.currentCheckpoint = round(eventPlayer.currentCheckpoint+1)
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
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
    eventPlayer.setUltCharge(0)
    eventPlayer.clearStatusEffect(Status.ROOTED)

    if not hasOnePlayerFinished:
        bigMessage(getAllPlayers(), "{} wins this round!".format(eventPlayer))
        hasOnePlayerFinished = true
        timeRemaining = TIME_REMAINING_ON_FINISH
        chase(timeRemaining, 0, rate=1, ChaseReeval.NONE)


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
    if currentRound < (NB_ROUNDS-1):
        gameStatus = GAME_IN_SETUP
        currentRound++
    else:
        wait(3)
        winner = sortedPlayersByScore()[0]
        hudSubtext(getAllPlayers(), " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, -9999, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
        hudSubtext(getAllPlayers(), " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.LEFT, -400, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
        hudSubtext(getAllPlayers(), " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.RIGHT, -400, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
        if winner.couldNameBeGuessed:
            displayWinHuds = true
        else:
            bigMessage(getAllPlayers(), "{} wins!".format(winner))
        #setSlowMotion(33)
        winner.startForcingPosition(winPosition, false)
        winner.setFacing(winFacing, Relativity.TO_WORLD)
        getAllPlayers().setStatusEffect(null, Status.ROOTED, 9999)
        getAllPlayers().setCamera(winPosition+winFacing*5, winner.getEyePosition(), 0)
        getAllPlayers().clearStatusEffect(Status.KNOCKED_DOWN)
        wait()
        winner.stopForcingPosition()
        winner.communicate(Comms.EMOTE_UP)
        winner.communicate(Comms.VOICE_LINE_UP)
        wait(10)
        declareTeamVictory(Team.1)


rule "increase player scores":
    @Event eachPlayer
    @Condition displayFinalScores
    wait(1)
    #floor((L-X)/(L-1) * 100)
    chase(eventPlayer.score, eventPlayer.score + floor(
        (len([p for p in getAllPlayers() if p.currentCheckpoint > 0])-(1+sorted([p for p in getAllPlayers() if p.currentCheckpoint > 0], lambda x: -x.currentCheckpoint).index(eventPlayer)))
        / (len([p for p in getAllPlayers() if p.currentCheckpoint > 0])-1)*100
    ), duration=1.5, ChaseReeval.NONE)

