local Canvas =
    require("src.ui.Canvas")

local RoadmapSetupSystem = {}

RoadmapSetupSystem.name =
    "RoadmapSetupSystem"

function RoadmapSetupSystem.setup(
    scene
)
    local registry =
        scene.registry

    Canvas.create(
        registry,
        {
            id = "roadmap",
            active = true,
            interactive = true,
            blocksGameplay = false,
            navigation = "vertical",
            selectedIndex = 1,
            priority = 10,
            dim = 0
        }
    )

    Canvas.createText(
        registry,
        {
            id = "roadmapTitle",
            canvasId = "roadmap",

            x = 100,
            y = 120,
            width = 600,

            value = "ROADMAP",
            font = "title",
            align = "center"
        }
    )

    Canvas.createText(
        registry,
        {
            id = "roadmapPlaceholder",
            canvasId = "roadmap",

            x = 150,
            y = 230,
            width = 500,

            value =
                "Roadmap placeholder",
            font = "normal",
            align = "center"
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "roadmap",

            x = 300,
            y = 360,

            width = 200,
            height = 55,

            text = "Inventory",
            font = "button",

            action =
                "openInventory",

            index = 1
        }
    )

    Canvas.createButton(
        registry,
        {
            canvasId = "roadmap",

            x = 300,
            y = 435,

            width = 200,
            height = 55,

            text = "Fight",
            font = "button",

            action = "startFight",

            index = 2
        }
    )
end

return RoadmapSetupSystem