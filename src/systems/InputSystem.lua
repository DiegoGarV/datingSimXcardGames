local Canvas = require("src.ui.Canvas")

local InputSystem = {}

InputSystem.name = "InputSystem"
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

local function findSelectedButton(buttons, selectedIndex)
    for _, entry in ipairs(buttons) do
        if entry.button.index == selectedIndex then
            return entry
        end
    end

    return nil
end

local function findButtonAtPosition(buttons, x, y)
    for _, entry in ipairs(buttons) do
        local position = entry.position
        local rectangle = entry.rectangle

        local inside =
            x >= position.x
            and x <= position.x + rectangle.width
            and y >= position.y
            and y <= position.y + rectangle.height

        if inside then
            return entry
        end
    end

    return nil
end

local function getDirection(navigation, key)
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

local function ensureValidSelection(registry, canvas)
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

local function moveCanvasSelection(registry, canvas, key)
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

local function activateButton(registry, entry)
    if not entry then
        return
    end

    registry:spawn({
        buttonPressed = {
            buttonEntity = entry.entity,
            canvasId = entry.uiElement.canvasId,
            action = entry.button.action,
            index = entry.button.index
        }
    })
end

local function activateSelectedButton(registry, canvas)
    local selected =
        ensureValidSelection(
            registry,
            canvas
        )

    activateButton(
        registry,
        selected
    )
end

local function processKeyPressed(registry, canvas, key)
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

local function processMousePressed(
    registry,
    canvas,
    input, 
    event
)
    input.mouse.x = event.x
    input.mouse.y = event.y
    input.mouse.buttons[event.button] = true

    if not canvas or event.button ~= 1 then
        return
    end

    local buttons = getCanvasButtons(
        registry,
        canvas.id
    )

    local clicked = findButtonAtPosition(
        buttons,
        event.x,
        event.y
    )

    if not clicked then
        return
    end

    canvas.selectedIndex = clicked.button.index

    activateButton(
        registry,
        clicked
    )
end

local function processMouseReleased(input, event)
    input.mouse.x = event.x
    input.mouse.y = event.y
    input.mouse.buttons[event.button] = false
end

local function processMouseMoved(
    registry,
    canvas,
    input,
    event
)
    input.mouse.x = event.x
    input.mouse.y = event.y
    input.mouse.dx = input.mouse.dx + event.dx
    input.mouse.dy = input.mouse.dy + event.dy

    if not canvas then
        return
    end

    canvas.selectedIndex = nil

    local buttons = getCanvasButtons(
        registry,
        canvas.id
    )

    local hovered = findButtonAtPosition(
        buttons,
        event.x,
        event.y
    )

    if hovered then
        canvas.selectedIndex = hovered.button.index
    end
end

function InputSystem.setup(scene)
    local registry = scene.registry

    local _, input = registry:first("input")

    if input then
        return
    end

    registry:spawn({
        input = {
            mouse = {
                x = 0,
                y = 0,

                dx = 0,
                dy = 0,

                buttons = {}
            }
        }
    })
end

function InputSystem.update(scene, dt)
    local registry = scene.registry
    local activeCanvas = Canvas.getActiveInteractive(registry)
    local _, input = registry:first("input")

    if not input then
        return
    end

    input.mouse.dx = 0
    input.mouse.dy = 0

    for _, eventEntity in ipairs(registry:query("keyPressed")) do
        local keyPressed = registry:get(eventEntity, "keyPressed")

        if keyPressed then
            processKeyPressed(
                registry,
                activeCanvas,
                keyPressed.key
            )
        end
    end

    for _, eventEntity in ipairs(registry:query("mousePressed")) do
        local mousePressed = registry:get(eventEntity, "mousePressed")

        if mousePressed then
            processMousePressed(
                registry,
                activeCanvas,
                input,
                mousePressed
            )
        end
    end

    for _, eventEntity in ipairs(registry:query("mouseReleased")) do
        local mouseReleased = registry:get(eventEntity, "mouseReleased")

        if mouseReleased then
            processMouseReleased(
                input,
                mouseReleased
            )
        end
    end

    for _, eventEntity in ipairs(registry:query("mouseMoved")) do
        local mouseMoved = registry:get(eventEntity, "mouseMoved")

        if mouseMoved then
            processMouseMoved(
                registry,
                activeCanvas,
                input,
                mouseMoved
            )
        end
    end
end

return InputSystem