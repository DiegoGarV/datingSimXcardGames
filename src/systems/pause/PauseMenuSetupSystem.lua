local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")

local PauseMenuSetupSystem = {}

PauseMenuSetupSystem.name = "PauseMenuSetupSystem"

function PauseMenuSetupSystem.setup(scene)
    local registry = scene.registry

    Canvas.create(registry, {
        id = "pauseMenu",
        active = false,
        interactive = true,
        blocksGameplay = true,
        navigation = "vertical",
        selectedIndex = 1,
        priority = 100,
        dim = 0.65
    })

    Canvas.createText(registry, {
        canvasId = "pauseMenu",
        x = 0,
        y = 150,
        width = GameConfig.width,
        value = "Pause",
        font = "title",
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "pauseMenu",
        x = 300,
        y = 250,
        width = 200,
        height = 50,
        text = "Resume",
        action = "resumeGame",
        index = 1
    })

    Canvas.createButton(registry, {
        canvasId = "pauseMenu",
        x = 300,
        y = 320,
        width = 200,
        height = 50,
        text = "Save Game",
        action = "saveGame",
        index = 2
    })

    Canvas.createButton(registry, {
        canvasId = "pauseMenu",
        x = 300,
        y = 390,
        width = 200,
        height = 50,
        text = "Save and Quit",
        action = "saveAndQuit",
        index = 3
    })

    Canvas.create(registry, {
        id = "saveConfirmation",
        active = false,
        interactive = true,
        blocksGameplay = true,
        navigation = "vertical",
        selectedIndex = 1,
        priority = 200,
        dim = 0.15
    })

    Canvas.createPanel(registry, {
        canvasId = "saveConfirmation",

        x = 225,
        y = 210,
        width = 350,
        height = 180,

        color = {
            r = 0.2,
            g = 0.2,
            b = 0.25
        }
    })

    Canvas.createText(registry, {
        canvasId = "saveConfirmation",

        value = "Game saved successfully!",
        font = "normal",

        x = 250,
        y = 285,
        width = 300,
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "saveConfirmation",

        text = "X",
        action = "closeSaveConfirmation",
        index = 1,
        active = true,

        x = 520,
        y = 225,
        width = 40,
        height = 40,

        color = {
            r = 0.55,
            g = 0.2,
            b = 0.2
        }
    })
end

return PauseMenuSetupSystem