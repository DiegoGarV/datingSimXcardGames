-- FROM: https://github.com/denn1s/game-engine-v3/blob/02-ECS/src/ecs/Scene.lua

local Registry = require("src.ecs.Registry")
local Canvas = require("src.ui.Canvas")

local Scene = {}
Scene.__index = Scene

function Scene.new(name)
    return setmetatable({
        name = name,
        registry = Registry.new(),
        systems = {},
        disabledSystems = {},
    }, Scene)
end

function Scene:addSystem(system)
    for _, registeredSystem in ipairs(self.systems) do
        if registeredSystem == system then
            return
        end
    end
    
    self.systems[#self.systems + 1] = system
end

function Scene:setup()
    for _, system in ipairs(self.systems) do
        if system.setup then
            system.setup(self)
        end
    end
end

function Scene:unload()
    for _, system in ipairs(self.systems) do
        if system.unload then
            system.unload(self)
        end
    end
end

function Scene:update(dt)
    local gameplayBlocked = Canvas.blocksGameplay(self.registry)

    for _, system in ipairs(self.systems) do
        if system.update and not self.disabledSystems[system] then
            local canRun = not gameplayBlocked or system.runWhenCanvasBlocked

            if canRun then
                system.update(self, dt)
            end
        end
    end
end

function Scene:draw()
    for _, system in ipairs(self.systems) do
        if system.draw and not self.disabledSystems[system] then
            system.draw(self)
        end
    end
end

return Scene