local TestRenderSystem = {}

TestRenderSystem.name = "TestRenderSystem"

function TestRenderSystem.draw(scene)
    love.graphics.clear(0.08, 0.08, 0.12)

    for _, position, rectangle, color in
        scene.registry:each(
            "position",
            "rectangle",
            "color"
        )
    do
        love.graphics.setColor(
            color.r,
            color.g,
            color.b
        )

        love.graphics.rectangle(
            "fill",
            position.x,
            position.y,
            rectangle.width,
            rectangle.height
        )
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.print(
        "Debug Play / Pause / Step Test",
        20,
        20
    )
end

return TestRenderSystem