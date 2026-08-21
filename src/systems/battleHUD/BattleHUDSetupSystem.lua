local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")

local BattleHUDSetupSystem = {}

BattleHUDSetupSystem.name = "BattleHUDSetupSystem"

local function createBar(
    registry,
    id,
    label,
    x,
    y,
    fillColor,
    labelFont,
    barFont
)
    local barWidth = 220
    local barHeight = 24

    Canvas.createText(registry, {
        id = id .. "Label",
        canvasId = "battleHUD",
        x = x,
        y = y,
        width = 280,
        value = label,
        font = labelFont or "normal",
        align = "left"
    })

    Canvas.createPanel(registry, {
        canvasId = "battleHUD",
        x = x,
        y = y + 30,
        width = barWidth,
        height = barHeight,

        color = {
            r = 0.15,
            g = 0.15,
            b = 0.18
        }
    })

    local fillEntity = Canvas.createPanel(registry, {
        canvasId = "battleHUD",
        x = x,
        y = y + 30,
        width = barWidth,
        height = barHeight,
        color = fillColor
    })

    registry:add(fillEntity, "hudBar", {
        id = id,
        maxWidth = barWidth
    })

    Canvas.createText(registry, {
        id = id .. "Value",
        canvasId = "battleHUD",
        x = x,
        y = y + 32,
        width = barWidth,
        value = "0 / 0",
        font = barFont or "normal",
        align = "center"
    })
end

function BattleHUDSetupSystem.setup(scene)
    local registry = scene.registry

    Canvas.create(registry, {
        id = "battleHUD",
        active = true,
        interactive = true,
        blocksGameplay = false,
        navigation = "vertical",
        selectedIndex = 1,
        priority = 10,
        dim = 0
    })

    createBar(
        registry,
        "patience",
        "Patience",
        540,
        150,
        {
            r = 0.35,
            g = 0.8,
            b = 0.95
        },
        "small",
        "small"
    )

    createBar(
        registry,
        "playerRelationship",
        "Player Relationship",
        25,
        360,
        {
            r = 0.9,
            g = 0.3,
            b = 0.35
        },
        "small",
        "small"
    )

    createBar(
        registry,
        "rivalRelationship",
        "Rival Relationship",
        25,
        15,
        {
            r = 0.9,
            g = 0.3,
            b = 0.35
        },
        "small",
        "small"
    )

    Canvas.createCircle(registry, {
        id = "energyCircle",
        canvasId = "battleHUD",

        x = 61,
        y = 490,
        radius = 32,

        color = {
            r = 0.95,
            g = 0.5,
            b = 0.15
        }
    })

    Canvas.createText(registry, {
        id = "energyText",
        canvasId = "battleHUD",

        x = 30,
        y = 476,
        width = 64,

        value = "3",
        font = "normal",
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "battleHUD",
        x = 650,
        y = 475,
        width = 135,
        height = 64,
        text = "Play Card",
        action = "playCard",
        index = 1,
        active = false
    })

    local deckEntity = Canvas.createPanel(registry, {
        canvasId = "battleHUD",
        x = 21,
        y = 537,
        width = 80,
        height = 50,

        color = {
            r = 0.2,
            g = 0.2,
            b = 0.25
        }
    })

    registry:add(deckEntity, "tooltip", {
        title = "Deck",
        text = "Cards left: 12"
    })

    registry:add(deckEntity, "hudDeck", {})
end

return BattleHUDSetupSystem