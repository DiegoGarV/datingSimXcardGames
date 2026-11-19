local Canvas = require("src.ui.Canvas")
local SaveFile = require("src.state.SaveFile")
local SceneManager = require("src.ecs.SceneManager")

local PauseMenuSystem = {}

PauseMenuSystem.name = "PauseMenuSystem"
PauseMenuSystem.runWhenCanvasBlocked = true

local PAUSE_CANVAS_ID = "pauseMenu"
local SAVE_CONFIRMATION_CANVAS_ID = "saveConfirmation"

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

    gameState.run.currentScene = SceneManager.currentName()

    local success = SaveFile.save(gameState)

    if not success then
        print("Error: no se pudo guardar la partida")
        return false
    end

    return true
end

local function openSaveConfirmation(registry)
    Canvas.show(
        registry,
        SAVE_CONFIRMATION_CANVAS_ID
    )
end

local function closeSaveConfirmation(registry)
    Canvas.hide(
        registry,
        SAVE_CONFIRMATION_CANVAS_ID
    )
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

local function isSaveConfirmationOpen(registry)
    return Canvas.isActive(
        registry,
        SAVE_CONFIRMATION_CANVAS_ID
    )
end

local function processAction(registry, action)
    if action == "resumeGame" then
        closePauseMenu(registry)

    elseif action == "saveGame" then
        if saveGame(registry) then
            openSaveConfirmation(registry)
        end

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
            if isSaveConfirmationOpen(registry) then
                closeSaveConfirmation(registry)
            else
                togglePauseMenu(registry)
            end
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

        if event then
            if event.canvasId == PAUSE_CANVAS_ID then
                processAction(
                    registry,
                    event.action
                )

                registry:destroy(eventEntity)
            
            elseif event.canvasId == SAVE_CONFIRMATION_CANVAS_ID then
                if event.action == "closeSaveConfirmation" then
                    closeSaveConfirmation(registry)
                end

                registry:destroy(eventEntity)
            end
        end
    end
end

return PauseMenuSystem