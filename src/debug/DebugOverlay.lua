local imlove = require("lib.imlove")
local GameConfig = require("src.GameConfig")
local SceneManager = require("src.ecs.SceneManager")

local DebugOverlay = {}

local visible = false
local paused = false
local stepOnce = false

local selectedEntity = nil
local selectedComponent = 1
local inspectedScene = nil

local gameCanvas = nil
local fontInstalled = false
local headingFont = nil
local labelFont = nil

local TOP_BAR_HEIGHT = 28
local LEFT_PANEL_WIDTH = 270
local RIGHT_PANEL_WIDTH = 320
local BOTTOM_PANEL_HEIGHT = 120
local MARGIN = 10
local GAP = 8

local DEBUG_WINDOW_WIDTH = LEFT_PANEL_WIDTH + GameConfig.width + RIGHT_PANEL_WIDTH + MARGIN * 2 + GAP * 2
local DEBUG_WINDOW_HEIGHT = TOP_BAR_HEIGHT + GameConfig.height + BOTTOM_PANEL_HEIGHT + MARGIN * 2 + GAP * 2

local layout = {}

local LIT = {0.16, 0.53, 0.90, 1.00}
local DIM = {0.50, 0.50, 0.50, 1.00}

local editableStringFields = {
    value = true,
    text = true,
    name = true
}

local function installFont()
    if fontInstalled then
        return
    end

    fontInstalled = true

    local symbolFont = love.graphics.newFont(
        "lib/fonts/NotoSansSymbols2-Regular.ttf",
        13
    )

    local ui = love.graphics.newFont(13)
    ui:setFallbacks(symbolFont)

    headingFont = love.graphics.newFont(17)
    headingFont:setFallbacks(symbolFont)

    labelFont = love.graphics.newFont(14)
    labelFont:setFallbacks(symbolFont)

    imlove.io.FontDefault = ui
end

local function ensureCanvas()
    if gameCanvas then
        return
    end

    gameCanvas = love.graphics.newCanvas(GameConfig.width, GameConfig.height)
end

local function updateLayout()
    layout.top = {
        x = MARGIN,
        y = MARGIN,
        w = DEBUG_WINDOW_WIDTH - MARGIN * 2,
        h = TOP_BAR_HEIGHT
    }

    layout.left = {
        x = MARGIN,
        y = MARGIN + TOP_BAR_HEIGHT + GAP,
        w = LEFT_PANEL_WIDTH,
        h = GameConfig.height
    }

    layout.game = {
        x = MARGIN + LEFT_PANEL_WIDTH + GAP,
        y = MARGIN + TOP_BAR_HEIGHT + GAP,
        w = GameConfig.width,
        h = GameConfig.height
    }

    layout.right = {
        x = MARGIN + LEFT_PANEL_WIDTH + GAP + GameConfig.width + GAP,
        y = MARGIN + TOP_BAR_HEIGHT + GAP,
        w = RIGHT_PANEL_WIDTH,
        h = GameConfig.height
    }

    layout.bottom = {
        x = MARGIN,
        y = MARGIN + TOP_BAR_HEIGHT + GameConfig.height + GAP * 2,
        w = DEBUG_WINDOW_WIDTH - MARGIN * 2,
        h = BOTTOM_PANEL_HEIGHT
    }
end

local LABEL_COLOR = {0.65, 0.75, 0.95, 1}

local function drawHeading(text)
    imlove.PushFont(headingFont)
    imlove.Text("%s", text)
    imlove.PopFont()
end

local function drawFieldLabel(text)
    imlove.PushFont(labelFont)
    imlove.TextColored(
        LABEL_COLOR,
        "%s",
        text
    )
    imlove.PopFont()
end

local function fieldSpacing()
    imlove.Text("")
end

local function applyWindowMode()
    if visible then
        love.window.setMode(DEBUG_WINDOW_WIDTH, DEBUG_WINDOW_HEIGHT)
    else
        love.window.setMode(GameConfig.width, GameConfig.height)
    end
end

local function transportButton(label, lit, enabled)
    if lit then
        imlove.PushStyleColor("button", LIT)
    end

    if not enabled then
        imlove.PushStyleColor("text", DIM)
    end

    local clicked = imlove.Button(label, 20, 20)

    if not enabled then
        imlove.PopStyleColor()
    end

    if lit then
        imlove.PopStyleColor()
    end

    return clicked and enabled
