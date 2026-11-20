local GameConfig = require("src.GameConfig")
local SaveFile = require("src.state.SaveFile")
local SceneManager = require("src.ecs.SceneManager")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")
local MainMenuScene = require("src.scenes.MainMenuScene")
local FightScene = require("src.scenes.FightScene")
local DevelopmentScene = require("src.scenes.DevelopmentScene")
local CardRewardScene = require("src.scenes.CardRewardScene")
local CardInventoryScene = require("src.scenes.CardInventoryScene")
local RoadmapScene = require("src.scenes.RoadmapScene")

function love.load(args)
    -- SaveFile.delete()
    -- Debug
    print(love.filesystem.getSaveDirectory())

    love.window.setTitle("Dating Sim X Card Game") -- Aún no he pensado en el nombre del juego XD
    love.window.setMode(GameConfig.width, GameConfig.height)

    SceneManager.register("mainMenu", MainMenuScene.new)
    SceneManager.register("fight", FightScene.new)
    SceneManager.register("development", DevelopmentScene.new)
    SceneManager.register("cardReward", CardRewardScene.new)
    SceneManager.register("cardInventory", CardInventoryScene.new)
    SceneManager.register("roadmap", RoadmapScene.new)

    SceneManager.change("mainMenu")

    attachDebugOverlay(SceneManager)

    if args and args[1] == "--debug" then
        DebugOverlay.enterEditor()
    end
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.keypressed(key)
    SceneManager.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    SceneManager.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    SceneManager.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    SceneManager.mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
    SceneManager.wheelmoved(x, y)
end

function love.draw()
    SceneManager.draw()
end

function love.quit()
    SceneManager.unload()
end