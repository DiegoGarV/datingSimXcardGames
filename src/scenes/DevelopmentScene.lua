local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")
local DevelopmentSetupSystem = require("src.systems.development.DevelopmentSetupSystem")
local DevelopmentSystem = require("src.systems.development.DevelopmentSystem")
local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")
local InputSystem = require("src.systems.InputSystem")
local UISystem = require("src.systems.UISystem")

local DevelopmentScene = {}

function DevelopmentScene.new(payload)
    local scene = Scene.new("Development Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    else
        scene.registry:setResource(
            "gameState",
            GameState.new(12345)
        )
    end

    scene:addSystem(DevelopmentSetupSystem)
    scene:addSystem(PauseMenuSetupSystem)
    scene:addSystem(InputSystem)
    scene:addSystem(DevelopmentSystem)
    scene:addSystem(PauseMenuSystem)
    scene:addSystem(UISystem)

    return scene
end

return DevelopmentScene