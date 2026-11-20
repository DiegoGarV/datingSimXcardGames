local Canvas = require("src.ui.Canvas")
local RoadmapGenerator = require("src.data.RoadmapGenerator")

local LEVEL_START_Y = 200
local LEVEL_GAP_Y = 170

local NODE_RADIUS = 30

local NODE_X_POSITIONS = {
    [1] = {
        400
    },

    [2] = {
        230,
        570
    },

    [3] = {
        130,
        400,
        670
    }
}

local RoadmapSetupSystem = {}

RoadmapSetupSystem.name = "RoadmapSetupSystem"

local function getNodePosition(
    level,
    index,
    nodeCount
)
    local positions =
        NODE_X_POSITIONS[
            nodeCount
        ]

    local x =
        positions[index]

    local y =
        LEVEL_START_Y
        + (8 - level)
        * LEVEL_GAP_Y

    return x, y
end

local function createFightNodes(
    registry,
    roadmap
)
    local nodeEntities = {}

    for level = 1, 8 do
        local levelNodes =
            roadmap.levels[level]

        local nodeCount =
            #levelNodes

        for index, node in ipairs(
            levelNodes
        ) do
            local x, y =
                getNodePosition(
                    level,
                    index,
                    nodeCount
                )

            local entity =
                registry:spawn({
                    position = {
                        x = x,
                        y = y
                    },

                    circle = {
                        radius =
                            NODE_RADIUS
                    },

                    roadmapNode = {
                        id = node.id,
                        kind = node.kind,
                        level = node.level,
                        focus = node.focus
                    }
                })

            nodeEntities[node.id] =
                entity
        end
    end

    return nodeEntities
end

local function createConnections(
    registry,
    roadmap
)
    for level = 1, 7 do
        for _, node in ipairs(
            roadmap.levels[level]
        ) do
            for _, childId in ipairs(
                node.children
            ) do
                registry:spawn({
                    roadmapConnection = {
                        fromId = node.id,
                        toId = childId
                    }
                })
            end
        end
    end
end

local function createRewards(
    registry,
    roadmap,
    nodeEntities
)
    for _, reward in ipairs(
        roadmap.rewards
    ) do
        local parentEntity =
            nodeEntities[
                reward.parentNode
            ]

        local parentPosition =
            registry:get(
                parentEntity,
                "position"
            )

        if parentPosition then
            registry:spawn({
                position = {
                    x = parentPosition.x + 65,

                    y = parentPosition.y
                },

                roadmapReward = {
                    id = reward.id,

                    level =
                        reward.level,

                    rewardType =
                        reward.rewardType,

                    developmentPoints =
                        reward.developmentPoints,

                    parentNode =
                        reward.parentNode
                }
            })
        end
    end
end

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

    local nodeEntities =
        createFightNodes(
            registry,
            roadmap
        )

    createConnections(
        registry,
        roadmap
    )

    createRewards(
        registry,
        roadmap,
        nodeEntities
    )

    registry:setResource(
        "roadmapNodeEntities",
        nodeEntities
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

            x = 30,
            y = 25,
            width = 250,

            value = "ROADMAP",
            font = "normal",
            align = "left"
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "roadmap",

            x = 650,
            y = 25,

            width = 120,
            height = 45,

            text = "Inventory",
            font = "small",

            action =
                "openInventory",

            index = 1
        }
    )
    
    local level1Entity =
        nodeEntities[
            gameState.run.roadmap.currentNode
        ]

    local level1Position =
        registry:get(
            level1Entity,
            "position"
        )

    local cameraY = 0

    if level1Position then
        cameraY =
            level1Position.y
            - 300
    end

    registry:setResource(
        "roadmapCamera",
        {
            x = 0,
            y = cameraY,

            viewportWidth = 800,
            viewportHeight = 600
        }
    )
end

return RoadmapSetupSystem