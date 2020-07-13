#!mainFile "main.opy"

/*

Beams must be 0.60m above the floor!

*/

rule "build mode":
    @Condition BUILD_MODE
    print("You are in build mode.")
    if "test" != p"test":
        print("Warning: Obfuscation is enabled!")

rule "display looking position":
    @Event eachPlayer
    @Condition BUILD_MODE
    print("Looking position: {} (+{})".format(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition(), (raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition()-eventPlayer.getPosition()).y))
    createEffect(getAllPlayers(), Effect.SPHERE, Color.WHITE, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition(), 0.3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    print("Position of {}: {}".format(eventPlayer, eventPlayer.getPosition()))
    print("Facing Direction of {}: {}".format(eventPlayer, eventPlayer.getFacingDirection()))

rule "add to array":
    @Event eachPlayer
    @Condition BUILD_MODE
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    positions.append(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition())
    createEffect(getAllPlayers(), Effect.SPHERE, Color.WHITE, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition()+eventPlayer.getFacingDirection()*30, [], [], true).getHitPosition(), 0.3, EffectReeval.VISIBILITY)

rule "display already done positions":
    @Condition BUILD_MODE
    wait(1)
    for I in range(len(positions)):
        createEffect(getAllPlayers(), Effect.SPHERE, Color.WHITE, positions[I], 0.3, EffectReeval.VISIBILITY)

rule "tp":
    @Event eachPlayer
    @Condition BUILD_MODE
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    eventPlayer.teleport(worldVector(vect(0,0,5), eventPlayer, Transform.ROTATION_AND_TRANSLATION))

rule "regen ult":
    @Event eachPlayer
    @Condition BUILD_MODE
    @Condition not eventPlayer.isUsingUltimate()
    wait(1)
    eventPlayer.setUltCharge(100)
    if RULE_CONDITION: goto RULE_START