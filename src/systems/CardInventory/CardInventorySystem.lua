local Canvas = require("src.ui.Canvas")
local CardDefinitions = require("src.data.CardDefinitions")

local CardInventorySystem = {}

CardInventorySystem.name = "CardInventorySystem"

CardInventorySystem.runWhenCanvasBlocked = true

local CATEGORY_ORDER = {
    conquest = 1,
    attack = 2,
    protection = 3
}

local RARITY_ORDER = {
    common = 1,
    uncommon = 2,
    rare = 3
}

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

local function getCardPosition(
    state,
    index
)
    local layout =
        state.layout

    local zeroIndex =
        index - 1

    local column =
        zeroIndex % layout.columns

    local row =
        math.floor(
            zeroIndex
            / layout.columns
        )

    local x =
        layout.startX
        + column
        * (
            layout.cardWidth
            + layout.gapX
        )

    local y =
        layout.startY
        + row
        * (
            layout.cardHeight
            + layout.gapY
        )

    return x, y
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

local function getSortValue(
    card,
    mode
)
    if mode == "category" then
        return
            CATEGORY_ORDER[
                card.category
            ] or 999

    elseif mode == "rarity" then
        return
            RARITY_ORDER[
                card.rarity
            ] or 999

    elseif mode == "cost" then
        return card.cost or 0

    elseif mode == "name" then
        return string.lower(
            card.name
        )
    end

    return 0
end

local function compareCards(
    a,
    b,
    state
)
    local mode = state.sortMode

    local valueA =
        getSortValue(
            a.card,
            mode
        )

    local valueB =
        getSortValue(
            b.card,
            mode
        )

    if valueA ~= valueB then
        if state.sortAscending then
            return valueA < valueB
        else
            return valueA > valueB
        end
    end

    local nameA =
        string.lower(
            a.card.name
        )

    local nameB =
        string.lower(
            b.card.name
        )

    if nameA ~= nameB then
        if state.sortAscending then
            return nameA < nameB
        else
            return nameA > nameB
        end
    end

    if state.sortAscending then
        return
            a.inventoryCard.deckIndex
            < b.inventoryCard.deckIndex
    else
        return
            a.inventoryCard.deckIndex
            > b.inventoryCard.deckIndex
    end
end

local function sortCards(
    registry,
    state
)
    local cards = {}

    for entity,
        position,
        button,
        inventoryCard
    in
        registry:each(
            "position",
            "button",
            "inventoryCard"
        )
    do
        local definition =
            CardDefinitions.get(
                inventoryCard.cardId
            )

        if definition then
            cards[#cards + 1] = {
                entity = entity,
                position = position,
                button = button,
                inventoryCard =
                    inventoryCard,
                card = definition
            }
        end
    end

    table.sort(
        cards,
        function(a, b)
            return compareCards(
                a,
                b,
                state
            )
        end
    )

    Canvas.resetScrollArea(
        registry,
        "inventoryCards"
    )

    for index, entry in
        ipairs(cards)
    do
        local x, y =
            getCardPosition(
                state,
                index
            )

        entry.position.x = x
        entry.position.y = y

        entry.button.index =
            index

        entry.inventoryCard.displayIndex =
            index
    end

    local _, canvas =
        Canvas.get(
            registry,
            "cardInventory"
        )

    if canvas then
        canvas.selectedIndex =
            #cards > 0
            and 1
            or nil
    end
end

local function updateSortButtons(
    registry,
    state
)
    local modes = {
        sortCategory = "category",
        sortName = "name",
        sortRarity = "rarity",
        sortCost = "cost"
    }

    local labels = {
        sortCategory = "Category",
        sortName = "Name",
        sortRarity = "Rarity",
        sortCost = "Cost"
    }

    for _,
        uiElement,
        button
    in
        registry:each(
            "uiElement",
            "button"
        )
    do
        if uiElement.canvasId
            == "inventorySort"
        then
            local mode =
                modes[
                    button.action
                ]

            if mode then
                if mode
                    == state.sortMode
                then
                    local arrow =
                        state.sortAscending
                        and " [asc] "
                        or " [desc] "

                    button.text =
                        "> "
                        .. labels[
                            button.action
                        ]
                        .. arrow
                else
                    button.text =
                        labels[
                            button.action
                        ]
                end
            end
        end
    end
end

local function openSort(
    registry,
    state
)
    updateSortButtons(
        registry,
        state
    )

    local indexes = {
        category = 1,
        name = 2,
        rarity = 3,
        cost = 4
    }

    local _, canvas =
        Canvas.get(
            registry,
            "inventorySort"
        )

    if canvas then
        canvas.selectedIndex =
            indexes[state.sortMode]
            or 1
    end

    Canvas.show(
        registry,
        "inventorySort"
    )
end

local function selectSortMode(
    registry,
    state,
    mode
)
    if state.sortMode == mode then
        state.sortAscending =
            not state.sortAscending
    else
        state.sortMode = mode
        state.sortAscending = true
    end

    sortCards(
        registry,
        state
    )

    updateSortButtons(
        registry,
        state
    )

    Canvas.hide(
        registry,
        "inventorySort"
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
        openSort(
            registry,
            state
        )

    elseif event.action
    == "exitInventory"
    then
        local gameState =
            registry:resource(
                "gameState"
            )

        if not gameState then
            return
        end

        registry:spawn({
            sceneChangeRequest = {
                target = "roadmap",

                payload = {
                    gameState =
                        gameState
                }
            }
        })
    end
end

local function processSortAction(
    registry,
    action,
    state
)
    if action == "sortCategory" then
        selectSortMode(
            registry,
            state,
            "category"
        )

    elseif action == "sortName" then
        selectSortMode(
            registry,
            state,
            "name"
        )

    elseif action == "sortRarity" then
        selectSortMode(
            registry,
            state,
            "rarity"
        )

    elseif action == "sortCost" then
        selectSortMode(
            registry,
            state,
            "cost"
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

    if Canvas.isActive(
        registry,
        "inventorySort"
    ) then
        for _, eventEntity in ipairs(
            registry:query("mousePressed")
        ) do
            local event =
                registry:get(
                    eventEntity,
                    "mousePressed"
                )

            if event
                and event.button == 1
            then
                local insidePanel =
                    event.x >= 560
                    and event.x <= 755
                    and event.y >= 95
                    and event.y <= 355

                if not insidePanel then
                    Canvas.hide(
                        registry,
                        "inventorySort"
                    )

                    registry:destroy(
                        eventEntity
                    )

                    return
                end
            end
        end
    end

    if not state then
        return
    end

    if state.needsSort then
        sortCards(
            registry,
            state
        )

        state.needsSort = false
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
                "inventorySort"
            )
        then
            Canvas.hide(
                registry,
                "inventorySort"
            )

            registry:destroy(
                eventEntity
            )

            return
        end

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
        elseif event.canvasId
            == "inventorySort"
        then
            processSortAction(
                registry,
                event.action,
                state
            )

            registry:destroy(
                eventEntity
            )
        end
    end
end

return CardInventorySystem