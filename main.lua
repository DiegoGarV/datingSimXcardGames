local SceneManager = require("src.ecs.SceneManager")
local MainMenuScene = require("src.scenes.MainMenuScene")

function love.load()
    love.window.setTitle("Dating Sim X Card Game") -- Aún no he pensado en el nombre del juego XD
    love.window.setMode(800, 600)

    SceneManager.register("mainMenu", MainMenuScene.new)

    SceneManager.change("mainMenu")
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