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
end

return PauseMenuSetupSystem