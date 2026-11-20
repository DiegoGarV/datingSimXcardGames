local Canvas = require("src.ui.Canvas")
local CardDefinitions = require("src.data.CardDefinitions")

local CardInventorySystem = {}

CardInventorySystem.name = "CardInventorySystem"

CardInventorySystem.runWhenCanvasBlocked = true

local function showCardDetails(
    registry,
    cardId
)
    local card =
        CardDefinitions.get(cardId)

    if not card then
        return
    end

    Canvas.setText(
        registry,
        "inventoryDetailName",
        card.name
    )

    Canvas.setText(
        registry,
        "inventoryDetailCategory",
        "Category: "
            .. card.category
    )

    Canvas.setText(
        registry,
        "inventoryDetailRarity",
        "Rarity: "
            .. card.rarity
    )

    Canvas.setText(
        registry,
        "inventoryDetailCost",
        "Cost: "
            .. tostring(card.cost)
    )

    Canvas.setText(
        registry,
        "inventoryDetailEffect",
        "Effect: "
            .. card.effect
    )

    Canvas.show(
        registry,
        "cardDetails"
    )
end

local function hideCardDetails(
    registry,
    state
)
    Canvas.hide(
        registry,
        "cardDetails"
    )

    state.selectedCardId = nil
end

local function selectCard(
    registry,
    entity,
    state
)
    local inventoryCard =
        registry:get(
            entity,
            "inventoryCard"
        )

    if not inventoryCard then
        return
    end

    state.selectedCardId =
        inventoryCard.cardId

    showCardDetails(
        registry,
        inventoryCard.cardId
    )
end

local function processAction(
    registry,
    event,
    state
)
    if event.action
        == "selectInventoryCard"
    then
        selectCard(
            registry,
            event.buttonEntity,
            state
        )

    elseif event.action
        == "openSort"
    then
        print(
            "Sort menu will be implemented next."
        )

    elseif event.action
        == "exitInventory"
    then
        print(
            "Roadmap Scene will be implemented later."
        )
    end
end

function CardInventorySystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    local state =
        registry:resource(
            "cardInventoryState"
        )

    if Canvas.isActive(
        registry,
        "cardDetails"
    ) then
        for _, eventEntity in ipairs(
            registry:query("mousePressed")
        ) do
            local event =
                registry:get(
                    eventEntity,
                    "mousePressed"
                )

            if event and event.button == 1 then
                hideCardDetails(
                    registry,
                    state
                )

                registry:destroy(
                    eventEntity
                )

                return
            end
        end
    end

    if not state then
        return
    end

    for _, eventEntity in ipairs(
        registry:query("keyPressed")
    ) do
        local event =
            registry:get(
                eventEntity,
                "keyPressed"
            )

        if event
            and event.key == "escape"
            and Canvas.isActive(
                registry,
                "cardDetails"
            )
        then
            hideCardDetails(
                registry,
                state
            )

            registry:destroy(
                eventEntity
            )

            return
        end
    end

    local detailsOpen =
        Canvas.isActive(
            registry,
            "cardDetails"
        )

    local pauseOpen =
        Canvas.isActive(
            registry,
            "pauseMenu"
        )

    local input =
        registry:resource("input")

    if not detailsOpen
        and not pauseOpen
        and input
    then
        for _, eventEntity in ipairs(
            registry:query("wheelMoved")
        ) do
            local event =
                registry:get(
                    eventEntity,
                    "wheelMoved"
                )

            if event
                and event.y ~= 0
                and Canvas.isPointInsideScrollArea(
                    registry,
                    "inventoryCards",
                    input.mouse.x,
                    input.mouse.y
                )
            then
                Canvas.scroll(
                    registry,
                    "inventoryCards",
                    event.y
                )
            end
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

        if event
            and event.canvasId
                == "cardInventory"
        then
            processAction(
                registry,
                event,
                state
            )

            registry:destroy(
                eventEntity
            )
        end
    end
end

return CardInventorySystem