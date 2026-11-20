local Canvas =
    require("src.ui.Canvas")

local RoadmapInteractionSystem = {}

RoadmapInteractionSystem.name =
    "RoadmapInteractionSystem"


local PLAYER_INTERACTION_PADDING = 8


local FOCUS_NAMES = {
    conquest = "Conquest",
    attack = "Attack",
    protection = "Defense",
    neutral = "Neutral"
}


local REWARD_NAMES = {
    card = "New Card",

    development =
        "Development Points",

    both =
        "Development Points and New Card"
}


local function distanceSquared(
    x1,
    y1,
    x2,
    y2
)
    local dx = x1 - x2
    local dy = y1 - y2

    return
        dx * dx
        + dy * dy
end


local function formatFocus(
    focus
)
    if not focus
        or #focus == 0
    then
        return "None"
    end

    if #focus == 1 then
        return
            FOCUS_NAMES[
                focus[1]
            ]
            or focus[1]
    end

    local first =
        FOCUS_NAMES[
            focus[1]
        ]
        or focus[1]

    local second =
        FOCUS_NAMES[
            focus[2]
        ]
        or focus[2]

    return
        first
        .. " and "
        .. second
end


local function findPlayer(
    registry
)
    for _,
        position,
        player
    in
        registry:each(
            "position",
            "roadmapPlayer"
        )
    do
        return position, player
    end

    return nil, nil
end


local function findNearbyNode(
    registry,
    playerPosition,
    player
)
    for entity,
        position,
        circle,
        node
    in
        registry:each(
            "position",
            "circle",
            "roadmapNode"
        )
    do
        if node.activatable then
            local radius =
                player.radius
                + circle.radius
                + PLAYER_INTERACTION_PADDING

            if distanceSquared(
                playerPosition.x,
                playerPosition.y,
                position.x,
                position.y
            ) <= radius * radius
            then
                return {
                    entity = entity,
                    kind = "node",
                    data = node
                }
            end
        end
    end

    return nil
end


local function findNearbyReward(
    registry,
    playerPosition,
    player
)
    for entity,
        position,
        reward
    in
        registry:each(
            "position",
            "roadmapReward"
        )
    do
        if reward.activatable then
            local size =
                reward.size or 22

            local radius =
                player.radius
                + size
                + PLAYER_INTERACTION_PADDING

            if distanceSquared(
                playerPosition.x,
                playerPosition.y,
                position.x,
                position.y
            ) <= radius * radius
            then
                return {
                    entity = entity,
                    kind = "reward",
                    data = reward
                }
            end
        end
    end

    return nil
end


local function updatePrompt(
    registry
)
    local playerPosition,
        player =
        findPlayer(
            registry
        )

    if not playerPosition
        or not player
    then
        Canvas.hide(
            registry,
            "roadmapPrompt"
        )

        return
    end

    local target =
        findNearbyNode(
            registry,
            playerPosition,
            player
        )

    if not target then
        target =
            findNearbyReward(
                registry,
                playerPosition,
                player
            )
    end

    local roadmapState =
        registry:resource(
            "roadmapState"
        )

    if roadmapState then
        roadmapState.activeTarget =
            target
    end

    if target then
        Canvas.show(
            registry,
            "roadmapPrompt"
        )
    else
        Canvas.hide(
            registry,
            "roadmapPrompt"
        )
    end
end


local function mouseToWorld(
    registry,
    mouseX,
    mouseY
)
    local camera =
        registry:resource(
            "roadmapCamera"
        )

    if not camera then
        return mouseX, mouseY
    end

    return
        mouseX + camera.x,
        mouseY + camera.y
end


local function findHoveredNode(
    registry,
    mouseX,
    mouseY
)
    for entity,
        position,
        circle,
        node
    in
        registry:each(
            "position",
            "circle",
            "roadmapNode"
        )
    do
        if distanceSquared(
            mouseX,
            mouseY,
            position.x,
            position.y
        ) <= circle.radius
            * circle.radius
        then
            return {
                entity = entity,
                kind = "node",
                data = node
            }
        end
    end

    return nil
end


local function findHoveredReward(
    registry,
    mouseX,
    mouseY
)
    for entity,
        position,
        reward
    in
        registry:each(
            "position",
            "roadmapReward"
        )
    do
        local size =
            reward.size or 22

        -- Aproximación circular suficiente
        -- para detectar el diamante.
        if distanceSquared(
            mouseX,
            mouseY,
            position.x,
            position.y
        ) <= size * size
        then
            return {
                entity = entity,
                kind = "reward",
                data = reward
            }
        end
    end

    return nil
end


local function showNodeInfo(
    registry,
    node
)
    Canvas.setText(
        registry,
        "roadmapInfoTitle",
        "Level "
            .. tostring(
                node.level
            )
    )

    Canvas.setText(
        registry,
        "roadmapInfoDescription",
        "Focus: "
            .. formatFocus(
                node.focus
            )
    )

    Canvas.show(
        registry,
        "roadmapInfo"
    )
end


local function showRewardInfo(
    registry,
    reward
)
    Canvas.setText(
        registry,
        "roadmapInfoTitle",
        "Reward"
    )

    Canvas.setText(
        registry,
        "roadmapInfoDescription",
        "Type: "
            .. (
                REWARD_NAMES[
                    reward.rewardType
                ]
                or reward.rewardType
            )
    )

    Canvas.show(
        registry,
        "roadmapInfo"
    )
end


local function updateHoverInfo(
    registry
)
    local input =
        registry:resource(
            "input"
        )

    if not input then
        return
    end

    local mouseX,
        mouseY =
        mouseToWorld(
            registry,
            input.mouse.x,
            input.mouse.y
        )

    local target =
        findHoveredNode(
            registry,
            mouseX,
            mouseY
        )

    if not target then
        target =
            findHoveredReward(
                registry,
                mouseX,
                mouseY
            )
    end

    local roadmapState =
        registry:resource(
            "roadmapState"
        )

    if roadmapState then
        roadmapState.hoveredTarget =
            target
    end

    if not target then
        Canvas.hide(
            registry,
            "roadmapInfo"
        )

        return
    end

    if target.kind
        == "node"
    then
        showNodeInfo(
            registry,
            target.data
        )
    else
        showRewardInfo(
            registry,
            target.data
        )
    end
end


function RoadmapInteractionSystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    updatePrompt(
        registry
    )

    updateHoverInfo(
        registry
    )
end


return RoadmapInteractionSystem