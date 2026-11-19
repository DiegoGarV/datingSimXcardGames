local SaveFile = require("src.state.SaveFile")
local GameState = require("src.state.GameState")
local Canvas = require("src.ui.Canvas")

local MainMenuActionSystem = {}

MainMenuActionSystem.name = "MainMenuActionSystem"

local NEW_GAME_CONFIRMATION_ID = "newGameConfirmation"

local function startNewGame(registry)
    SaveFile.delete()

    local gameState = GameState.new(12345)

    SaveFile.save(gameState)

    registry:spawn({
        sceneChangeRequest = {
            target = "fight",
            payload = {gameState = gameState}
        }
    })
end

local function openNewGameConfirmation(registry)
    Canvas.show(
        registry,
        NEW_GAME_CONFIRMATION_ID
    )
end

local function closeNewGameConfirmation(registry)
    Canvas.hide(
        registry,
        NEW_GAME_CONFIRMATION_ID
    )
end

local function processButtonAction(registry, action)
    if action == "newGame" then
        if SaveFile.isValid() then
            openNewGameConfirmation(registry)
        else
            startNewGame(registry)
        end

    elseif action == "confirmNewGame" then
        startNewGame(registry)

    elseif action == "cancelNewGame" then
        closeNewGameConfirmation(registry)

    elseif action == "loadGame" then
        local gameState = SaveFile.load()

        if gameState then
            registry:spawn({
                sceneChangeRequest = {
                    target = "fight",
                    payload = {gameState = gameState}
                }
            })
        end

    elseif action == "quit" then
        love.event.quit()
    end
end

function MainMenuActionSystem.update(scene, dt)
    local registry = scene.registry
    local events = registry:query("buttonPressed")

    for _, eventEntity in ipairs(events) do
        local buttonPressed = registry:get(eventEntity, "buttonPressed")

        if buttonPressed then
            local isMainMenu = buttonPressed.canvasId == "mainMenu"
            local isConfirmation = buttonPressed.canvasId == "newGameConfirmation"

            if isMainMenu or isConfirmation then
                processButtonAction(registry, buttonPressed.action)
            end
        end

        registry:destroy(eventEntity)
    end

    for _, eventEntity in ipairs(registry:query("keyPressed")) do
        local keyPressed = registry:get(eventEntity, "keyPressed")

        if keyPressed and keyPressed.key == "escape" and
            Canvas.isActive(registry, NEW_GAME_CONFIRMATION_ID) then
            
                closeNewGameConfirmation(registry)
        end
    end
end

return MainMenuActionSystem