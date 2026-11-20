local RoadmapRenderSystem = {}

RoadmapRenderSystem.name =
    "RoadmapRenderSystem"

local FOCUS_COLORS = {
    conquest = {
        r = 0.85,
        g = 0.35,
        b = 0.55
    },

    attack = {
        r = 0.85,
        g = 0.30,
        b = 0.30
    },

    protection = {
        r = 0.30,
        g = 0.55,
        b = 0.90
    },

    neutral = {
        r = 0.65,
        g = 0.65,
        b = 0.70
    }
}

local function findNodePosition(
    registry,
    nodeId
)
    for _,
        position,
        roadmapNode
    in
        registry:each(
            "position",
            "roadmapNode"
        )
    do
        if roadmapNode.id
            == nodeId
        then
            return position
        end
    end

    return nil
end

local function drawConnections(
    registry
)
    love.graphics.setColor(
        0.35,
        0.35,
        0.40,
        1
    )

    love.graphics.setLineWidth(4)

    for _,
        connection
    in
        registry:each(
            "roadmapConnection"
        )
    do
        local from =
            findNodePosition(
                registry,
                connection.fromId
            )

        local to =
            findNodePosition(
                registry,
                connection.toId
            )

        if from
            and to
        then
            love.graphics.line(
                from.x,
                from.y,
                to.x,
                to.y
            )
        end
    end
end

local function getNodeColor(
    roadmapNode
)
    local focus =
        roadmapNode.focus

    if not focus
        or #focus == 0
    then
        return
            FOCUS_COLORS.neutral
    end

    if #focus == 1 then
        return
            FOCUS_COLORS[
                focus[1]
            ]
            or FOCUS_COLORS.neutral
    end

    local first =
        FOCUS_COLORS[
            focus[1]
        ]

    local second =
        FOCUS_COLORS[
            focus[2]
        ]

    if not first
        or not second
    then
        return
            FOCUS_COLORS.neutral
    end

    return {
        r =
            (
                first.r
                + second.r
            ) / 2,

        g =
            (
                first.g
                + second.g
            ) / 2,

        b =
            (
                first.b
                + second.b
            ) / 2
    }
end

local function drawNodes(
    registry
)
    for _,
        position,
        circle,
        roadmapNode
    in
        registry:each(
            "position",
            "circle",
            "roadmapNode"
        )
    do
        local color =
            getNodeColor(
                roadmapNode
            )

        love.graphics.setColor(
            color.r,
            color.g,
            color.b,
            1
        )

        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            circle.radius
        )

        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.setLineWidth(2)

        love.graphics.circle(
            "line",
            position.x,
            position.y,
            circle.radius
        )

        love.graphics.print(
            tostring(
                roadmapNode.level
            ),
            position.x - 4,
            position.y - 7
        )
    end
end

local function drawRewards(
    registry
)
    for _,
        position,
        reward
    in
        registry:each(
            "position",
            "roadmapReward"
        )
    do
        if reward.rewardType
            == "card"
        then
            love.graphics.setColor(
                0.95,
                0.80,
                0.25,
                1
            )

        elseif reward.rewardType
            == "development"
        then
            love.graphics.setColor(
                0.30,
                0.90,
                0.50,
                1
            )

        else
            love.graphics.setColor(
                0.75,
                0.40,
                0.95,
                1
            )
        end

        local size = 10

        love.graphics.polygon(
            "fill",

            position.x,
            position.y - size,

            position.x + size,
            position.y,

            position.x,
            position.y + size,

            position.x - size,
            position.y
        )
    end
end

function RoadmapRenderSystem.draw(
    scene
)
    local registry =
        scene.registry

    love.graphics.clear(
        0.07,
        0.07,
        0.09,
        1
    )

    local camera =
        registry:resource(
            "roadmapCamera"
        )

    love.graphics.push()

    if camera then
        love.graphics.translate(
            -camera.x,
            -camera.y
        )
    end

    drawConnections(
        registry
    )

    drawNodes(
        registry
    )

    drawRewards(
        registry
    )

    love.graphics.pop()

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setLineWidth(1)
end

return RoadmapRenderSystem