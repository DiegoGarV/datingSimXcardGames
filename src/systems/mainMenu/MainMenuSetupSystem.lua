local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")
local SaveFile = require("src.state.SaveFile")

local MainMenuSetupSystem = {}

MainMenuSetupSystem.name = "MainMenuSetupSystem"

local hasSaveFile = SaveFile.exists()

function MainMenuSetupSystem.setup(scene)
    local registry = scene.registry
    local screenWidth = GameConfig.width
    local buttonWidth = 300
    local buttonHeight = 60
    local buttonSpacing = 20
    local buttonX = (screenWidth - buttonWidth) / 2
    local firstButtonY = 240

    Canvas.create(registry, {
        id = "mainMenu",
        active = true,
        interactive = true,
        blocksGameplay = false,
        navigation = "vertical",
        selectedIndex = 1,
        priority = 0,
        dim = 0
    })

    Canvas.createText(registry, {
        id = "mainMenuTitle",
        canvasId = "mainMenu",
        value = "Placeholder Title", 
        font = "title",

        x = 0,
        y = 90,
        width = screenWidth,
        align = "center",

        color = {
            r = 1,
            g = 1,
            b = 1
        }
    })

    Canvas.createButton(registry, {
        canvasId = "mainMenu",

        text = "New Game",
        action = "newGame",
        index = 1,
        active = true,

        x = buttonX,
        y = 240,
        width = buttonWidth,
        height = buttonHeight,

        color = {
            r = 0.35,
            g = 0.25,
            b = 0.55
        }
    })

    Canvas.createButton(registry, {
        canvasId = "mainMenu",

        text = "Load Game",
        action = "loadGame",
        index = 2,
        active = hasSaveFile,

        x = buttonX,
        y = 320,
        width = buttonWidth,
        height = buttonHeight,

        color = {
            r = 0.35,
            g = 0.25,
            b = 0.55
        }
    })

    Canvas.createButton(registry, {
        canvasId = "mainMenu",

        text = "Quit",
        action = "quit",
        index = 3,
        active = true,

        x = buttonX,
        y = 400,
        width = buttonWidth,
        height = buttonHeight,

        color = {
            r = 0.35,
            g = 0.25,
            b = 0.55
        }
    })
end

return MainMenuSetupSystem