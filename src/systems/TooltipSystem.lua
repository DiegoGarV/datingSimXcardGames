local GameConfig = require("src.GameConfig")
local Canvas = require("src.ui.Canvas")
local HitTest = require("src.ui.HitTest")

local TooltipSystem = {}

TooltipSystem.name = "TooltipSystem"
TooltipSystem.runWhenCanvasBlocked = true

local OFFSET_X = 15
local OFFSET_Y = 15
local WIDTH = 240
local PADDING = 12

function TooltipSystem.setup(scene)
    scene.registry:setResource("tooltipState", {
        entity = nil,
        tooltip = nil,
        x = 0,
        y = 0
    })
end

local function findHoveredTooltip(registry, x, y)
    for entity,
        position,
        rectangle,
        tooltip
    in
        registry:each(
            "position",
            "rectangle",
            "tooltip"
        )
    do
        if HitTest.rectangle(
            position,
            rectangle,
            x,
            y
        ) then
            return entity, tooltip
        end
    end

    return nil, nil
end

local function getTooltipHeight(titleFont, textFont, tooltip)
    local _, textLines =
        textFont:getWrap(
            tooltip.text or "",
            WIDTH - PADDING * 2
        )

    local titleHeight = titleFont:getHeight()
    local textHeight =
        #textLines * textFont:getHeight()

    return PADDING
        + titleHeight
        + 8
        + textHeight
        + PADDING
end

function TooltipSystem.update(scene, dt)
    local registry = scene.registry
    local input = registry:resource("input")
    local state = registry:resource("tooltipState")

    if not input or not state then
        return
    end

    state.entity = nil
    state.tooltip = nil

    if Canvas.blocksGameplay(registry) then
        return
    end

    local entity, tooltip =
        findHoveredTooltip(
            registry,
            input.mouse.x,
            input.mouse.y
        )

    if not tooltip then
        return
    end

    state.entity = entity
    state.tooltip = tooltip
    state.x = input.mouse.x + OFFSET_X
    state.y = input.mouse.y + OFFSET_Y
end

function TooltipSystem.draw(scene)
    local registry = scene.registry
    local state = registry:resource("tooltipState")

    if not state or not state.tooltip then
        return
    end

    local _, resources =
        registry:first("uiResources")

    if not resources then
        return
    end

    local tooltip = state.tooltip
    local titleFont = resources.fonts.button
    local textFont = resources.fonts.normal

    local height =
        getTooltipHeight(
            titleFont,
            textFont,
            tooltip
        )

    local x = state.x
    local y = state.y

    if x + WIDTH > GameConfig.width then
        x = GameConfig.width - WIDTH - 10
    end

    if y + height > GameConfig.height then
        y = GameConfig.height - height - 10
    end

    love.graphics.setColor(
        0.12,
        0.12,
        0.16,
        0.95
    )

    love.graphics.rectangle(
        "fill",
        x,
        y,
        WIDTH,
        height,
        8,
        8
    )

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setLineWidth(2)

    love.graphics.rectangle(
        "line",
        x,
        y,
        WIDTH,
        height,
        8,
        8
    )

    love.graphics.setFont(titleFont)

    love.graphics.print(
        tooltip.title or "",
        x + PADDING,
        y + PADDING
    )

    love.graphics.setFont(textFont)

    love.graphics.printf(
        tooltip.text or "",
        x + PADDING,
        y + PADDING + titleFont:getHeight() + 8,
        WIDTH - PADDING * 2,
        "left"
    )

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setLineWidth(1)
end

return TooltipSystem