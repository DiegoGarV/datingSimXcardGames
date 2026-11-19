local Scene = require("src.ecs.Scene")
local GameState = require("src.state.GameState")

local CardRewardSetupSystem = require("src.systems.cardReward.CardRewardSetupSystem")
local CardRewardSystem = require("src.systems.cardReward.CardRewardSystem")

local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")

local InputSystem = require("src.systems.InputSystem")
local UISystem = require("src.systems.UISystem")
local TooltipSystem = require("src.systems.TooltipSystem")

local CardRewardScene = {}

function CardRewardScene.new(payload)
    local scene =
        Scene.new("Card Reward Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    else
        -- Debug fallback
        scene.registry:setResource(
            "gameState",
            GameState.new(12345)
        )
    end

    scene:addSystem(CardRewardSetupSystem)
    scene:addSystem(PauseMenuSetupSystem)

    scene:addSystem(InputSystem)
    scene:addSystem(CardRewardSystem)
    scene:addSystem(PauseMenuSystem)

    scene:addSystem(UISystem)
    scene:addSystem(TooltipSystem)

    return scene
end

return CardRewardScene