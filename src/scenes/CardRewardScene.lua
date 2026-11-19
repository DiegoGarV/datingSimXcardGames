local Scene = require("src.ecs.Scene")
local Canvas = require("src.ui.Canvas")
local UISystem = require("src.systems.UISystem")

local CardRewardScene = {}

local SetupSystem = {}

SetupSystem.name = "CardRewardPlaceholderSetupSystem"

function SetupSystem.setup(scene)
    Canvas.create(scene.registry, {
        id = "cardRewardPlaceholder",
        active = true,
        interactive = false
    })

    Canvas.createText(scene.registry, {
        id = "cardRewardTitle",
        canvasId = "cardRewardPlaceholder",

        x = 0,
        y = 250,
        width = 800,

        value = "CARD REWARD",
        font = "title",
        align = "center"
    })

    Canvas.createText(scene.registry, {
        id = "cardRewardMessage",
        canvasId = "cardRewardPlaceholder",

        x = 0,
        y = 320,
        width = 800,

        value = "Card acquisition will be implemented next.",
        font = "normal",
        align = "center"
    })
end

function CardRewardScene.new(payload)
    local scene =
        Scene.new("Card Reward Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    end

    scene:addSystem(SetupSystem)
    scene:addSystem(UISystem)

    return scene
end

return CardRewardScene