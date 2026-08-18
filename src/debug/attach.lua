local DebugOverlay = require("src.debug.DebugOverlay")

local UI_EVENTS = {
    "textinput",
    "wheelmoved"
}

return function(sceneManager)
    local update = love.update

    love.update = function(dt)
        DebugOverlay.beginFrame(sceneManager.current())

        if DebugOverlay.shouldUpdate() then
            update(dt)
        end
    end

    local draw = love.draw

    love.draw = function()
        DebugOverlay.draw(draw)
    end

    for _, event in ipairs(UI_EVENTS) do
        local original = love[event]

        love[event] = function(...)
            if DebugOverlay[event](...) then
                return
            end

            if original then
                original(...)
            end
        end
    end

    local keypressed = love.keypressed

    love.keypressed = function(key, scancode, isrepeat)
        if DebugOverlay.keypressed(key) then
            return
        end

        if DebugOverlay.isPaused() then
            return
        end

        if keypressed then
            keypressed(key, scancode, isrepeat)
        end
    end

    local mousepressed = love.mousepressed

    love.mousepressed = function(x, y, button, istouch, presses)
        if DebugOverlay.mousepressed(x, y, button) then
            return
        end

        if DebugOverlay.isPaused() then
            return
        end

        local gameX, gameY = DebugOverlay.screenToGame(x, y)

        if gameX and gameY and mousepressed then
            mousepressed(gameX, gameY, button, istouch, presses)
        end
    end

    local mousereleased = love.mousereleased

    love.mousereleased = function(x, y, button, istouch, presses)
        if DebugOverlay.mousereleased(x, y, button) then
            return
        end

        if DebugOverlay.isPaused() then
            return
        end

        local gameX, gameY = DebugOverlay.screenToGame(x, y)

        if gameX and gameY and mousereleased then
            mousereleased(gameX, gameY, button, istouch, presses)
        end
    end

    local mousemoved = love.mousemoved

    love.mousemoved = function(x, y, dx, dy, istouch)
        if DebugOverlay.isPaused() then
            return
        end
        
        local gameX, gameY = DebugOverlay.screenToGame(x, y)

        if not gameX or not gameY then
            return
        end

        local viewport = DebugOverlay.getViewport()
        local gameDX = dx / viewport.scale
        local gameDY = dy / viewport.scale

        if mousemoved then
            mousemoved(gameX, gameY, gameDX, gameDY, istouch)
        end
    end
end