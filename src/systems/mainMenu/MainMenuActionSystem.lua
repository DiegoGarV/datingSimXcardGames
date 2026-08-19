local SaveFile = require("src.state.SaveFile")
local GameState = require("src.state.GameState")

local MainMenuActionSystem = {}

MainMenuActionSystem.name = "MainMenuActionSystem"

local function processButtonAction(registry, action)
    if action == "newGame" then
        local gameState = GameState.new(12345)

        SaveFile.save(gameState)

        registry:spawn({
            sceneChangeRequest = {
                target = "test",

                payload = {
                    gameState = gameState
                }
            }
        })
    elseif action == "loadGame" then
        local gameState = SaveFile.load()

        if gameState then
            registry:spawn({
                sceneChangeRequest = {
                    target = "test",
                    payload = gameState
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

        if buttonPressed and buttonPressed.canvasId == "mainMenu" then
            processButtonAction(registry, buttonPressed.action)
        end

        registry:destroy(eventEntity)
    end
end

return MainMenuActionSystem