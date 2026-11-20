local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")
local CardInventorySetupSystem = require("src.systems.cardInventory.CardInventorySetupSystem")
local CardInventorySystem = require("src.systems.cardInventory.CardInventorySystem")
local InputSystem = require("src.systems.InputSystem")
local UISystem = require("src.systems.UISystem")
local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")

local CardInventoryScene = {}

function CardInventoryScene.new(payload)
    local scene = Scene.new("Card Inventory Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    else
        -- Debug fallback
        local gameState = GameState.new(12345)

        gameState.run.deck = {
            "flirt",
            "teaseRival",
            "keepCalm",
            "sweetTalk",
            "jealousy",
            "counterMove",
            "grandGesture",
            "publicEmbarrassment",
            "unshakableConfidence"
        }

        scene.registry:setResource(
            "gameState",
            gameState
        )
    end

    scene:addSystem(CardInventorySetupSystem)
    scene:addSystem(PauseMenuSetupSystem)
    scene:addSystem(InputSystem)
    scene:addSystem(CardInventorySystem)
    scene:addSystem(PauseMenuSystem)
    scene:addSystem(UISystem)

    return scene
end

return CardInventoryScene