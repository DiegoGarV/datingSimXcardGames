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

local function collidesWithBlockedNode(
    registry,
    x,
    y,
    playerRadius
)
    for _,
        nodePosition,
        circle,
        roadmapNode
    in
        registry:each(
            "position",
            "circle",
            "roadmapNode"
        )
    do
        if roadmapNode.blocking then
            local dx =
                x - nodePosition.x

            local dy =
                y - nodePosition.y

            local distanceSquared =
                dx * dx
                + dy * dy

            local minimumDistance =
                playerRadius
                + circle.radius

            if distanceSquared
                < minimumDistance
                * minimumDistance
            then
                return true
            end
        end
    end

    return false
end

local function collidesWithBlockedReward(
    registry,
    x,
    y,
    playerRadius
)
    for _,
        rewardPosition,
        reward
    in
        registry:each(
            "position",
            "roadmapReward"
        )
    do
        if reward.blocking then
            local dx =
                x - rewardPosition.x

            local dy =
                y - rewardPosition.y

            local distanceSquared =
                dx * dx
                + dy * dy

            local rewardRadius =
                reward.size or 22

            local minimumDistance =
                playerRadius
                + rewardRadius

            if distanceSquared
                < minimumDistance
                * minimumDistance
            then
                return true
            end
        end
    end

    return false
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
        local nextX =
            position.x
            + moveX
            * player.speed
            * dt

        nextX =
            clamp(
                nextX,
                bounds.left,
                bounds.right
            )

        if not collidesWithBlockedNode(
            registry,
            nextX,
            position.y,
            player.radius
        )
        and not collidesWithBlockedReward(
            registry,
            nextX,
            position.y,
            player.radius
        )
        then
            position.x = nextX
        end

        local nextY =
            position.y
            + moveY
            * player.speed
            * dt

        nextY =
            clamp(
                nextY,
                bounds.top,
                bounds.bottom
            )

        if not collidesWithBlockedNode(
            registry,
            position.x,
            nextY,
            player.radius
        )
        and not collidesWithBlockedReward(
            registry,
            position.x,
            nextY,
            player.radius
        )
        then
            position.y = nextY
        end

        updateCamera(
            registry,
            position
        )
    end
end

return RoadmapMovementSystem