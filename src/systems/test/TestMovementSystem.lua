local GameConfig = require("src.GameConfig")

local TestMovementSystem = {}

TestMovementSystem.name = "TestMovementSystem"

function TestMovementSystem.update(scene, dt)
    for _, position, velocity, rectangle in
        scene.registry:each(
            "position",
            "velocity",
            "rectangle"
        )
    do
        position.x = position.x + velocity.x * dt

        if position.x + rectangle.width >= GameConfig.width then
            position.x = GameConfig.width - rectangle.width
            velocity.x = -math.abs(velocity.x)

        elseif position.x <= 0 then
            position.x = 0
            velocity.x = math.abs(velocity.x)
        end
    end
end

return TestMovementSystem