end

local function drawSystems(scene)
    for index, system in ipairs(scene.systems) do
        local name = system.name or ("System " .. index)

        local enabled = imlove.Checkbox(
            name,
            not scene.disabledSystems[system]
        )

        scene.disabledSystems[system] = (not enabled) or nil
    end
end

local function drawEntityList(scene)
    local registry = scene.registry

    if imlove.BeginChild("entityList", 0, 250, true) then
        for _, entity in ipairs(registry:entities()) do
            imlove.PushID(entity)

            local components = registry:componentsOf(entity)
            local label = tostring(entity) .. ": " .. table.concat(components, " ")

            if imlove.Selectable(label, selectedEntity == entity) then
                selectedEntity = entity
                selectedComponent = 1
            end

            imlove.PopID()
        end
    end

    imlove.EndChild()
end

local function drawComponent(registry, entity, componentName)
    local component = registry:get(entity, componentName)

    if not component then
        return
    end

    local keys = {}

    for key in pairs(component) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b)
        local valueA = component[a]
        local valueB = component[b]

        local editableA =
            type(valueA) == "number"
            or type(valueA) == "boolean"
            or (
                type(valueA) == "string"
                and editableStringFields[a]
            )

        local editableB =
            type(valueB) == "number"
            or type(valueB) == "boolean"
            or (
                type(valueB) == "string"
                and editableStringFields[b]
            )

        if editableA ~= editableB then
            return not editableA
        end

        return tostring(a) < tostring(b)
    end)

    for _, key in ipairs(keys) do
        local value = component[key]
        local label = tostring(key)

        imlove.PushID(label)

        drawFieldLabel(label)

        if type(value) == "number" then
            local newValue = imlove.SliderFloat(
                "##slider",
                value,
                -1000,
                1000
            )

            imlove.SameLine()

            newValue = imlove.InputFloat(
                "##input",
                newValue
            )

            component[key] = newValue

        elseif type(value) == "boolean" then
            component[key] = imlove.Checkbox(
                "##value",
                value
            )

        elseif type(value) == "string" then
            if editableStringFields[key] then
                component[key] = imlove.InputText(
                    "##value",
                    value
                )
            else
                imlove.TextDisabled(
                    "%s",
                    value
                )
            end

        else
            imlove.TextDisabled(
                "%s",
                tostring(value)
            )
        end

        fieldSpacing()

        imlove.PopID()
    end
end

local function drawSelectedEntity(scene)
    local registry = scene.registry

    if not selectedEntity then
        return
    end

    local components = registry:componentsOf(selectedEntity)

    if #components == 0 then
        selectedEntity = nil
        selectedComponent = 1
        return
    end

    drawHeading("Entity " .. selectedEntity)

    fieldSpacing()

    if selectedComponent > #components then
        selectedComponent = 1
    end

    drawFieldLabel("Components")

    selectedComponent = imlove.Combo(
        "##component",
        selectedComponent,
        components
    )

    fieldSpacing()

    local componentName = components[selectedComponent]

    if componentName then
        drawComponent(
            registry,
            selectedEntity,
            componentName
        )
    end
end

local function buildTopBar(scene)
    imlove.SetNextWindowPos(layout.top.x, layout.top.y, "always")
    imlove.SetNextWindowSize(layout.top.w, layout.top.h, "always")
    imlove.PushStyleVar("windowPadding", 4)

    if imlove.Begin("TopBar", nil, { "NoTitleBar", "NoResize", "NoMove" }) then
        imlove.Text("Scene: %s", scene.name)

        local controlsWidth = 100
        local controlsX = (layout.top.w - controlsWidth) / 2
        imlove.SameLine(controlsX)

        if transportButton("▶", not paused, true) then
            paused = false
        end

        imlove.SameLine()
        if transportButton("⏸", paused, true) then
            paused = true
        end

        imlove.SameLine()
        if transportButton("⏭", false, paused) then
            stepOnce = true
        end

        local fpsText = "FPS: " .. tostring(love.timer.getFPS())
        local fpsWidth = imlove.io.FontDefault:getWidth(fpsText)
        imlove.SameLine(layout.top.w - fpsWidth - 30)

        drawFieldLabel(fpsText)
    end

    imlove.End()
    imlove.PopStyleVar()
