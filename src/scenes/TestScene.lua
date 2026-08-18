local Scene = require("src.ecs.Scene")

local TestSetupSystem = require("src.systems.test.TestSetupSystem")
local TestMovementSystem = require("src.systems.test.TestMovementSystem")
local TestRenderSystem = require("src.systems.test.TestRenderSystem")

local TestScene = {}

function TestScene.new()
    local scene = Scene.new("Test Scene")

    scene:addSystem(TestSetupSystem)
    scene:addSystem(TestMovementSystem)
    scene:addSystem(TestRenderSystem)

    return scene
end

return TestScene