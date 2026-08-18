local MainMenuRenderSystem = {}

MainMenuRenderSystem.name = "MainMenuRenderSystem"

function MainMenuRenderSystem.draw(scene)
    love.graphics.clear(
        0.08,
        0.06,
        0.12,
        1
    )
end

return MainMenuRenderSystem