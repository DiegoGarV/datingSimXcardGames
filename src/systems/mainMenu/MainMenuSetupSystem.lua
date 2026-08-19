local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")
local SaveFile = require("src.state.SaveFile")

local MainMenuSetupSystem = {}

MainMenuSetupSystem.name = "MainMenuSetupSystem"

function MainMenuSetupSystem.setup(scene)
    local registry = scene.registry
    local hasSaveFile = SaveFile.isValid()
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

    Canvas.create(registry, {
        id = "newGameConfirmation",
        active = false,
        interactive = true,
        blocksGameplay = false,
        navigation = "vertical",
        selectedIndex = 1,
        priority = 100,
        dim = 0.5
    })

    Canvas.createPanel(registry, {
        canvasId = "newGameConfirmation",

        x = 175,
        y = 180,
        width = 450,
        height = 240,

        color = {
            r = 0.2,
            g = 0.2,
            b = 0.25
        }
    })

    Canvas.createText(registry, {
        canvasId = "newGameConfirmation",

        value = "Are you sure you want to delete your previous progress and start a new one?",
        font = "normal",

        x = 210,
        y = 220,
        width = 380,
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "newGameConfirmation",

        text = "Accept",
        action = "confirmNewGame",
        index = 1,
        active = true,

        x = 240,
        y = 330,
        width = 140,
        height = 50
    })

    Canvas.createButton(registry, {
        canvasId = "newGameConfirmation",

        text = "Return",
        action = "cancelNewGame",
        index = 2,
        active = true,

        x = 420,
        y = 330,
        width = 140,
        height = 50
    })
end

return MainMenuSetupSystem