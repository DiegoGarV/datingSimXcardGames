local Canvas = require("src.ui.Canvas")
local RoadmapGenerator = require("src.data.RoadmapGenerator")

local RoadmapSetupSystem = {}

RoadmapSetupSystem.name =
    "RoadmapSetupSystem"

function RoadmapSetupSystem.setup(
    scene
)
    local registry = scene.registry

    local gameState =
        registry:resource(
            "gameState"
        )

    if not gameState then
        return
    end

    if not gameState.run.roadmap then
        gameState.run.roadmap = {
            currentNode = "level1A",
            completedNodes = {},
            claimedRewards = {}
        }
    end

    local roadmap =
        RoadmapGenerator.generate(
            gameState.run.seed
        )

    registry:setResource(
        "roadmapState",
        {
            map = roadmap,

            hoveredNodeId = nil,

            activeNodeId = nil
        }
    )

    Canvas.create(
        registry,
        {
            id = "roadmap",
            active = true,
            interactive = true,
            blocksGameplay = false,
            navigation = "vertical",
            selectedIndex = 1,
            priority = 10,
            dim = 0
        }
    )

    Canvas.createText(
        registry,
        {
            id = "roadmapTitle",
            canvasId = "roadmap",

            x = 100,
            y = 120,
            width = 600,

            value = "ROADMAP",
            font = "title",
            align = "center"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "roadmapPlaceholder",
            canvasId = "roadmap",

            x = 150,
            y = 230,
            width = 500,

            value =
                "Roadmap placeholder",
            font = "normal",
            align = "center"
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "roadmap",

            x = 300,
            y = 360,

            width = 200,
            height = 55,

            text = "Inventory",
            font = "button",

            action =
                "openInventory",

            index = 1
        }
    )
end

return RoadmapSetupSystem