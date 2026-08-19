local GameState = {}

function GameState.new(seed)
    return {
        version = 0.1,

        player = {
            name = nil
        },

        run = {
            active = false,
            seed = seed,
            level = 1,
            deck = {},

            progression = {
                completedLevels = {}
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