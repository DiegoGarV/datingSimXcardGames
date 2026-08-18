local TestSetupSystem = {}

TestSetupSystem.name = "TestSetupSystem"

function TestSetupSystem.setup(scene)
    scene.registry:spawn({
        position = {
            x = 50,
            y = 275
        },

        velocity = {
            x = 150
        },

        rectangle = {
            width = 50,
            height = 50
        },

        color = {
            r = 0.2,
            g = 0.7,
            b = 1
        },

        testObject = {}
    })
end

return TestSetupSystem