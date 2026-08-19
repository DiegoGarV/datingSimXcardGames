local serialize = {}

local function isIdentifier(key)
    return type(key) == "string"
        and key:match("^[%a_][%w_]*$") ~= nil
end

local function serializeValue(value, indent, visited)
    local valueType = type(value)

    if valueType == "number"
        or valueType == "boolean" then

        return tostring(value)
    end

    if valueType == "string" then
        return ("%q"):format(value)
    end

    if valueType ~= "table" then
        error(
            "cannot serialize value of type "
            .. valueType
        )
    end

    if visited[value] then
        error("cycle detected")
    end

    visited[value] = true

    local pieces = {}
    local keys = {}

    for key in pairs(value) do
        keys[#keys + 1] = key
    end

    table.sort(
        keys,
        function(a, b)
            return tostring(a) < tostring(b)
        end
    )

    local innerIndent = indent .. "    "

    for _, key in ipairs(keys) do
        local keyType = type(key)
        local keyText

        if isIdentifier(key) then
            keyText = key

        elseif keyType == "number" then
            keyText = "[" .. tostring(key) .. "]"

        elseif keyType == "string" then
            keyText =
                "[" ..
                ("%q"):format(key) ..
                "]"

        else
            error(
                "cannot serialize key of type "
                .. keyType
            )
        end

        pieces[#pieces + 1] =
            innerIndent
            .. keyText
            .. " = "
            .. serializeValue(
                value[key],
                innerIndent,
                visited
            )
            .. ","
    end

    visited[value] = nil

    if #pieces == 0 then
        return "{}"
    end

    return
        "{\n"
        .. table.concat(pieces, "\n")
        .. "\n"
        .. indent
        .. "}"
end

function serialize.encode(data)
    assert(
        type(data) == "table",
        "can only serialize a table"
    )

    return "return "
        .. serializeValue(
            data,
            "",
            {}
        )
end

function serialize.decode(text)
    if type(text) ~= "string" then
        return nil
    end

    local chunk = loadstring(text)

    if not chunk then
        return nil
    end

    setfenv(chunk, {})

    local ok, data = pcall(chunk)

    if not ok or type(data) ~= "table" then
        return nil
    end

    return data
end

return serialize