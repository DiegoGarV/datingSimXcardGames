local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")
local RoadmapSetupSystem = require("src.systems.roadmap.RoadmapSetupSystem")
local RoadmapSystem = require("src.systems.roadmap.RoadmapSystem")
local InputSystem = require("src.systems.InputSystem")
local RoadmapRenderSystem = require("src.systems.roadmap.RoadmapRenderSystem")
local UISystem = require("src.systems.UISystem")

local RoadmapScene = {}

function RoadmapScene.new(payload)
    local scene =
        Scene.new("Roadmap Scene")

    if payload
        and payload.gameState
    then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    else
        -- Debug fallback
        scene.registry:setResource(
            "gameState",
            GameState.new(12345)
        )
    end

    scene:addSystem(
        RoadmapSetupSystem
    )

    scene:addSystem(
        InputSystem
    )

    scene:addSystem(
        RoadmapSystem
    )

    scene:addSystem(
        RoadmapRenderSystem
    )

    scene:addSystem(
        UISystem
    )

    return scene
end

return RoadmapScene