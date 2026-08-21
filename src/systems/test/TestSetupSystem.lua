local Canvas = require("src.ui.Canvas")

local TestSetupSystem = {}

TestSetupSystem.name = "TestSetupSystem"

local cardColors = {
    { r = 0.8, g = 0.25, b = 0.25 },
    { r = 0.25, g = 0.55, b = 0.9 },
    { r = 0.3, g = 0.75, b = 0.4 },
    { r = 0.8, g = 0.65, b = 0.2 },
    { r = 0.65, g = 0.35, b = 0.8 }
}

local cardTooltips = {
    {
        title = "Flirt",
        text = "Gain relationship progress with the girl."
    },
    {
        title = "Compliment",
        text = "A simple way to improve your relationship."
    },
    {
        title = "Defend",
        text = "Protect yourself from the rival's next sabotage."
    },
    {
        title = "Sabotage",
        text = "Interfere with the rival's progress."
    },
    {
        title = "Charm",
        text = "A stronger relationship action with a higher cost."
    }
}

local function createAvatar(registry, x, y, role)
    registry:spawn({
        position = {
            x = x,
            y = y
        },

        circle = {
            radius = 35
        },

        avatar = {
            role = role
        },

        color = {
            r = role == "player" and 0.3 or 0.9,
            g = role == "player" and 0.6 or 0.3,
            b = 0.9
        }
    })
end

local function createGirl(registry)
    registry:spawn({
        position = {
            x = 660,
            y = 270
        },

        triangle = {
            width = 70,
            height = 80
        },

        girl = {},

        color = {
            r = 0.95,
            g = 0.45,
            b = 0.65
        }
    })
end

local function createCards(registry)
    local cardWidth = 90
    local cardHeight = 120
    local gap = 15
    local startX = 125
    local y = 450

    for i = 1, 5 do
        registry:spawn({
            position = {
                x = startX + (i - 1) * (cardWidth + gap),
                y = y
            },

            rectangle = {
                width = cardWidth,
                height = cardHeight
            },

            card = {
                index = i,
                baseY = y,
                hovered = false,
                selected = false
            },

            tooltip = cardTooltips[i],

            color = cardColors[i]
        })
    end
end

function TestSetupSystem.setup(scene)
    local registry = scene.registry

    registry:setResource("testBattle", {
        selectedCard = nil,

        patience = {
            current = 80,
            max = 100
        },

        playerRelationship = {
            current = 35,
            max = 100
        },

        rivalRelationship = {
            current = 50,
            max = 100
        },

        energy = {
            current = 3,
            max = 3
        },

        deck = {
            current = 12
        }
    })

    createAvatar(
        registry,
        250,
        330,
        "player"
    )

    createAvatar(
        registry,
        250,
        140,
        "rival"
    )

    createGirl(registry)
    createCards(registry)

    Canvas.create(registry, {
        id = "testBattleUI",
        active = true,
        interactive = true,
        navigation = "vertical",
        selectedIndex = 1
    })
end

return TestSetupSystem