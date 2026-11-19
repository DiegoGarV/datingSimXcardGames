local GameState = {}

function GameState.new(seed)
    return {
        player = {
            name = nil
        },

        run = {
            active = false,
            seed = seed,
            level = 1,
            currentScene = "fight",
            deck = {},

            progression = {
                conquest = 1,
                attack = 1,
                protection = 1,
                completedLevels = {}
            },

            development = {
                actionsRemaining = 2
            }
        },

        settings = {
            masterVolume = 1,
            musicVolume = 1,
            soundVolume = 1
        }
    }
end

return GameState