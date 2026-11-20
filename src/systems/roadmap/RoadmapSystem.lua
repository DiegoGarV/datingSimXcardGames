local RoadmapSystem = {}

RoadmapSystem.name =
    "RoadmapSystem"

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

            elseif event.action
                == "startFight"
            then
                registry:spawn({
                    sceneChangeRequest = {
                        target = "fight",

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