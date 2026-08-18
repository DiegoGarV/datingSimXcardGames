local MainMenuActionSystem = {}

MainMenuActionSystem.name = "MainMenuActionSystem"

local function processButtonAction(action)
    if action == "newGame" then
        -- Por ahora no hace nada
    elseif action == "saveGame" then
        -- Tampoco hace nada aún
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
            processButtonAction(buttonPressed.action)
        end

        registry:destroy(eventEntity)
    end
end

return MainMenuActionSystem