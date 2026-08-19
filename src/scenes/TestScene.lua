local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")
local TestSetupSystem = require("src.systems.test.TestSetupSystem")
local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local InputSystem = require("src.systems.InputSystem")
local TestBattleSystem = require("src.systems.test.TestBattleSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")
local TestAnimationSystem = require("src.systems.test.TestAnimationSystem")
local TestRenderSystem = require("src.systems.test.TestRenderSystem")
local UISystem = require("src.systems.UISystem")

local TestScene = {}

function TestScene.new(payload)
    local scene = Scene.new("Test Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    end

    scene:addSystem(TestSetupSystem)
    scene:addSystem(PauseMenuSetupSystem)
    scene:addSystem(InputSystem)
    scene:addSystem(TestBattleSystem)
    scene:addSystem(PauseMenuSystem)
    scene:addSystem(TestAnimationSystem)
    scene:addSystem(TestRenderSystem)
    scene:addSystem(UISystem)

    return scene
end

return TestScene