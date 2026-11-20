local RoadmapSystem = {}

RoadmapSystem.name = "RoadmapSystem"

local function startFight(
    registry,
    gameState,
    target
)
    local node =
        target.data

    local flow =
        gameState.run.flow

    flow.source = "fight"

    flow.fightNodeId =
        node.id

    flow.fightNodeLevel =
        node.level

    flow.rewardId = nil

    flow.developmentNext =
        "cardReward"

    flow.cardRewardNext =
        "cardInventory"

    registry:spawn({
        sceneChangeRequest = {
            target = "fight",

            payload = {
                gameState = gameState
            }
        }
    })
end

local function startRoadmapReward(
    registry,
    gameState,
    reward
)
    local flow =
        gameState.run.flow

    flow.source =
        "roadmapReward"

    flow.rewardId =
        reward.id

    flow.fightNodeId = nil
    flow.fightNodeLevel = nil

    if reward.rewardType
        == "development"
    then
        gameState.run.development.actionsRemaining =
            reward.developmentPoints

        flow.developmentNext =
            "roadmap"

        flow.cardRewardNext =
            nil

        registry:spawn({
            sceneChangeRequest = {
                target = "development",

                payload = {
                    gameState = gameState
                }
            }
        })


    elseif reward.rewardType
        == "card"
    then
        flow.developmentNext =
            nil

        flow.cardRewardNext =
            "roadmap"

        registry:spawn({
            sceneChangeRequest = {
                target = "cardReward",

                payload = {
                    gameState = gameState
                }
            }
        })


    elseif reward.rewardType
        == "both"
    then
        gameState.run.development.actionsRemaining =
            reward.developmentPoints

        flow.developmentNext =
            "cardReward"

        flow.cardRewardNext =
            "roadmap"

        registry:spawn({
            sceneChangeRequest = {
                target = "development",

                payload = {
                    gameState = gameState
                }
            }
        })
    end
end

local function processSpace(
    registry,
    gameState
)
    local roadmapState =
        registry:resource(
            "roadmapState"
        )

    if not roadmapState
        or not roadmapState.activeTarget
    then
        return
    end

    local target =
        roadmapState.activeTarget

    if target.kind == "node" then
        startFight(
            registry,
            gameState,
            target
        )

    elseif target.kind == "reward" then
        startRoadmapReward(
            registry,
            gameState,
            target.data
        )
    end
end

function RoadmapSystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    local gameState =
        registry:resource(
            "gameState"
        )

    if not gameState then
        return
    end

    for _, eventEntity in ipairs(
        registry:query(
            "keyPressed"
        )
    ) do
        local event =
            registry:get(
                eventEntity,
                "keyPressed"
            )

        if event
            and event.key == "space"
        then
            processSpace(
                registry,
                gameState
            )

            registry:destroy(
                eventEntity
            )
        end
    end

    for _, eventEntity in ipairs(
        registry:query(
            "buttonPressed"
        )
    ) do
        local event =
            registry:get(
                eventEntity,
                "buttonPressed"
            )

        if event
            and event.canvasId
                == "roadmap"
        then
            if event.action
                == "openInventory"
            then
                registry:spawn({
                    sceneChangeRequest = {
                        target = "cardInventory",

                        payload = {
                            gameState = gameState
                        }
                    }
                })
            end

            registry:destroy(
                eventEntity
            )
        end
    end
end

return RoadmapSystem