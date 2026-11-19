local Scene = require("src.ecs.Scene")
local FightSetupSystem = require("src.systems.fight.FightSetupSystem")
local BattleHUDSetupSystem = require("src.systems.battleHUD.BattleHUDSetupSystem")
local BattleHUDSystem = require("src.systems.battleHUD.BattleHUDSystem")
local PauseMenuSetupSystem = require("src.systems.pause.PauseMenuSetupSystem")
local InputSystem = require("src.systems.InputSystem")
local FightSystem = require("src.systems.fight.FightSystem")
local PauseMenuSystem = require("src.systems.pause.PauseMenuSystem")
local FightAnimationSystem = require("src.systems.fight.FightAnimationSystem")
local FightRenderSystem = require("src.systems.fight.FightRenderSystem")
local UISystem = require("src.systems.UISystem")
local TooltipSystem = require("src.systems.TooltipSystem")

local FightScene = {}

function FightScene.new(payload)
    local scene = Scene.new("Fight Scene")

    if payload and payload.gameState then
        scene.registry:setResource(
            "gameState",
            payload.gameState
        )
    end

    scene:addSystem(FightSetupSystem)
    scene:addSystem(BattleHUDSetupSystem)
    scene:addSystem(PauseMenuSetupSystem)

    scene:addSystem(InputSystem)
    scene:addSystem(FightSystem)
    scene:addSystem(BattleHUDSystem)
    scene:addSystem(PauseMenuSystem)
    scene:addSystem(FightAnimationSystem)

    scene:addSystem(FightRenderSystem)
    scene:addSystem(UISystem)
    scene:addSystem(TooltipSystem)

    return scene
end

return FightScene