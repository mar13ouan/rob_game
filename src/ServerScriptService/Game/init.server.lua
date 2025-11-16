--!strict
-- Entry point for game-specific server logic. This script will eventually wire
-- gameplay systems together, but for now it ensures the module dependencies
-- load correctly and gives us a single place to expand the flow later.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Common.GameConfig)
local StateMachine = require(ReplicatedStorage.Common.StateMachine)

local GameController = {}

function GameController.Init()
    -- Prepare any stateful services or references the controller will need.
    GameController.Config = GameConfig
    GameController.StateMachine = StateMachine

    print(string.format(
        "[GameController] Initialized. Lobby duration: %ds",
        GameConfig.MATCH.LOBBY_DURATION
    ))
end

function GameController.Start()
    -- Stub that will eventually coordinate the state machine and gameplay flow.
    print("[GameController] Start called. Current state:", StateMachine.CurrentState)
end

GameController.Init()

return GameController
