local Canvas = require("src.ui.Canvas")

local DevelopmentSetupSystem = {}

DevelopmentSetupSystem.name = "DevelopmentSetupSystem"

local function ensureProgression(gameState)
    if not gameState.run.progression then
        gameState.run.progression = {}
    end

    local progression = gameState.run.progression

    progression.conquest =
        progression.conquest or 1

    progression.attack =
        progression.attack or 1

    progression.protection =
        progression.protection or 1
end

local function createStat(
    registry,
    id,
    title,
    description,
    buttonText,
    action,
    x
)
    Canvas.createPanel(registry, {
        canvasId = "development",
        x = x,
        y = 160,
        width = 220,
        height = 262,

        color = {
            r = 0.15,
            g = 0.15,
            b = 0.18
        }
    })

    Canvas.createText(registry, {
        id = id .. "Title",
        canvasId = "development",

        x = x,
        y = 180,
        width = 220,

        value = title,
        font = "normal",
        align = "center"
    })

    Canvas.createText(registry, {
        id = id .. "Level",
        canvasId = "development",

        x = x,
        y = 225,
        width = 220,

        value = "Level 1",
        font = "normal",
        align = "center"
    })

    Canvas.createText(registry, {
        id = id .. "Description",
        canvasId = "development",

        x = x + 15,
        y = 270,
        width = 190,

        value = description,
        font = "small",
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "development",

        x = x + 20,
        y = 350,
        width = 180,
        height = 50,

        text = buttonText,
        action = action,
        index = action == "trainConquest" and 1
            or action == "trainAttack" and 2
            or 3,

        font = "small",
        active = true
    })
end

local function ensureDevelopment(gameState)
    if not gameState.run.development then
        gameState.run.development = {
            actionsRemaining = 2
        }
    end

    if gameState.run.development.actionsRemaining == nil then
        gameState.run.development.actionsRemaining = 2
    end
end

function DevelopmentSetupSystem.setup(scene)
    local registry = scene.registry
    local gameState =
        registry:resource("gameState")

    if gameState then
        ensureProgression(gameState)
        ensureDevelopment(gameState)
    end

    local actionsRemaining = 2

    if gameState then
        actionsRemaining =
            gameState.run.development.actionsRemaining
    end

    registry:setResource(
        "developmentState",
        {
            feedback = "Choose how to develop."
        }
    )

    Canvas.create(registry, {
        id = "development",
        active = true,
        interactive = true,
        blocksGameplay = false,
        navigation = "horizontal",
        selectedIndex = 1,
        priority = 10,
        dim = 0
    })

    Canvas.createText(registry, {
        id = "developmentTitle",
        canvasId = "development",

        x = 0,
        y = 40,
        width = 800,

        value = "DEVELOPMENT",
        font = "title",
        align = "center"
    })

    Canvas.createText(registry, {
        id = "actionsRemaining",
        canvasId = "development",

        x = 0,
        y = 110,
        width = 800,

        value = "Actions Remaining: " .. tostring(actionsRemaining),
        font = "normal",
        align = "center"
    })

    createStat(
        registry,
        "conquest",
        "CONQUEST",
        "Improve your ability to build relationships.",
        "Practice Charm",
        "trainConquest",
        45
    )

    createStat(
        registry,
        "attack",
        "ATTACK",
        "Improve your ability to sabotage your rival.",
        "Study Sabotage",
        "trainAttack",
        290
    )

    createStat(
        registry,
        "protection",
        "PROTECTION",
        "Improve your ability to resist rival actions.",
        "Train Defense",
        "trainProtection",
        535
    )

    Canvas.createText(registry, {
        id = "developmentFeedback",
        canvasId = "development",

        x = 100,
        y = 445,
        width = 600,

        value = "Choose how to develop.",
        font = "normal",
        align = "center"
    })

    Canvas.createButton(registry, {
        canvasId = "development",

        x = 300,
        y = 500,
        width = 200,
        height = 60,

        text = "Continue",
        action = "continueDevelopment",
        index = 4,

        active = false
    })
end

return DevelopmentSetupSystem