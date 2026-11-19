local CardDefinitions = {}

CardDefinitions.cards = {
    -- CARTAS DE CONQUISTA
    {
        id = "flirt",
        name = "Flirt",
        category = "conquest",
        rarity = "common",
        cost = 1,
        requiredLevel = 1,
        effect = "Gain 8 Relationship."
    },

    {
        id = "sweetTalk",
        name = "Sweet Talk",
        category = "conquest",
        rarity = "uncommon",
        cost = 1,
        requiredLevel = 1,
        effect = "Gain 12 Relationship."
    },

    {
        id = "grandGesture",
        name = "Grand Gesture",
        category = "conquest",
        rarity = "rare",
        cost = 2,
        requiredLevel = 3,
        effect = "Gain 20 Relationship."
    },


    -- CARTAS DE ATAQUE
    {
        id = "teaseRival",
        name = "Tease Rival",
        category = "attack",
        rarity = "common",
        cost = 1,
        requiredLevel = 1,
        effect = "Reduce the rival's Relationship by 6."
    },

    {
        id = "jealousy",
        name = "Jealousy",
        category = "attack",
        rarity = "uncommon",
        cost = 1,
        requiredLevel = 1,
        effect = "Reduce the rival's Relationship by 10."
    },

    {
        id = "publicEmbarrassment",
        name = "Public Embarrassment",
        category = "attack",
        rarity = "rare",
        cost = 2,
        requiredLevel = 3,
        effect = "Greatly reduce the rival's Relationship."
    },


    -- CARTAS DE DEFENSA
    {
        id = "keepCalm",
        name = "Keep Calm",
        category = "protection",
        rarity = "common",
        cost = 1,
        requiredLevel = 1,
        effect = "Reduce the next sabotage effect."
    },

    {
        id = "counterMove",
        name = "Counter Move",
        category = "protection",
        rarity = "uncommon",
        cost = 1,
        requiredLevel = 1,
        effect = "Strongly reduce the next sabotage effect."
    },

    {
        id = "unshakableConfidence",
        name = "Unshakable Confidence",
        category = "protection",
        rarity = "rare",
        cost = 2,
        requiredLevel = 3,
        effect = "Greatly reduce the next sabotage effect."
    }
}

function CardDefinitions.get(id)
    for _, card in ipairs(CardDefinitions.cards) do
        if card.id == id then
            return card
        end
    end

    return nil
end

return CardDefinitions