local RoadmapRenderSystem = {}

RoadmapRenderSystem.name = "RoadmapRenderSystem"

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

local function findRoadmapNode(
    registry,
    nodeId
)
    for _,
        roadmapNode
    in
        registry:each(
            "roadmapNode"
        )
    do
        if roadmapNode.id
            == nodeId
        then
            return roadmapNode
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
            local targetNode =
                findRoadmapNode(
                    registry,
                    connection.toId
                )

            if targetNode
                and targetNode.status
                    == "blocked"
            then
                love.graphics.setColor(
                    0.20,
                    0.20,
                    0.23,
                    1
                )
            else
                love.graphics.setColor(
                    0.45,
                    0.45,
                    0.50,
                    1
                )
            end

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

        -- 1. FILL DEL NODO
        -- El color representa el enfoque.
        if roadmapNode.status
            == "blocked"
        then
            -- Si está bloqueado,
            -- mantenemos su color pero mucho más oscuro.
            love.graphics.setColor(
                color.r * 0.25,
                color.g * 0.25,
                color.b * 0.25,
                1
            )
        else
            love.graphics.setColor(
                color.r,
                color.g,
                color.b,
                1
            )
        end

        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            circle.radius
        )


        -- 2. COLOR DEL BORDE
        -- El borde representa el estado.
        if roadmapNode.status
            == "blocked"
        then
            love.graphics.setColor(
                0.45,
                0.45,
                0.48,
                1
            )

        elseif roadmapNode.status
            == "current"
        then
            love.graphics.setColor(
                1,
                0.85,
                0.25,
                1
            )

        elseif roadmapNode.status
            == "available"
        then
            love.graphics.setColor(
                1,
                1,
                1,
                1
            )

        elseif roadmapNode.status
            == "completed"
        then
            love.graphics.setColor(
                0.35,
                0.9,
                0.45,
                1
            )

        else
            love.graphics.setColor(
                1,
                1,
                1,
                1
            )
        end

        love.graphics.setLineWidth(
            roadmapNode.status
                == "current"
                and 4
                or 2
        )

        love.graphics.circle(
            "line",
            position.x,
            position.y,
            circle.radius
        )


        -- 3. NÚMERO DEL NIVEL
        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.print(
            tostring(
                roadmapNode.level
            ),
            position.x - 4,
            position.y - 7
        )


        -- 4. X PARA NODOS BLOQUEADOS
        if roadmapNode.status
            == "blocked"
        then
            local lockSize =
                circle.radius * 0.45

            love.graphics.setColor(
                0.75,
                0.75,
                0.78,
                1
            )

            love.graphics.setLineWidth(3)

            love.graphics.line(
                position.x - lockSize,
                position.y - lockSize,
                position.x + lockSize,
                position.y + lockSize
            )

            love.graphics.line(
                position.x + lockSize,
                position.y - lockSize,
                position.x - lockSize,
                position.y + lockSize
            )
        end
    end
end

local function drawRewardConnections(
    registry
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
        local parentPosition =
            findNodePosition(
                registry,
                reward.parentNode
            )

        if parentPosition then
            if reward.status
                == "blocked"
            then
                love.graphics.setColor(
                    0.20,
                    0.20,
                    0.23,
                    1
                )
            else
                love.graphics.setColor(
                    0.45,
                    0.45,
                    0.50,
                    1
                )
            end

            love.graphics.setLineWidth(3)

            love.graphics.line(
                parentPosition.x,
                parentPosition.y,
                rewardPosition.x,
                rewardPosition.y
            )
        end
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
        local size =
            reward.size or 22

        -- 1. FILL
        -- El color representa el tipo de premio.

        local r
        local g
        local b

        if reward.rewardType
            == "card"
        then
            r = 0.95
            g = 0.80
            b = 0.25

        elseif reward.rewardType
            == "development"
        then
            r = 0.30
            g = 0.90
            b = 0.50

        else
            r = 0.75
            g = 0.40
            b = 0.95
        end

        if reward.status
            == "blocked"
        then
            love.graphics.setColor(
                r * 0.25,
                g * 0.25,
                b * 0.25,
                1
            )
        else
            love.graphics.setColor(
                r,
                g,
                b,
                1
            )
        end

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


        -- 2. BORDE
        -- El color representa el estado.

        if reward.status
            == "blocked"
        then
            love.graphics.setColor(
                0.45,
                0.45,
                0.48,
                1
            )

        elseif reward.status
            == "available"
        then
            love.graphics.setColor(
                1,
                1,
                1,
                1
            )

        elseif reward.status
            == "completed"
        then
            love.graphics.setColor(
                0.35,
                0.9,
                0.45,
                1
            )

        else
            love.graphics.setColor(
                1,
                1,
                1,
                1
            )
        end

        love.graphics.setLineWidth(3)

        love.graphics.polygon(
            "line",

            position.x,
            position.y - size,

            position.x + size,
            position.y,

            position.x,
            position.y + size,

            position.x - size,
            position.y
        )


        -- 3. X PARA REWARD BLOQUEADA

        if reward.status
            == "blocked"
        then
            local lockSize =
                size * 0.45

            love.graphics.setColor(
                0.75,
                0.75,
                0.78,
                1
            )

            love.graphics.setLineWidth(3)

            love.graphics.line(
                position.x - lockSize,
                position.y - lockSize,
                position.x + lockSize,
                position.y + lockSize
            )

            love.graphics.line(
                position.x + lockSize,
                position.y - lockSize,
                position.x - lockSize,
                position.y + lockSize
            )
        end
    end
end

local function drawPlayer(
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
        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            player.radius
        )

        love.graphics.setColor(
            0.1,
            0.1,
            0.12,
            1
        )

        love.graphics.setLineWidth(3)

        love.graphics.circle(
            "line",
            position.x,
            position.y,
            player.radius
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

    drawRewardConnections(
        registry
    )

    drawNodes(
        registry
    )

    drawRewards(
        registry
    )

    drawPlayer(
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