#!mainFile "main.opy"

rule "build mode":
    @Condition BUILD_MODE
    print("You are in build mode.")

rule "display looking position":
    @Event eachPlayer
    @Condition BUILD_MODE
    print("Looking position: {}".format(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition()))
    createEffect(getAllPlayers(), Effect.SPHERE, Color.WHITE, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition(), 0.3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    print("Position of {}: {}".format(eventPlayer, eventPlayer.getPosition()))

rule "add to array":
    @Event eachPlayer
    @Condition BUILD_MODE
    @Condition eventPlayer.isHoldingButton(ButtonLiteral.INTERACT)
    positions.append(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition())
    createEffect(getAllPlayers(), Effect.SPHERE, Color.WHITE, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition(), 0.3, EffectReeval.VISIBILITY)
