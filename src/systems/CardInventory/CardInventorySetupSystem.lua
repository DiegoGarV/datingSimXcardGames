local Canvas = require("src.ui.Canvas")
local CardDefinitions = require("src.data.CardDefinitions")

local CardInventorySetupSystem = {}

CardInventorySetupSystem.name =
    "CardInventorySetupSystem"

local CARD_WIDTH = 140
local CARD_HEIGHT = 185

local START_X = 55
local START_Y = 140

local GAP_X = 35
local GAP_Y = 30

local COLUMNS = 4

local SCROLL_X = 40
local SCROLL_Y = 120
local SCROLL_WIDTH = 720
local SCROLL_HEIGHT = 430

local categoryColors = {
    conquest = {
        r = 0.75,
        g = 0.3,
        b = 0.45
    },

    attack = {
        r = 0.75,
        g = 0.25,
        b = 0.25
    },

    protection = {
        r = 0.25,
        g = 0.5,
        b = 0.8
    }
}

local function getCardPosition(index)
    local zeroIndex =
        index - 1

    local column =
        zeroIndex % COLUMNS

    local row =
        math.floor(
            zeroIndex / COLUMNS
        )

    local x =
        START_X
        + column
        * (CARD_WIDTH + GAP_X)

    local y =
        START_Y
        + row
        * (CARD_HEIGHT + GAP_Y)

    return x, y
end

local function createInventoryCard(
    registry,
    cardId,
    index
)
    local card =
        CardDefinitions.get(cardId)

    if not card then
        return
    end

    local x, y =
        getCardPosition(index)

    local color =
        categoryColors[card.category]

    local entity =
        Canvas.createButton(
            registry,
            {
                canvasId = "cardInventory",
                scrollAreaId = "inventoryCards",

                x = x,
                y = y,

                width = CARD_WIDTH,
                height = CARD_HEIGHT,

                text = card.name,
                font = "small",

                action = "selectInventoryCard",
                index = index,

                color = {
                    r = color.r,
                    g = color.g,
                    b = color.b
                }
            }
        )

    registry:add(
        entity,
        "inventoryCard",
        {
            cardId = cardId,
            deckIndex = index
        }
    )
end

local function createDetailsPanel(registry)
    Canvas.create(
        registry,
        {
            id = "cardDetails",
            active = false,
            interactive = true,
            blocksGameplay = true,
            priority = 20,
            dim = 0.35
        }
    )

    Canvas.createPanel(
        registry,
        {
            canvasId = "cardDetails",

            x = 170,
            y = 130,

            width = 460,
            height = 330,

            color = {
                r = 0.12,
                g = 0.12,
                b = 0.16
            }
        }
    )

    Canvas.createText(
        registry,
        {
            id = "inventoryDetailName",
            canvasId = "cardDetails",

            x = 200,
            y = 160,
            width = 400,

            value = "",
            font = "normal",
            align = "center"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "inventoryDetailCategory",
            canvasId = "cardDetails",

            x = 215,
            y = 220,
            width = 370,

            value = "",
            font = "small",
            align = "left"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "inventoryDetailRarity",
            canvasId = "cardDetails",

            x = 215,
            y = 255,
            width = 370,

            value = "",
            font = "small",
            align = "left"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "inventoryDetailCost",
            canvasId = "cardDetails",

            x = 215,
            y = 290,
            width = 370,

            value = "",
            font = "small",
            align = "left"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "inventoryDetailEffect",
            canvasId = "cardDetails",

            x = 215,
            y = 340,
            width = 370,

            value = "",
            font = "small",
            align = "left"
        }
    )
end

local function createSortPanel(registry)
    Canvas.create(
        registry,
        {
            id = "inventorySort",
            active = false,
            interactive = true,
            blocksGameplay = true,
            navigation = "vertical",
            selectedIndex = 1,
            priority = 25,
            dim = 0
        }
    )

    Canvas.createPanel(
        registry,
        {
            canvasId = "inventorySort",

            x = 560,
            y = 95,

            width = 225,
            height = 260,

            color = {
                r = 0.12,
                g = 0.12,
                b = 0.16
            }
        }
    )

    Canvas.createText(
        registry,
        {
            id = "sortTitle",
            canvasId = "inventorySort",

            x = 575,
            y = 110,
            width = 165,

            value = "SORT BY",
            font = "small",
            align = "center"
        }
    )

    local options = {
        {
            text = "Category",
            action = "sortCategory"
        },
        {
            text = "Name",
            action = "sortName"
        },
        {
            text = "Rarity",
            action = "sortRarity"
        },
        {
            text = "Cost",
            action = "sortCost"
        }
    }

    for index, option in ipairs(options) do
        Canvas.createButton(
            registry,
            {
                canvasId = "inventorySort",

                x = 580,
                y = 145 + (index - 1) * 48,

                width = 187,
                height = 38,

                text = option.text,
                font = "small",

                action = option.action,
                index = index
            }
        )
    end
end

function CardInventorySetupSystem.setup(scene)
    local registry =
        scene.registry

    local gameState =
        registry:resource("gameState")

    if not gameState then
        return
    end

    local cardCount =
        #gameState.run.deck

    local rows =
        math.ceil(
            cardCount / COLUMNS
        )

    local contentHeight = 0

    if rows > 0 then
        contentHeight =
            (START_Y - SCROLL_Y)
            + rows * CARD_HEIGHT
            + math.max(
                0,
                rows - 1
            ) * GAP_Y
            + 20
    end

    registry:setResource(
        "cardInventoryState",
        {
            selectedCardId = nil,
            sortMode = "category",
            sortAscending = true,
            needsSort = true,

            layout = {
                startX = START_X,
                startY = START_Y,
                cardWidth = CARD_WIDTH,
                cardHeight = CARD_HEIGHT,
                gapX = GAP_X,
                gapY = GAP_Y,
                columns = COLUMNS
            }
        }
    )

    Canvas.create(
        registry,
        {
            id = "cardInventory",
            active = true,
            interactive = true,
            blocksGameplay = false,
            navigation = "grid",
            selectedIndex = 1,
            priority = 10,
            dim = 0
        }
    )

    Canvas.createScrollArea(
        registry,
        {
            id = "inventoryCards",
            canvasId = "cardInventory",

            x = SCROLL_X,
            y = SCROLL_Y,

            width = SCROLL_WIDTH,
            height = SCROLL_HEIGHT,

            contentHeight =
                contentHeight,

            step = 70
        }
    )

    Canvas.createText(
        registry,
        {
            id = "cardInventoryTitle",
            canvasId = "cardInventory",

            x = 40,
            y = 35,
            width = 500,

            value = "CARD INVENTORY",
            font = "title",
            align = "left"
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "cardInventory",

            x = 600,
            y = 40,

            width = 80,
            height = 45,

            text = "Sort",
            font = "small",

            action = "openSort",
            index = 1001,
            active = true
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "cardInventory",

            x = 695,
            y = 40,

            width = 60,
            height = 45,

            text = "X",
            font = "small",

            action = "exitInventory",
            index = 1002,
            active = true
        }
    )

    for index, cardId in ipairs(
        gameState.run.deck
    ) do
        createInventoryCard(
            registry,
            cardId,
            index
        )
    end

    createDetailsPanel(registry)
    createSortPanel(registry)
end

return CardInventorySetupSystem