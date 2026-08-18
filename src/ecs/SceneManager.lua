local SceneManager = {}
local currentScene = nil 
local currentSceneName = nil
local sceneFactories = {}

local frameEvents = {
    "keyPressed"
}

local function clearFrameEvents(scene)
    local registry = scene.registry

    for _, eventName in ipairs(frameEvents) do
        for _, entity in ipairs(registry:query(eventName)) do
            registry:destroy(entity)
        end
    end
end

function SceneManager.register(name, factory)
    sceneFactories[name] = factory
end

function SceneManager.current()
    return currentScene
end

function SceneManager.change(name, payload)
    local factory = sceneFactories[name]

    if not factory then
        -- Debug
        print("Error: no existe una escena registrada con el nombre: " .. tostring(name))
        return
    end

    -- Descargar la escena anterior
    if currentScene then
        currentScene:unload()
    end

    -- Crear la nueva escena
    currentSceneName = name
    currentScene = factory(payload)

    -- Ejecutar su setup
    currentScene:setup()

    print("Escena actual: " .. currentScene.name)
end

function SceneManager.update(dt)
    local scene = currentScene

    if not scene then
        return
    end

    scene:update(dt)
    clearFrameEvents(scene)

    local _, request = scene.registry:first("sceneChangeRequest")

    if not request then
        return
    end

    local target = request.target
    local payload = request.payload

    for _, entity in ipairs(scene.registry:query("sceneChangeRequest")) do
        scene.registry:destroy(entity)
    end

    SceneManager.change(target, payload)
end

function SceneManager.currentName()
    return currentSceneName
end

function SceneManager.draw()
    if currentScene then
        currentScene:draw()
    end
end

function SceneManager.keypressed(key)
    if not currentScene then
        return
    end

    currentScene.registry:spawn({
        keyPressed = {
            key = key
        }
    })
end

function SceneManager.sceneNames()
    local names = {}

    for name in pairs(sceneFactories) do
        names[#names + 1] = name
    end

    table.sort(names)

    return names
end

function SceneManager.unload()
    if currentScene then
        currentScene:unload()
        currentScene = nil
        currentSceneName = nil
    end
end

return SceneManager