--!strict
-- GameConfig centralizes all the tunable values that both the client and server
-- need to agree on. Keeping them here helps ensure we only have a single source
-- of truth for gameplay numbers.

local GameConfig = {
    PLAYER = {
        -- Default walk speed of the player humanoid.
        SPEED = 16,
        -- Number of lives a user starts a match with.
        STARTING_LIVES = 3,
    },

    MATCH = {
        -- How long the lobby phase lasts (seconds) before auto-start.
        LOBBY_DURATION = 30,
        -- How long a match lasts once it begins (seconds).
        MATCH_DURATION = 180,
        -- Time allowed to show post-match results (seconds).
        RESULTS_DURATION = 10,
    },

    OBJECT_IDS = {
        -- Developer-assigned identifiers for collectible or interactive objects.
        COIN = "Coin",
        POWER_CORE = "PowerCore",
        EXIT_PORTAL = "ExitPortal",
    },

    SCORES = {
        -- Score for collecting coins.
        COIN_VALUE = 10,
        -- Bonus applied when exiting with a Power Core.
        POWER_CORE_BONUS = 250,
    },
}

return GameConfig
