local TestRenderSystem = {}

TestRenderSystem.name = "TestRenderSystem"

local function drawCards(registry)
    for _, position, rectangle, color, card in registry:each(
        "position",
        "rectangle",
        "color",
        "card"
    ) do
        love.graphics.setColor(
            color.r,
            color.g,
            color.b,
            1
        )

        love.graphics.rectangle(
            "fill",
            position.x,
            position.y,
            rectangle.width,
            rectangle.height,
            6,
            6
        )

        if card.selected then
            love.graphics.setColor(
                1,
                1,
                1,
                1
            )

            love.graphics.setLineWidth(4)

        elseif card.hovered then
            love.graphics.setColor(
                1,
                1,
                1,
                0.7
            )

            love.graphics.setLineWidth(2)

        else
            love.graphics.setColor(
                0.15,
                0.15,
                0.15,
                1
            )

            love.graphics.setLineWidth(2)
        end

        love.graphics.rectangle(
            "line",
            position.x,
            position.y,
            rectangle.width,
            rectangle.height,
            6,
            6
        )
    end
end

local function drawAvatars(registry)
    for _, position, circle, color in registry:each(
        "position",
        "circle",
        "color",
        "avatar"
    ) do
        love.graphics.setColor(
            color.r,
            color.g,
            color.b,
            1
        )

        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            circle.radius
        )
    end
end

local function drawGirl(registry)
    for _, position, triangle, color in registry:each(
        "position",
        "triangle",
        "color",
        "girl"
    ) do
        love.graphics.setColor(
            color.r,
            color.g,
            color.b,
            1
        )

        local halfWidth =
            triangle.width / 2

        love.graphics.polygon(
            "fill",

            position.x,
            position.y - triangle.height / 2,

            position.x - halfWidth,
            position.y + triangle.height / 2,

            position.x + halfWidth,
            position.y + triangle.height / 2
        )
    end
end

function TestRenderSystem.draw(scene)
    local registry = scene.registry

    love.graphics.clear(
        0.08,
        0.08,
        0.1,
        1
    )

    drawAvatars(registry)
    drawGirl(registry)
    drawCards(registry)

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setLineWidth(1)
end

return TestRenderSystem