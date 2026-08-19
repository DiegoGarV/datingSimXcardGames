local TestBattleSystem = {}

TestBattleSystem.name = "TestBattleSystem"

local HOVER_OFFSET = 25

local function isInsideCard(position, rectangle, x, y)
    return x >= position.x
        and x <= position.x + rectangle.width
        and y >= position.y
        and y <= position.y + rectangle.height
end

local function getPlayButton(registry)
    for entity, button in registry:each("button") do
        if button.action == "playCard" then
            return entity, button
        end
    end

    return nil, nil
end

local function updateCardHover(registry, mouseX, mouseY)
    for _, position, rectangle, card in registry:each(
        "position",
        "rectangle",
        "card"
    ) do
        card.hovered = isInsideCard(
            position,
            rectangle,
            mouseX,
            mouseY
        )

        if card.selected or card.hovered then
            position.y = card.baseY - HOVER_OFFSET
        else
            position.y = card.baseY
        end
    end
end

local function selectCard(registry, battle, x, y)
    local selected = nil

    for entity, position, rectangle, card in registry:each(
        "position",
        "rectangle",
        "card"
    ) do
        if isInsideCard(
            position,
            rectangle,
            x,
            y
        ) then
            selected = entity
            break
        end
    end

    if not selected then
        return
    end

    battle.selectedCard = selected

    for entity, position, _, card in registry:each(
        "position",
        "rectangle",
        "card"
    ) do
        card.selected = entity == selected

        if card.selected or card.hovered then
            position.y = card.baseY - HOVER_OFFSET
        else
            position.y = card.baseY
        end
    end

    local _, playButton = getPlayButton(registry)

    if playButton then
        playButton.active = true
    end
end

local function startPlayerAnimation(registry)
    for entity, position, avatar in registry:each(
        "position",
        "avatar"
    ) do
        if avatar.role == "player" then
            registry:add(entity, "testAnimation", {
                startX = position.x,
                startY = position.y,
                targetX = position.x + 80,
                targetY = position.y - 20,

                progress = 0,
                duration = 0.25,
                returning = false
            })

            return
        end
    end
end

local function playSelectedCard(registry, battle)
    if not battle.selectedCard then
        return
    end

    startPlayerAnimation(registry)
end

function TestBattleSystem.update(scene, dt)
    local registry = scene.registry
    local input = registry:resource("input")
    local battle = registry:resource("testBattle")

    if not input or not battle then
        return
    end

    updateCardHover(
        registry,
        input.mouse.x,
        input.mouse.y
    )

    for _, eventEntity in ipairs(
        registry:query("mousePressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "mousePressed"
            )

        if event and event.button == 1 then
            selectCard(
                registry,
                battle,
                event.x,
                event.y
            )
        end
    end

    for _, eventEntity in ipairs(
        registry:query("buttonPressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "buttonPressed"
            )

        if event and event.action == "playCard" then
            playSelectedCard(
                registry,
                battle
            )

            registry:destroy(eventEntity)
        end
    end
end

return TestBattleSystem