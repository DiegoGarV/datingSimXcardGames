local serialize = require("src.state.serialize")

local SaveFile = {
    FILENAME = "save.lua",
    VERSION = 1
}

function SaveFile.save(data)
    data.version = SaveFile.VERSION

    local encoded = serialize.encode(data)

    return love.filesystem.write(
        SaveFile.FILENAME,
        encoded
    )
end

function SaveFile.load()
    local text = love.filesystem.read(
        SaveFile.FILENAME
    )

    if not text then
        return nil
    end

    local data = serialize.decode(text)

    if not data then
        return nil
    end

    if data.version ~= SaveFile.VERSION then
        return nil
    end

    return data
end

function SaveFile.exists()
    return love.filesystem.getInfo(
        SaveFile.FILENAME,
        "file"
    ) ~= nil
end

function SaveFile.isValid()
    return SaveFile.load() ~= nil
end

function SaveFile.delete()
    if not SaveFile.exists() then
        return true
    end

    return love.filesystem.remove(
        SaveFile.FILENAME
    )
end

return SaveFile