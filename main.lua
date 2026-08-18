local GameConfig = require("src.GameConfig")
local SceneManager = require("src.ecs.SceneManager")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")
local MainMenuScene = require("src.scenes.MainMenuScene")
local TestScene = require("src.scenes.TestScene")

function love.load(args)
    love.window.setTitle("Dating Sim X Card Game") -- Aún no he pensado en el nombre del juego XD
    love.window.setMode(GameConfig.width, GameConfig.height)

    SceneManager.register("mainMenu", MainMenuScene.new)
    SceneManager.register("test", TestScene.new)

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

function love.draw()
    SceneManager.draw()
end

function love.quit()
    SceneManager.unload()
end