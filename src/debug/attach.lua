local DebugOverlay = require("src.debug.DebugOverlay")

local UI_EVENTS = {
    "keypressed",
    "textinput",
    "mousepressed",
    "mousereleased",
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
end