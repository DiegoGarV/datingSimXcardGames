-- FROM: https://github.com/denn1s/game-engine-v3/blob/02-ECS/src/ecs/Registry.lua

local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({
        nextEntity = 1,
        components = {},
    }, Registry)
end

function Registry:spawn(components)
    local entity = self.nextEntity
    self.nextEntity = entity + 1
    for name, data in pairs(components) do
        self:add(entity, name, data)
    end
    return entity
end

function Registry:add(entity, name, data)
    local store = self.components[name]
    if not store then
        store = {}
        self.components[name] = store
    end
    store[entity] = data
end

function Registry:get(entity, name)
    local store = self.components[name]
    return store and store[entity]
end

function Registry:destroy(entity)
    for _, store in pairs(self.components) do
        store[entity] = nil
    end
end

function Registry:entities()
    local seen = {}
    local result = {}

    for _, store in pairs(self.components) do
        for entity in pairs(store) do
            if not seen[entity] then
                seen[entity] = true
                result[#result + 1] = entity
            end
        end
    end

    table.sort(result)

    return result
end

function Registry:componentsOf(entity)
    local result = {}

    for name, store in pairs(self.components) do
        if store[entity] ~= nil then
            result[#result + 1] = name
        end
    end

    table.sort(result)

    return result
end

function Registry:query(...)
    local names = { ... }
    
    if #names == 0 then
        return {}
    end

    local first = self.components[names[1]] or {}
    local result = {}
    for entity in pairs(first) do
        local ok = true
        for i = 2, #names do
            local store = self.components[names[i]]
            if not store or store[entity] == nil then
                ok = false
                break
            end
        end
        if ok then
            result[#result + 1] = entity
        end
    end
    table.sort(result)
    return result
end

function Registry:each(...)
    local names = { ... }
    local entities = self:query(...)
    local i = 0
    return function()
        while true do
            i = i + 1
            local entity = entities[i]
            if not entity then return nil end
            local values, alive = {}, true
            for k, name in ipairs(names) do
                values[k] = self.components[name][entity]
                if values[k] == nil then -- destroyed since query(): skip it
                    alive = false
                    break
                end
            end
            if alive then
                -- LÖVE is LuaJIT (Lua 5.1): `unpack`, not `table.unpack`.
                -- Explicit bounds, because values could have nil holes.
                return entity, unpack(values, 1, #names)
            end
        end
    end
end

function Registry:first(name)
    local store = self.components[name]
    if store then
        for entity, data in pairs(store) do
            return entity, data
        end
    end
end

function Registry:remove(entity, name)
    local store = self.components[name]

    if store then
        store[entity] = nil
    end
end

return Registry