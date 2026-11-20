local Canvas = require("src.ui.Canvas")

local CardRewardSystem = {}

CardRewardSystem.name =
    "CardRewardSystem"

local function getConfirmButton(
    registry
)
    for _, button in
        registry:each("button")
    do
        if button.action == "confirmReward"
            or button.action == "continueReward"
        then
            return button
        end
    end

    return nil
end

local function getClaimKey(
    gameState
)
    local flow =
        gameState.run.flow

    if flow
        and flow.source
            == "roadmapReward"
        and flow.rewardId
    then
        return
            "roadmap:"
            .. flow.rewardId
    end

    return
        "level:"
        .. tostring(
            gameState.run.level
        )
end

local function selectCard(
    registry,
    entity,
    gameState,
    state
)
    local reward =
        gameState.run.cardReward

    local claimKey =
        getClaimKey(
            gameState
        )

    if reward.claimedKey
        == claimKey
    then
        return
    end

    for cardEntity,
        position,
        rectangle,
        outline,
        rewardCard
    in
        registry:each(
            "position",
            "rectangle",
            "outline",
            "rewardCard"
        )
    do
        rewardCard.selected =
            cardEntity == entity

        if rewardCard.selected then
            local scale = 1.08

            local newWidth =
                rewardCard.originalWidth
                * scale

            local newHeight =
                rewardCard.originalHeight
                * scale

            position.x =
                rewardCard.originalX
                - (
                    newWidth
                    - rewardCard.originalWidth
                ) / 2

            position.y =
                rewardCard.originalY
                - (
                    newHeight
                    - rewardCard.originalHeight
                ) / 2

            rectangle.width =
                newWidth

            rectangle.height =
                newHeight

            outline.width = 4

            outline.color = {
                r = 1,
                g = 0.85,
                b = 0.25
            }

            state.selectedEntity =
                cardEntity

            state.selectedCardId =
                rewardCard.cardId

        else
            position.x =
                rewardCard.originalX

            position.y =
                rewardCard.originalY

            rectangle.width =
                rewardCard.originalWidth

            rectangle.height =
                rewardCard.originalHeight

            outline.width = 2

            outline.color = {
                r = 1,
                g = 1,
                b = 1
            }
        end
    end

    local button =
        getConfirmButton(registry)

    if button then
        button.active = true
    end
end

local function shrinkUnselectedCards(
    registry,
    selectedCardId
)
    for _,
        position,
        rectangle,
        color,
        button,
        rewardCard
    in
        registry:each(
            "position",
            "rectangle",
            "color",
            "button",
            "rewardCard"
        )
    do
        button.active = false

        if rewardCard.cardId
            ~= selectedCardId
        then
            local newWidth =
                rewardCard.originalWidth
                * 0.82

            local newHeight =
                rewardCard.originalHeight
                * 0.82

            position.x =
                rewardCard.originalX
                + (
                    rewardCard.originalWidth
                    - newWidth
                ) / 2

            position.y =
                rewardCard.originalY
                + (
                    rewardCard.originalHeight
                    - newHeight
                ) / 2

            rectangle.width =
                newWidth

            rectangle.height =
                newHeight

            color.r = 0.2
            color.g = 0.2
            color.b = 0.2
        end
    end
end

local function confirmReward(
    registry,
    gameState
)
    local reward =
        gameState.run.cardReward

    local claimKey =
        getClaimKey(
            gameState
        )

    if reward.claimedKey
        == claimKey
    then
        return
    end

    local state = registry:resource("cardRewardState")

    if not state
        or not state.selectedCardId
    then
        return
    end

    gameState.run.deck[
        #gameState.run.deck + 1
    ] = state.selectedCardId

    reward.claimedKey = claimKey

    local flow =
        gameState.run.flow

    if flow
        and flow.source
            == "roadmapReward"
        and flow.rewardId
    then
        local claimedRewards =
            gameState.run.roadmap.claimedRewards

        local alreadyClaimed =
            false

        for _, id in ipairs(
            claimedRewards
        ) do
            if id == flow.rewardId then
                alreadyClaimed = true
                break
            end
        end

        if not alreadyClaimed then
            claimedRewards[
                #claimedRewards + 1
            ] =
                flow.rewardId
        end

    else
        reward.claimedForLevel =
            gameState.run.level
    end

    shrinkUnselectedCards(
        registry,
        state.selectedCardId
    )

    Canvas.setText(
        registry,
        "cardRewardInstruction",
        "Card acquired!"
    )

    local button =
        getConfirmButton(registry)

    if button then
        button.text = "Continue"
        button.action =
            "continueReward"
        button.active = true
    end
end

local function continueReward(
    registry,
    gameState
)
    local reward =
        gameState.run.cardReward

    local claimKey =
        getClaimKey(
            gameState
        )

    if reward.claimedKey
        ~= claimKey
    then
        return
    end

    local flow =
        gameState.run.flow

    local target =
        flow
        and flow.cardRewardNext
        or "cardInventory"

    registry:spawn({
        sceneChangeRequest = {
            target = target,

            payload = {
                gameState =
                    gameState
            }
        }
    })
end

function CardRewardSystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    local gameState =
        registry:resource("gameState")

    local state =
        registry:resource(
            "cardRewardState"
        )

    if not gameState or not state then
        return
    end

    for _, eventEntity in ipairs(
        registry:query("buttonPressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "buttonPressed"
            )

        if event
            and event.canvasId
                == "cardReward"
        then

            if event.action
                == "selectRewardCard"
            then
                selectCard(
                    registry,
                    event.buttonEntity,
                    gameState,
                    state
                )

            elseif event.action
                == "confirmReward"
            then
                confirmReward(
                    registry,
                    gameState
                )

            elseif event.action
                == "continueReward"
            then
                continueReward(
                    registry,
                    gameState
                )
            end

            registry:destroy(
                eventEntity
            )
        end
    end
end

return CardRewardSystem