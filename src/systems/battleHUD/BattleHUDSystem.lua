local Canvas = require("src.ui.Canvas")

local BattleHUDSystem = {}

BattleHUDSystem.name = "BattleHUDSystem"

local function updateBar(registry, id, value)
    for _, rectangle, hudBar in registry:each(
        "rectangle",
        "hudBar"
    ) do
        if hudBar.id == id then
            local percent = value.current / value.max

            percent = math.max(
                0,
                math.min(1, percent)
            )

            rectangle.width =
                hudBar.maxWidth * percent

            break
        end
    end

    Canvas.setText(
        registry,
        id .. "Value",
        tostring(value.current)
            .. " / "
            .. tostring(value.max)
    )
end

function BattleHUDSystem.update(scene, dt)
    local registry = scene.registry
    local battle = registry:resource("fightState")

    if not battle then
        return
    end

    updateBar(
        registry,
        "patience",
        battle.patience
    )

    updateBar(
        registry,
        "playerRelationship",
        battle.playerRelationship
    )

    updateBar(
        registry,
        "rivalRelationship",
        battle.rivalRelationship
    )

    Canvas.setText(
        registry,
        "energyText",
        tostring(battle.energy.current)
    )

    for _, tooltip, hudDeck in registry:each(
        "tooltip",
        "hudDeck"
    ) do
        tooltip.text =
            "Cards left: "
            .. tostring(battle.deck.current)
    end
end

return BattleHUDSystem