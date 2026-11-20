local Canvas = require("src.ui.Canvas")
local CardDefinitions = require("src.data.CardDefinitions")

local CardRewardSetupSystem = {}

CardRewardSetupSystem.name =
    "CardRewardSetupSystem"

local CARD_WIDTH = 160
local CARD_HEIGHT = 220
local CARD_Y = 180

local CARD_POSITIONS = {
    70,
    320,
    570
}

local categoryColors = {
    conquest = {
        r = 0.75,
        g = 0.3,
        b = 0.45
    },

    attack = {
        r = 0.75,
        g = 0.25,
        b = 0.25
    },

    protection = {
        r = 0.25,
        g = 0.5,
        b = 0.8
    }
}

local function ensureRewardState(
    gameState
)
    if not gameState.run.cardReward then
        gameState.run.cardReward = {
            claimedForLevel = nil,
            claimedKey = nil
        }

        return
    end

    if gameState.run.cardReward.claimedKey
        == nil
    then
        gameState.run.cardReward.claimedKey =
            nil
    end
end

local function getEligibleCards(gameState)
    local progression =
        gameState.run.progression

    local eligible = {}

    for _, card in ipairs(
        CardDefinitions.cards
    ) do
        local categoryLevel =
            progression[card.category] or 1

        if categoryLevel >=
            card.requiredLevel
        then
            eligible[#eligible + 1] =
                card
        end
    end

    return eligible
end

local function chooseWeightedCard(
    rng,
    cards,
    progression
)
    local totalWeight = 0

    for _, card in ipairs(cards) do
        totalWeight =
            totalWeight
            + (progression[card.category] or 1)
    end

    local roll =
        rng:random() * totalWeight

    local current = 0

    for index, card in ipairs(cards) do
        current =
            current
            + (progression[card.category] or 1)

        if roll <= current then
            return index, card
        end
    end

    return #cards, cards[#cards]
end

local function generateChoices(gameState)
    local progression =
        gameState.run.progression

    local pool =
        getEligibleCards(gameState)

    local seed =
        gameState.run.seed
        + gameState.run.level * 1000
        + progression.conquest * 100
        + progression.attack * 10
        + progression.protection

    local rng =
        love.math.newRandomGenerator(seed)

    local choices = {}

    while #choices < 3
        and #pool > 0
    do
        local index, card =
            chooseWeightedCard(
                rng,
                pool,
                progression
            )

        choices[#choices + 1] =
            card.id

        table.remove(
            pool,
            index
        )
    end

    return choices
end

local function getTooltipText(card)
    return
        "Category: "
        .. card.category
        .. "\nRarity: "
        .. card.rarity
        .. "\nCost: "
        .. tostring(card.cost)
        .. "\n\n"
        .. card.effect
end

local function getClaimKey(
    gameState
)
    local flow =
        gameState.run.flow

    if flow
        and flow.source
            == "roadmapReward"
        and flow.rewardId
    then
        return
            "roadmap:"
            .. flow.rewardId
    end

    return
        "level:"
        .. tostring(
            gameState.run.level
        )
end

local function createRewardCard(
    registry,
    cardId,
    index
)
    local card =
        CardDefinitions.get(cardId)

    if not card then
        return
    end

    local x =
        CARD_POSITIONS[index]

    local color =
        categoryColors[card.category]

    local entity =
        Canvas.createButton(
            registry,
            {
                canvasId = "cardReward",

                x = x,
                y = CARD_Y,

                width = CARD_WIDTH,
                height = CARD_HEIGHT,

                text = card.name,
                font = "small",

                action = "selectRewardCard",
                index = index,

                color = {
                    r = color.r,
                    g = color.g,
                    b = color.b
                }
            }
        )

    registry:add(
        entity,
        "rewardCard",
        {
            cardId = cardId,
            index = index,

            originalX = x,
            originalY = CARD_Y,

            originalWidth = CARD_WIDTH,
            originalHeight = CARD_HEIGHT,

            originalColor = {
                r = color.r,
                g = color.g,
                b = color.b
            }
        }
    )

    registry:add(
        entity,
        "tooltip",
        {
            title = card.name,
            text = getTooltipText(card)
        }
    )
end

function CardRewardSetupSystem.setup(scene)
    local registry =
        scene.registry

    local gameState =
        registry:resource("gameState")

    if not gameState then
        return
    end

    ensureRewardState(gameState)

    local reward = gameState.run.cardReward

    local choices = generateChoices(gameState)

    registry:setResource(
        "cardRewardState",
        {
            selectedEntity = nil
        }
    )

    Canvas.create(
        registry,
        {
            id = "cardReward",
            active = true,
            interactive = true,
            blocksGameplay = false,
            navigation = "horizontal",
            selectedIndex = 1,
            priority = 10,
            dim = 0
        }
    )

    Canvas.createText(
        registry,
        {
            id = "cardRewardTitle",
            canvasId = "cardReward",

            x = 0,
            y = 35,
            width = 800,

            value = "CARD REWARD",
            font = "title",
            align = "center"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "cardRewardInstruction",
            canvasId = "cardReward",

            x = 0,
            y = 115,
            width = 800,

            value = "Choose 1 card",
            font = "normal",
            align = "center"
        }
    )

    for index, cardId in ipairs(choices) do
        createRewardCard(
            registry,
            cardId,
            index
        )
    end

    local rewardClaimed =
        reward.claimedKey
            == getClaimKey(
                gameState
            )

    Canvas.createButton(
        registry,
        {
            canvasId = "cardReward",

            x = 300,
            y = 470,

            width = 200,
            height = 60,

            text = rewardClaimed
                and "Continue"
                or "Select",

            font = "normal",

            action = rewardClaimed
                and "continueReward"
                or "confirmReward",

            index = 4,

            active = rewardClaimed
        }
    )
end

return CardRewardSetupSystem