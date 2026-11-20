local Canvas = require("src.ui.Canvas")

local DevelopmentSystem = {}

DevelopmentSystem.name = "DevelopmentSystem"

local function findButtonByAction(registry, action)
    for _, button in registry:each("button") do
        if button.action == action then
            return button
        end
    end

    return nil
end

local function updateUI(
    registry,
    gameState,
    development
)
    local progression =
        gameState.run.progression

    local actionsRemaining =
        gameState.run.development.actionsRemaining

    Canvas.setText(
        registry,
        "conquestLevel",
        "Level "
            .. tostring(progression.conquest)
    )

    Canvas.setText(
        registry,
        "attackLevel",
        "Level "
            .. tostring(progression.attack)
    )

    Canvas.setText(
        registry,
        "protectionLevel",
        "Level "
            .. tostring(progression.protection)
    )

    Canvas.setText(
        registry,
        "actionsRemaining",
        "Actions Remaining: "
            .. tostring(actionsRemaining)
    )

    Canvas.setText(
        registry,
        "developmentFeedback",
        development.feedback
    )
end

local function finishDevelopment(registry)
    local actions = {
        "trainConquest",
        "trainAttack",
        "trainProtection"
    }

    for _, action in ipairs(actions) do
        local button =
            findButtonByAction(
                registry,
                action
            )

        if button then
            button.active = false
        end
    end

    local continueButton =
        findButtonByAction(
            registry,
            "continueDevelopment"
        )

    if continueButton then
        continueButton.active = true
    end
end

local function train(
    registry,
    gameState,
    progression,
    development,
    attribute,
    label
)
    local developmentProgress =
        gameState.run.development

    if developmentProgress.actionsRemaining <= 0 then
        return
    end

    progression[attribute] =
        progression[attribute] + 1

    developmentProgress.actionsRemaining =
        developmentProgress.actionsRemaining - 1

    development.feedback =
        label
        .. " increased to Level "
        .. tostring(
            progression[attribute]
        )
        .. "!"

    if developmentProgress.actionsRemaining == 0 then
        finishDevelopment(registry)
    end
end

local function processAction(
    registry,
    action,
    gameState,
    development
)
    local progression =
        gameState.run.progression

    if action == "trainConquest" then
        train(
            registry,
            gameState,
            progression,
            development,
            "conquest",
            "Conquest"
        )

    elseif action == "trainAttack" then
        train(
            registry,
            gameState,
            progression,
            development,
            "attack",
            "Attack"
        )

    elseif action == "trainProtection" then
        train(
            registry,
            gameState,
            progression,
            development,
            "protection",
            "Protection"
        )

    elseif action == "continueDevelopment" then
        if gameState.run.development.actionsRemaining
            > 0
        then
            return
        end

        local flow =
            gameState.run.flow

        local target =
            flow
            and flow.developmentNext
            or "cardReward"

        if flow
            and flow.source
                == "roadmapReward"
            and target
                == "roadmap"
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
        end

        registry:spawn({
            sceneChangeRequest = {
                target = target,

                payload = {
                    gameState = gameState
                }
            }
        })
    end
end

function DevelopmentSystem.update(scene, dt)
    local registry = scene.registry

    local gameState =
        registry:resource("gameState")

    local development =
        registry:resource(
            "developmentState"
        )

    if not gameState or not development then
        return
    end

    if gameState.run.development.actionsRemaining == 0 then
        finishDevelopment(registry)
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
            and event.canvasId == "development"
        then
            processAction(
                registry,
                event.action,
                gameState,
                development
            )

            registry:destroy(eventEntity)
        end
    end

    updateUI(
        registry,
        gameState,
        development
    )
end

return DevelopmentSystem