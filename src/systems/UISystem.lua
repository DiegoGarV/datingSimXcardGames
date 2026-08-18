local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")

local UISystem = {}

UISystem.name = "UISystem"

function UISystem.setup(scene)
    local registry = scene.registry

    local _, resources = registry:first("uiResources")

    if resources then
        return
    end

    registry:spawn({
        uiResources = {
            fonts = {
                title =
                    love.graphics.newFont(48),

                normal =
                    love.graphics.newFont(24),

                button =
                    love.graphics.newFont(24)
            }
        }
    })
end

local function getActiveCanvases(
    registry
)
    local canvases = {}

    for entity, canvas in
        registry:each("canvas")
    do
        if canvas.active then
            canvases[#canvases + 1] = {
                entity = entity,
                canvas = canvas
            }
        end
    end

    table.sort(
        canvases,
        function(a, b)
            if a.canvas.priority == b.canvas.priority then
                return a.entity < b.entity
            end

            return a.canvas.priority < b.canvas.priority
        end
    )

    return canvases
end

local function drawCanvasBackground(
    canvas
)
    if canvas.dim <= 0 then
        return
    end

    local screenWidth = GameConfig.width
    local screenHeight = GameConfig.height

    love.graphics.setColor(
        0,
        0,
        0,
        canvas.dim
    )

    love.graphics.rectangle(
        "fill",
        0,
        0,
        screenWidth,
        screenHeight
    )
end

local function drawCanvasTexts(
    registry,
    fonts,
    canvasId
)
    for _, position, color,
        uiElement, text
    in
        registry:each(
            "position",
            "color",
            "uiElement",
            "uiText"
        )
    do
        if uiElement.canvasId == canvasId then
            local font =
                fonts[text.font]
                or fonts.normal

            love.graphics.setFont(font)

            love.graphics.setColor(
                color.r or 1,
                color.g or 1,
                color.b or 1,
                color.a or 1
            )

            love.graphics.printf(
                text.value,
                position.x,
                position.y,
                text.width,
                text.align
            )
        end
    end
end

local function drawButtonBackground(
    position,
    rectangle,
    color,
    isActive,
    isSelected
)
    if not isActive then
        love.graphics.setColor(
            (color.r or 1) * 0.35,
            (color.g or 1) * 0.35,
            (color.b or 1) * 0.35,
            color.a or 1
        )

    elseif isSelected then
        love.graphics.setColor(
            0.35,
            0.65,
            1,
            1
        )

    else
        love.graphics.setColor(
            color.r or 1,
            color.g or 1,
            color.b or 1,
            color.a or 1
        )
    end

    love.graphics.rectangle(
        "fill",
        position.x,
        position.y,
        rectangle.width,
        rectangle.height,
        8,
        8
    )
end

local function drawButtonOutline(
    outline,
    position,
    rectangle,
    isActive,
    isSelected
)
    if not outline then
        return
    end

    if not isActive then
        love.graphics.setLineWidth(2)

        love.graphics.setColor(
            0.35,
            0.35,
            0.35,
            1
        )

    elseif isSelected then
        love.graphics.setLineWidth(4)

        love.graphics.setColor(
            1,
            1,
            0.3,
            1
        )

    else
        love.graphics.setLineWidth(
            outline.width or 1
        )

        love.graphics.setColor(
            outline.color.r or 1,
            outline.color.g or 1,
            outline.color.b or 1,
            outline.color.a or 1
        )
    end

    love.graphics.rectangle(
        "line",
        position.x,
        position.y,
        rectangle.width,
        rectangle.height,
        8,
        8
    )
end

local function drawButtonText(
    fonts,
    position,
    rectangle,
    button,
    isActive
)
    local font = fonts.button or fonts.normal 
    love.graphics.setFont(font)

    if isActive then
        love.graphics.setColor(
            1,
            1,
            1,
            1
        )
    else
        love.graphics.setColor(
            0.5,
            0.5,
            0.5,
            1
        )
    end

    local textY = position.y + (rectangle.height - font:getHeight()) / 2

    love.graphics.printf(
        button.text,
        position.x,
        textY,
        rectangle.width,
        "center"
    )
end

local function drawCanvasButtons(
    registry,
    fonts,
    canvas
)
    for entity,
        position,
        rectangle,
        color,
        uiElement,
        button
    in
        registry:each(
            "position",
            "rectangle",
            "color",
            "uiElement",
            "button"
        )
    do
        if uiElement.canvasId == canvas.id then 
            local isActive = button.active ~= false 
            local isSelected = isActive and canvas.interactive and canvas.selectedIndex == button.index

            drawButtonBackground(
                position,
                rectangle,
                color,
                isActive,
                isSelected
            )

            local outline =
                registry:get(
                    entity,
                    "outline"
                )

            drawButtonOutline(
                outline,
                position,
                rectangle,
                isActive,
                isSelected
            )

            drawButtonText(
                fonts,
                position,
                rectangle,
                button,
                isActive
            )
        end
    end
end

local function drawCanvas(
    registry,
    fonts,
    canvas
)
    drawCanvasBackground(canvas)

    drawCanvasTexts(
        registry,
        fonts,
        canvas.id
    )

    drawCanvasButtons(
        registry,
        fonts,
        canvas
    )
end

function UISystem.draw(scene)
    local registry = scene.registry

    local _, resources = registry:first("uiResources")

    if not resources then
        -- Debug
        print("Error: no se encontraron recursos UI")
        return
    end

    local activeCanvases = getActiveCanvases(registry)

    for _, entry in
        ipairs(activeCanvases)
    do
        drawCanvas(
            registry,
            resources.fonts,
            entry.canvas
        )
    end

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setLineWidth(1)
end

return UISystem