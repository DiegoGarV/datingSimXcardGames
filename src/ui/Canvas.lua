local GameConfig = require("src.GameConfig")

local Canvas = {}

function Canvas.create(registry, options)
    options = options or {}

    return registry:spawn({
        canvas = {
            id = options.id,
            active = options.active == true,
            blocksGameplay = options.blocksGameplay == true,
            interactive = options.interactive == true,
            navigation = options.navigation or "vertical",
            selectedIndex = options.selectedIndex or 1,
            priority = options.priority or 0,
            dim = options.dim or 0
        }
    })
end

function Canvas.createText(registry, options)
    options = options or {}

    return registry:spawn({
        position = {
            x = options.x or 0,
            y = options.y or 0
        },

        color = options.color or {
            r = 1,
            g = 1,
            b = 1
        },

        uiElement = {
            canvasId = options.canvasId,
            scrollAreaId = options.scrollAreaId
        },

        uiText = {
            id = options.id,
            value = options.value or "",
            font = options.font or "normal",
            width = options.width or GameConfig.width,
            align = options.align or "left"
        }
    })
end

function Canvas.createButton(registry, options)
    options = options or {}

    return registry:spawn({
        position = {
            x = options.x or 0,
            y = options.y or 0
        },

        rectangle = {
            width = options.width or 0,
            height = options.height or 0
        },

        color = options.color or {
            r = 0.2,
            g = 0.4,
            b = 0.8
        },

        outline = {
            width = options.outlineWidth or 2,

            color = options.outlineColor or {
                r = 1,
                g = 1,
                b = 1
            }
        },

        uiElement = {
            canvasId = options.canvasId,
            scrollAreaId = options.scrollAreaId
        },

        button = {
            text = options.text or "",
            action = options.action,
            index = options.index,
            active = options.active ~= false,
            font = options.font or "button"
        }
    })
end

function Canvas.createPanel(registry, options)
    options = options or {}

    return registry:spawn({
        position = {
            x = options.x or 0,
            y = options.y or 0
        },

        rectangle = {
            width = options.width or 0,
            height = options.height or 0
        },

        color = options.color or {
            r = 0.2,
            g = 0.2,
            b = 0.25
        },

        outline = {
            width = options.outlineWidth or 2,

            color = options.outlineColor or {
                r = 1,
                g = 1,
                b = 1
            }
        },

        uiElement = {
            canvasId = options.canvasId,
            scrollAreaId = options.scrollAreaId
        },

        panel = {}
    })
end

function Canvas.createCircle(registry, options)
    options = options or {}

    return registry:spawn({
        position = {
            x = options.x or 0,
            y = options.y or 0
        },

        circle = {
            radius = options.radius or 20
        },

        color = options.color or {
            r = 1,
            g = 0.5,
            b = 0.2
        },

        uiElement = {
            canvasId = options.canvasId,
            scrollAreaId = options.scrollAreaId
        },

        uiCircle = {
            id = options.id
        }
    })
end

function Canvas.createScrollArea(
    registry,
    options
)
    options = options or {}

    local height =
        options.height or 0

    local contentHeight =
        options.contentHeight
        or height

    return registry:spawn({
        uiElement = {
            canvasId =
                options.canvasId
        },

        scrollArea = {
            id = options.id,

            x = options.x or 0,
            y = options.y or 0,

            width =
                options.width or 0,

            height = height,

            contentHeight =
                contentHeight,

            offsetY = 0,

            maxOffsetY =
                math.max(
                    0,
                    contentHeight - height
                ),

            step =
                options.step or 70
        }
    })
end

function Canvas.get(registry, canvasId)
    for entity, canvas in
        registry:each("canvas")
    do
        if canvas.id == canvasId then
            return entity, canvas
        end
    end

    return nil, nil
end

function Canvas.show(registry, canvasId)
    local _, canvas =
        Canvas.get(registry, canvasId)

    if canvas then
        canvas.active = true
    end
end

function Canvas.hide(registry, canvasId)
    local _, canvas =
        Canvas.get(registry, canvasId)

    if canvas then
        canvas.active = false
    end
end

function Canvas.isActive(registry, canvasId)
    local _, canvas =
        Canvas.get(registry, canvasId)

    return canvas and canvas.active
end

function Canvas.blocksGameplay(registry)
    for _, canvas in
        registry:each("canvas")
    do
        if canvas.active
            and canvas.blocksGameplay then

            return true
        end
    end

    return false
end

function Canvas.getActiveInteractive(registry)
    local selectedCanvas = nil

    for _, canvas in
        registry:each("canvas")
    do
        if canvas.active
            and canvas.interactive then

            if not selectedCanvas
                or canvas.priority >
                    selectedCanvas.priority then

                selectedCanvas = canvas
            end
        end
    end

    return selectedCanvas
end

function Canvas.setText(
    registry,
    textId,
    value,
    color
)
    for _, text, textColor in
        registry:each(
            "uiText",
            "color"
        )
    do
        if text.id == textId then
            text.value = value

            if color then
                textColor.r = color.r
                textColor.g = color.g
                textColor.b = color.b
            end

            return
        end
    end
end

function Canvas.getScrollArea(
    registry,
    scrollAreaId
)
    for entity, area in
        registry:each("scrollArea")
    do
        if area.id
            == scrollAreaId
        then
            return entity, area
        end
    end

    return nil, nil
end

function Canvas.scroll(
    registry,
    scrollAreaId,
    direction
)
    local _, area =
        Canvas.getScrollArea(
            registry,
            scrollAreaId
        )

    if not area then
        return
    end

    local oldOffset =
        area.offsetY

    local newOffset =
        oldOffset
        - direction * area.step

    newOffset =
        math.max(
            0,
            math.min(
                newOffset,
                area.maxOffsetY
            )
        )

    local delta =
        newOffset - oldOffset

    if delta == 0 then
        return
    end

    area.offsetY =
        newOffset

    for _,
        position,
        uiElement
    in
        registry:each(
            "position",
            "uiElement"
        )
    do
        if uiElement.scrollAreaId
            == scrollAreaId
        then
            position.y =
                position.y - delta
        end
    end
end

function Canvas.resetScrollArea(
    registry,
    scrollAreaId
)
    local _, area =
        Canvas.getScrollArea(
            registry,
            scrollAreaId
        )

    if not area then
        return
    end

    local offset =
        area.offsetY

    if offset == 0 then
        return
    end

    for _,
        position,
        uiElement
    in
        registry:each(
            "position",
            "uiElement"
        )
    do
        if uiElement.scrollAreaId
            == scrollAreaId
        then
            position.y =
                position.y + offset
        end
    end

    area.offsetY = 0
end

function Canvas.isPointInsideScrollArea(
    registry,
    scrollAreaId,
    x,
    y
)
    local _, area =
        Canvas.getScrollArea(
            registry,
            scrollAreaId
        )

    if not area then
        return false
    end

    return
        x >= area.x
        and x <=
            area.x + area.width
        and y >= area.y
        and y <=
            area.y + area.height
end

return Canvas