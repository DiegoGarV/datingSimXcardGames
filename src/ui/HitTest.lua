local HitTest = {}

function HitTest.rectangle(position, rectangle, x, y)
    return x >= position.x
        and x <= position.x + rectangle.width
        and y >= position.y
        and y <= position.y + rectangle.height
end

function HitTest.circle(position, circle, x, y)
    local dx = x - position.x
    local dy = y - position.y

    return dx * dx + dy * dy
        <= circle.radius * circle.radius
end

return HitTest