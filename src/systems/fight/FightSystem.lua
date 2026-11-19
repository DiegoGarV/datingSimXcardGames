local HitTest = require("src.ui.HitTest")

local FightSystem = {}

FightSystem.name = "FightSystem"

local HOVER_OFFSET = 25

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
        card.hovered = HitTest.rectangle(
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
        if HitTest.rectangle(
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
            registry:add(entity, "fightAnimation", {
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

local function startVictory(registry, battle)
    if battle.victoryPending then
        return
    end

    battle.victoryPending = true
    battle.victoryTimer = 2

    local _, playButton = getPlayButton(registry)

    if playButton then
        playButton.active = false
    end
end

local function playSelectedCard(registry, battle)
    if not battle.selectedCard then
        return
    end

    local battleState = registry:resource("fightState")

    if battleState then
        battleState.energy.current =
            math.max(
                0,
                battleState.energy.current - 1
            )

        battleState.playerRelationship.current =
            math.min(
                battleState.playerRelationship.max,
                battleState.playerRelationship.current + 5
            )
        
        if battleState.playerRelationship.current
            >= battleState.playerRelationship.max
        then
            startVictory(
                registry,
                battleState
            )
        end

        battleState.patience.current =
            math.max(
                0,
                battleState.patience.current - 2
            )
    end

    startPlayerAnimation(registry)
end

function FightSystem.update(scene, dt)
    local registry = scene.registry
    local input = registry:resource("input")
    local battle = registry:resource("fightState")

    if not input or not battle then
        return
    end

    if battle.victoryPending then
        battle.victoryTimer =
            battle.victoryTimer - dt

        if battle.victoryTimer <= 0 then
            local gameState =
                registry:resource("gameState")

            if gameState then
                gameState.run.development.actionsRemaining = 2

                registry:spawn({
                    sceneChangeRequest = {
                        target = "development",

                        payload = {
                            gameState = gameState
                        }
                    }
                })
            end
        end

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

return FightSystem