end

local function buildLeftPanel(scene)
    imlove.SetNextWindowPos(layout.left.x, layout.left.y, "always")
    imlove.SetNextWindowSize(layout.left.w, layout.left.h, "always")

    if imlove.Begin("Hierarchy", nil, { "NoResize", "NoMove" }) then
        if imlove.CollapsingHeader("Systems", true) then
            drawSystems(scene)
        end

        if imlove.CollapsingHeader("Entities", true) then
            drawEntityList(scene)
        end
    end

    imlove.End()
end

local function buildRightPanel(scene)
    imlove.SetNextWindowPos(layout.right.x, layout.right.y, "always")
    imlove.SetNextWindowSize(layout.right.w, layout.right.h, "always")

    if imlove.Begin("Inspector", nil, { "NoResize", "NoMove" }) then
        drawSelectedEntity(scene)
    end

    imlove.End()
end

local function buildBottomPanel(scene)
    imlove.SetNextWindowPos(layout.bottom.x, layout.bottom.y, "always")
    imlove.SetNextWindowSize(layout.bottom.w, layout.bottom.h, "always")

    if imlove.Begin("Scenes", nil, { "NoResize", "NoMove" }) then
        for i, sceneName in ipairs(SceneManager.sceneNames()) do
            if i > 1 then
                imlove.SameLine()
            end

            if imlove.Button(sceneName) then
                scene.registry:spawn({
                    sceneChangeRequest = {
                        target = sceneName
                    }
                })
            end
        end
    end

    imlove.End()
end

local function drawGameFrame()
    local game = layout.game

    love.graphics.setColor(0.10, 0.10, 0.11, 1)
    -- love.graphics.setColor(0.35, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", 0, 0, DEBUG_WINDOW_WIDTH, DEBUG_WINDOW_HEIGHT)

    love.graphics.setColor(0.08, 0.08, 0.09, 1)
    love.graphics.rectangle("fill", game.x - 3, game.y - 3, game.w + 6, game.h + 6)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, game.x, game.y)

    love.graphics.setColor(0.75, 0.75, 0.78, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", game.x - 1, game.y - 1, game.w + 2, game.h + 2)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

function DebugOverlay.toggle()
    visible = not visible

    if not visible then
        paused = false
        stepOnce = false
    end

    applyWindowMode()
    updateLayout()
end

function DebugOverlay.isVisible()
    return visible
end

function DebugOverlay.beginFrame(scene)
    if not visible then
        return
    end

    installFont()
    ensureCanvas()
    updateLayout()
    imlove.NewFrame()

    if scene ~= inspectedScene then
        inspectedScene = scene
        selectedEntity = nil
        selectedComponent = 1
    end

    if not scene then
        return
    end

    buildTopBar(scene)
    buildLeftPanel(scene)
    buildRightPanel(scene)
    buildBottomPanel(scene)
end

function DebugOverlay.shouldUpdate()
    if not visible or not paused then
        return true
    end

    if stepOnce then
        stepOnce = false
        return true
    end

    return false
end

function DebugOverlay.draw(gameDraw)
    if not visible then
        gameDraw()
        return
    end

    ensureCanvas()
    updateLayout()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    gameDraw()
    love.graphics.setCanvas()

    drawGameFrame()
    imlove.Render()
end

function DebugOverlay.keypressed(key)
    if key == "f1" then
        DebugOverlay.toggle()
        return true
    end

    if not visible then
        return false
    end

    if key == "f9" and visible then
        paused = not paused
        return true
    end

    if key == "f10" and visible then
        if paused then
            stepOnce = true
        end

        return true
    end

    return imlove.keypressed(key)
end

function DebugOverlay.textinput(text)
    if not visible then
        return false
    end

    return imlove.textinput(text)
end

function DebugOverlay.mousepressed(x, y, button)
    if not visible then
        return false
    end

    return imlove.mousepressed(x, y, button)
end

function DebugOverlay.mousereleased(x, y, button)
    if not visible then
        return false
    end
    return imlove.mousereleased(x, y, button)
end

function DebugOverlay.wheelmoved(dx, dy)
    if not visible then
        return false
    end

    return imlove.wheelmoved(dx, dy)
end

return DebugOverlay