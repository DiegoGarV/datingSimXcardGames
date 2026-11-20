local RoadmapAccessSystem = {}

RoadmapAccessSystem.name =
    "RoadmapAccessSystem"

local function buildCompletedSet(
    completedNodes
)
    local completed = {}

    for _, nodeId in ipairs(
        completedNodes
    ) do
        completed[nodeId] = true
    end

    return completed
end

local function isChildOfCurrent(
    roadmap,
    currentNodeId,
    nodeId
)
    local currentNode =
        roadmap.nodes[currentNodeId]

    if not currentNode
        or not currentNode.children
    then
        return false
    end

    for _, childId in ipairs(
        currentNode.children
    ) do
        if childId == nodeId then
            return true
        end
    end

    return false
end

local function getNodeStatus(
    roadmap,
    progress,
    completed,
    nodeId
)
    if completed[nodeId] then
        return "completed"
    end

    if nodeId
        == progress.currentNode
    then
        return "current"
    end

    local currentCompleted =
        completed[
            progress.currentNode
        ] == true

    if currentCompleted
        and isChildOfCurrent(
            roadmap,
            progress.currentNode,
            nodeId
        )
    then
        return "available"
    end

    return "blocked"
end

local function isRewardClaimed(
    claimedRewards,
    rewardId
)
    for _, claimedId in ipairs(
        claimedRewards
    ) do
        if claimedId == rewardId then
            return true
        end
    end

    return false
end

function RoadmapAccessSystem.update(
    scene,
    dt
)
    local registry =
        scene.registry

    local gameState =
        registry:resource(
            "gameState"
        )

    local roadmapState =
        registry:resource(
            "roadmapState"
        )

    if not gameState
        or not roadmapState
    then
        return
    end

    local progress =
        gameState.run.roadmap

    local completed =
        buildCompletedSet(
            progress.completedNodes
        )

    for _,
        roadmapNode
    in
        registry:each(
            "roadmapNode"
        )
    do
        local status =
            getNodeStatus(
                roadmapState.map,
                progress,
                completed,
                roadmapNode.id
            )

        roadmapNode.status =
            status

        roadmapNode.blocking =
            status == "blocked"

        roadmapNode.activatable =
            status == "current"
            or status == "available"
    end

    for _,
        reward
    in
        registry:each(
            "roadmapReward"
        )
    do
        if isRewardClaimed(
            progress.claimedRewards,
            reward.id
        ) then
            reward.status =
                "completed"

        elseif completed[
            reward.parentNode
        ] then
            reward.status =
                "available"

        else
            reward.status =
                "blocked"
        end

        reward.blocking =
            reward.status
            == "blocked"

        reward.activatable =
            reward.status
            == "available"
    end
end

return RoadmapAccessSystem