local Scene = require("src.ecs.Scene")

local MainMenuSetupSystem = require("src.systems.mainMenu.MainMenuSetupSystem")
local InputSystem = require("src.systems.InputSystem")
local MainMenuActionSystem = require("src.systems.mainMenu.MainMenuActionSystem")
local MainMenuRenderSystem = require("src.systems.mainMenu.MainMenuRenderSystem")
local UISystem = require("src.systems.UISystem")

local MainMenuScene = {}

function MainMenuScene.new()
    local scene = Scene.new("Main Menu")

    scene:addSystem(MainMenuSetupSystem)
    scene:addSystem(InputSystem)
    scene:addSystem(MainMenuActionSystem)
    scene:addSystem(MainMenuRenderSystem)
    scene:addSystem(UISystem)

    return scene
end

return MainMenuScene