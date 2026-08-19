local Canvas = require("src.ui.Canvas")
local SaveFile = require("src.state.SaveFile")

local PauseMenuSystem = {}

PauseMenuSystem.name = "PauseMenuSystem"
PauseMenuSystem.runWhenCanvasBlocked = true

local PAUSE_CANVAS_ID = "pauseMenu"

local function getPauseCanvas(registry)
    local _, canvas = Canvas.get(
        registry,
        PAUSE_CANVAS_ID
    )

    return canvas
end

local function openPauseMenu(registry)
    local canvas = getPauseCanvas(registry)

    if not canvas then
        return
    end

    canvas.active = true
    canvas.selectedIndex = 1
end

local function closePauseMenu(registry)
    local canvas = getPauseCanvas(registry)

    if canvas then
        canvas.active = false
    end
end

local function togglePauseMenu(registry)
    local canvas = getPauseCanvas(registry)

    if not canvas then
        return
    end

    if canvas.active then
        closePauseMenu(registry)
    else
        openPauseMenu(registry)
    end
end

local function saveGame(registry)
    local gameState = registry:resource("gameState")

    if not gameState then
        print("Error: no se encontró gameState para guardar")
        return false
    end

    local success = SaveFile.save(gameState)

    if not success then
        print("Error: no se pudo guardar la partida")
        return false
    end

    return true
end

local function saveAndQuit(registry)
    if not saveGame(registry) then
        return
    end

    registry:spawn({
        sceneChangeRequest = {
            target = "mainMenu"
        }
    })
end

local function processAction(registry, action)
    if action == "resumeGame" then
        closePauseMenu(registry)

    elseif action == "saveGame" then
        saveGame(registry)

    elseif action == "saveAndQuit" then
        saveAndQuit(registry)
    end
end

function PauseMenuSystem.update(scene, dt)
    local registry = scene.registry

    for _, eventEntity in ipairs(
        registry:query("keyPressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "keyPressed"
            )

        if event and event.key == "escape" then
            togglePauseMenu(registry)
        end
    end

    local canvas = getPauseCanvas(registry)

    if not canvas or not canvas.active then
        return
    end

    for _, eventEntity in ipairs(
        registry:query("buttonPressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "buttonPressed"
            )

        if event
            and event.canvasId == PAUSE_CANVAS_ID then

            processAction(
                registry,
                event.action
            )

            registry:destroy(eventEntity)
        end
    end
end

return PauseMenuSystem