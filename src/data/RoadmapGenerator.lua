local RoadmapGenerator = {}

local SINGLE_FOCUSES = {
    "conquest",
    "attack",
    "protection"
}

local MIXED_FOCUSES = {
    {
        "conquest",
        "attack"
    },

    {
        "conquest",
        "protection"
    },

    {
        "attack",
        "protection"
    }
}

local function getNodeLetter(index)
    return string.char(
        string.byte("A")
        + index
        - 1
    )
end

local function getNodeId(
    level,
    index
)
    return
        "level"
        .. tostring(level)
        .. getNodeLetter(index)
end

local function getNodeCount(
    rng,
    level
)
    -- Inicio.
    if level == 1 then
        return 1
    end

    -- Boss final.
    if level == 8 then
        return 1
    end

    -- Más variedad en la parte
    -- central del roadmap.
    if level <= 5 then
        return rng:random(2, 3)
    end

    -- Se empieza a cerrar el árbol
    -- antes del boss.
    return rng:random(1, 2)
end

local function getFocus(
    rng,
    level
)
    if level == 1 then
        return {
            "neutral"
        }
    end

    local mixedChance = 0

    if level >= 4
        and level <= 5
    then
        mixedChance = 0.20

    elseif level >= 6
        and level <= 7
    then
        mixedChance = 0.45

    elseif level == 8 then
        mixedChance = 0.75
    end

    if rng:random() < mixedChance then
        local focus =
            MIXED_FOCUSES[
                rng:random(
                    1,
                    #MIXED_FOCUSES
                )
            ]

        return {
            focus[1],
            focus[2]
        }
    end

    return {
        SINGLE_FOCUSES[
            rng:random(
                1,
                #SINGLE_FOCUSES
            )
        ]
    }
end

local function contains(
    list,
    value
)
    for _, current in ipairs(list) do
        if current == value then
            return true
        end
    end

    return false
end

local function connect(
    parent,
    child
)
    if not contains(
        parent.children,
        child.id
    ) then
        parent.children[
            #parent.children + 1
        ] = child.id
    end

    if not contains(
        child.parents,
        parent.id
    ) then
        child.parents[
            #child.parents + 1
        ] = parent.id
    end
end

local function connectLevels(
    rng,
    currentLevel,
    nextLevel
)
    -- Cada nodo produce uno o dos
    -- caminos.
    for _, parent in ipairs(
        currentLevel
    ) do
        local connectionCount = 1

        if #nextLevel > 1
            and rng:random() < 0.55
        then
            connectionCount = 2
        end

        local available = {}

        for index = 1, #nextLevel do
            available[index] = index
        end

        for _ = 1, connectionCount do
            if #available == 0 then
                break
            end

            local selection =
                rng:random(
                    1,
                    #available
                )

            local childIndex =
                available[selection]

            table.remove(
                available,
                selection
            )

            connect(
                parent,
                nextLevel[
                    childIndex
                ]
            )
        end
    end

    -- Garantiza que ningún nodo
    -- del siguiente nivel quede
    -- desconectado.
    for _, child in ipairs(
        nextLevel
    ) do
        if #child.parents == 0 then
            local parent =
                currentLevel[
                    rng:random(
                        1,
                        #currentLevel
                    )
                ]

            connect(
                parent,
                child
            )
        end
    end
end

local function shouldGenerateReward(
    rng,
    level
)
    if level <= 1
        or level >= 8
    then
        return false
    end

    return rng:random() < 0.45
end

local function getRewardType(
    rng,
    level
)
    local bothChance = 0

    if level >= 6 then
        bothChance = 0.35

    elseif level >= 4 then
        bothChance = 0.15
    end

    if rng:random() < bothChance then
        return "both"
    end

    if rng:random() < 0.5 then
        return "card"
    end

    return "development"
end

local function getDevelopmentReward(
    level
)
    if level >= 7 then
        return 3

    elseif level >= 4 then
        return 2
    end

    return 1
end

local function generateReward(
    rng,
    fightNode
)
    local rewardType =
        getRewardType(
            rng,
            fightNode.level
        )

    return {
        id =
            "reward_"
            .. fightNode.id,

        kind = "reward",

        level =
            fightNode.level,

        parentNode =
            fightNode.id,

        rewardType =
            rewardType,

        developmentPoints =
            rewardType == "development"
                or rewardType == "both"
            and getDevelopmentReward(
                fightNode.level
            )
            or 0
    }
end

function RoadmapGenerator.generate(seed)
    local rng =
        love.math.newRandomGenerator(
            seed + 7319
        )

    local roadmap = {
        levels = {},
        nodes = {},
        rewards = {}
    }

    -- Primero creamos todos los
    -- niveles y encuentros.
    for level = 1, 8 do
        local nodeCount =
            getNodeCount(
                rng,
                level
            )

        local nodes = {}

        for index = 1, nodeCount do
            local id =
                getNodeId(
                    level,
                    index
                )

            local node = {
                id = id,

                kind = "fight",

                level = level,

                focus =
                    getFocus(
                        rng,
                        level
                    ),

                parents = {},
                children = {}
            }

            nodes[
                #nodes + 1
            ] = node

            roadmap.nodes[id] =
                node
        end

        roadmap.levels[level] =
            nodes
    end

    -- Después conectamos cada
    -- nivel con el siguiente.
    for level = 1, 7 do
        connectLevels(
            rng,
            roadmap.levels[level],
            roadmap.levels[
                level + 1
            ]
        )
    end

    -- Finalmente generamos los
    -- puntos de recompensa.
    for level = 2, 7 do
        for _, fightNode in ipairs(
            roadmap.levels[level]
        ) do
            if shouldGenerateReward(
                rng,
                level
            ) then
                local reward =
                    generateReward(
                        rng,
                        fightNode
                    )

                roadmap.rewards[
                    #roadmap.rewards + 1
                ] = reward

                roadmap.nodes[
                    reward.id
                ] = reward
            end
        end
    end

    return roadmap
end

return RoadmapGenerator