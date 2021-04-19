#!mainFile "main.opy"

rule "init debug":
    @Condition DEBUG_MODE

    for I in range(6):
        createDummy(Hero.JUNKRAT, Team.1, -1, positions[0], vect(0,0,0))
        createDummy(Hero.JUNKRAT, Team.2, -1, positions[0], vect(0,0,0))

rule "debug game finished":
    @Condition hostPlayer.isHoldingButton(Button.MELEE)
    @Condition gameStatus == GAME_NOT_STARTED
    @Condition DEBUG_MODE
    gameStatus = GAME_FINISHED

rule "debug - increase dummy checkpoints":
    @Event eachPlayer
    @Condition eventPlayer.isDummy()
    @Condition gameStatus == GAME_STARTED
    @Condition hostPlayer.isHoldingButton(Button.MELEE)
    @Condition DEBUG_MODE
    eventPlayer.currentCheckpoint++
