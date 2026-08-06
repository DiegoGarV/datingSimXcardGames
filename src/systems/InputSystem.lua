local Canvas = require("src.ui.Canvas")

local InputSystem = {}

InputSystem.runWhenCanvasBlocked = true

local function getCanvasButtons(
    registry,
    canvasId
)
    local buttons = {}

    for entity,
        position,
        rectangle,
        uiElement,
        button
    in
        registry:each(
            "position",
            "rectangle",
            "uiElement",
            "button"
        )
    do
        local belongsToCanvas = uiElement.canvasId == canvasId
        local isActive = button.active ~= false

        if belongsToCanvas and isActive then
            buttons[#buttons + 1] = {
                entity = entity,
                position = position,
                rectangle = rectangle,
                uiElement = uiElement,
                button = button,

                centerX =
                    position.x +
                    rectangle.width / 2,

                centerY =
                    position.y +
                    rectangle.height / 2
            }
        end
    end

    table.sort(
        buttons,
        function(a, b)
            return a.button.index < b.button.index
        end
    )

    return buttons
end

local function findSelectedButton(
    buttons,
    selectedIndex
)
    for _, entry in ipairs(buttons) do
        if entry.button.index == selectedIndex then
            return entry
        end
    end

    return nil
end

local function getDirection(
    navigation,
    key
)
    if navigation == "vertical" or navigation == "grid" then
        if key == "up" or key == "w" then
            return 0, -1
        end
        if key == "down" or key == "s" then
            return 0, 1
        end
    end

    if navigation == "horizontal" or navigation == "grid" then
        if key == "left" or key == "a" then
            return -1, 0
        end
        if key == "right" or key == "d" then
            return 1, 0
        end
    end

    return nil, nil
end

local function candidateScore(
    current,
    candidate,
    directionX,
    directionY
)
    local differenceX = candidate.centerX - current.centerX
    local differenceY = candidate.centerY - current.centerY
    local primaryDistance
    local secondaryDistance

    if directionX ~= 0 then
        if differenceX * directionX <= 0 then
            return nil
        end

        primaryDistance = math.abs(differenceX)
        secondaryDistance = math.abs(differenceY)
    else
        if differenceY * directionY <= 0 then
            return nil
        end

        primaryDistance = math.abs(differenceY)
        secondaryDistance = math.abs(differenceX)
    end

    return primaryDistance * 1000 + secondaryDistance
end

local function findWrappedButton(
    buttons,
    current,
    directionX,
    directionY
)
    local best = nil
    local bestScore = nil

    for _, candidate in ipairs(buttons) do
        if candidate ~= current then
            local primary
            local secondary

            if directionX > 0 then
                primary = candidate.centerX
                secondary = math.abs(candidate.centerY - current.centerY)

            elseif directionX < 0 then
                primary = -candidate.centerX
                secondary = math.abs(candidate.centerY - current.centerY)

            elseif directionY > 0 then
                primary = candidate.centerY
                secondary = math.abs(candidate.centerX - current.centerX)

            else
                primary = -candidate.centerY
                secondary = math.abs(candidate.centerX - current.centerX)
            end

            local score = primary * 1000 + secondary

            if not bestScore or score < bestScore then
                best = candidate
                bestScore = score
            end
        end
    end

    return best
end

local function ensureValidSelection(
    registry,
    canvas
)
    local buttons =
        getCanvasButtons(
            registry,
            canvas.id
        )

    if #buttons == 0 then
        return nil
    end

    local current =
        findSelectedButton(
            buttons,
            canvas.selectedIndex
        )

    if current then
        return current
    end

    canvas.selectedIndex = buttons[1].button.index

    return buttons[1]
end

local function moveCanvasSelection(
    registry,
    canvas,
    key
)
    local directionX, directionY =
        getDirection(
            canvas.navigation,
            key
        )

    if not directionX then
        return
    end

    local buttons =
        getCanvasButtons(
            registry,
            canvas.id
        )

    if #buttons == 0 then
        return
    end

    local current =
        findSelectedButton(
            buttons,
            canvas.selectedIndex
        )

    if not current then
        canvas.selectedIndex = buttons[1].button.index

        return
    end

    local best = nil
    local bestScore = nil

    for _, candidate in ipairs(buttons) do
        if candidate ~= current then
            local score =
                candidateScore(
                    current,
                    candidate,
                    directionX,
                    directionY
                )

            if score and (not bestScore or score < bestScore) then
                best = candidate
                bestScore = score
            end
        end
    end

    if not best then
        best = findWrappedButton(
            buttons,
            current,
            directionX,
            directionY
        )
    end

    if best then
        canvas.selectedIndex =
            best.button.index
    end
end

local function activateSelectedButton(
    registry,
    canvas
)
    local selected =
        ensureValidSelection(
            registry,
            canvas
        )

    if not selected then
        return
    end

    registry:spawn({
        buttonPressed = {
            buttonEntity = selected.entity,
            canvasId = selected.uiElement.canvasId,
            action = selected.button.action,
            index = selected.button.index
        }
    })
end

local function processKeyPressed(
    registry,
    canvas,
    key
)
    if not canvas then
        return
    end

    if key == "return" or key == "kpenter" then
        activateSelectedButton(
            registry,
            canvas
        )
        return
    end

    moveCanvasSelection(
        registry,
        canvas,
        key
    )
end

function InputSystem.setup(scene)
    local registry = scene.registry

    local _, input = registry:first("input")

    if input then
        return
    end

    registry:spawn({
        input = {}
    })
end

function InputSystem.update(scene, dt)
    local registry = scene.registry

    local activeCanvas =
        Canvas.getActiveInteractive(
            registry
        )

    local events = registry:query("keyPressed")

    for _, eventEntity in ipairs(events) do
        local keyPressed =
            registry:get(
                eventEntity,
                "keyPressed"
            )

        if keyPressed then
            processKeyPressed(
                registry,
                activeCanvas,
                keyPressed.key
            )
        end

        registry:destroy(eventEntity)
    end
end

return InputSystem