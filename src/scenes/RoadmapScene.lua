local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")
local RoadmapSetupSystem = require("src.systems.roadmap.RoadmapSetupSystem")
local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local RoadmapSystem = require("src.systems.roadmap.RoadmapSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")
local InputSystem = require("src.systems.InputSystem")
local RoadmapAccessSystem = require("src.systems.roadmap.RoadmapAccessSystem")
local RoadmapMovementSystem = require("src.systems.roadmap.RoadmapMovementSystem")
local RoadmapInteractionSystem = require("src.systems.roadmap.RoadmapInteractionSystem")
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
        PauseMenuSetupSystem
    )

    scene:addSystem(
        PauseMenuSetupSystem
    )

    scene:addSystem(
        InputSystem
    )

    scene:addSystem(
        RoadmapAccessSystem
    )

    scene:addSystem(
        RoadmapMovementSystem
    )

    scene:addSystem(
        RoadmapInteractionSystem
    )

    scene:addSystem(
        RoadmapSystem
    )

    scene:addSystem(
        PauseMenuSystem
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