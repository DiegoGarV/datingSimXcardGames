local TestAnimationSystem = {}

TestAnimationSystem.name = "TestAnimationSystem"

local function lerp(a, b, t)
    return a + (b - a) * t
end

function TestAnimationSystem.update(scene, dt)
    local registry = scene.registry

    for entity, position, animation in registry:each(
        "position",
        "testAnimation"
    ) do
        animation.progress =
            animation.progress
            + dt / animation.duration

        local t = math.min(
            animation.progress,
            1
        )

        if animation.returning then
            position.x = lerp(
                animation.targetX,
                animation.startX,
                t
            )

            position.y = lerp(
                animation.targetY,
                animation.startY,
                t
            )
        else
            position.x = lerp(
                animation.startX,
                animation.targetX,
                t
            )

            position.y = lerp(
                animation.startY,
                animation.targetY,
                t
            )
        end

        if animation.progress >= 1 then
            if animation.returning then
                position.x = animation.startX
                position.y = animation.startY

                registry:remove(
                    entity,
                    "testAnimation"
                )
            else
                animation.returning = true
                animation.progress = 0
            end
        end
    end
end

return TestAnimationSystem