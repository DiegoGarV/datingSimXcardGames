local RoadmapMovementSystem = {}

RoadmapMovementSystem.name =
    "RoadmapMovementSystem"

local function clamp(
    value,
    minimum,
    maximum
)
    return math.max(
        minimum,
        math.min(
            maximum,
            value
        )
    )
end

local function getMovement()
    local x = 0
    local y = 0

    if love.keyboard.isDown(
        "a",
        "left"
    ) then
        x = x - 1
    end

    if love.keyboard.isDown(
        "d",
        "right"
    ) then
        x = x + 1
    end

    if love.keyboard.isDown(
        "w",
        "up"
    ) then
        y = y - 1
    end

    if love.keyboard.isDown(
        "s",
        "down"
    ) then
        y = y + 1
    end

    if x ~= 0
        and y ~= 0
    then
        local length =
            math.sqrt(
                x * x
                + y * y
            )

        x = x / length
        y = y / length
    end

    return x, y
end

local function updateCamera(
    registry,
    position
)
    local camera =
        registry:resource(
            "roadmapCamera"
        )

    local bounds =
        registry:resource(
            "roadmapBounds"
        )

    if not camera
        or not bounds
    then
        return
    end

    camera.y =
        clamp(
            position.y
                - camera.viewportHeight / 2,

            bounds.cameraTop,
            bounds.cameraBottom
        )
end

function RoadmapMovementSystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    local bounds =
        registry:resource(
            "roadmapBounds"
        )

    if not bounds then
        return
    end

    local moveX, moveY =
        getMovement()

    for _,
        position,
        player
    in
        registry:each(
            "position",
            "roadmapPlayer"
        )
    do
        position.x =
            position.x
            + moveX
            * player.speed
            * dt

        position.y =
            position.y
            + moveY
            * player.speed
            * dt

        position.x =
            clamp(
                position.x,
                bounds.left,
                bounds.right
            )

        position.y =
            clamp(
                position.y,
                bounds.top,
                bounds.bottom
            )

        updateCamera(
            registry,
            position
        )
    end
end

return RoadmapMovementSystem