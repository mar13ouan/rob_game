--!strict
-- Entry point for game-specific server logic. This script will eventually wire
-- gameplay systems together, but for now it ensures the module dependencies
-- load correctly and gives us a single place to expand the flow later.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local PetService = require(script.Parent.Parent:WaitForChild("PetService"))
local StarterEggService = require(script.Parent.Parent:WaitForChild("StarterEggService"))
local TrainingService = require(script.Parent.Parent:WaitForChild("TrainingService"))

local GameConfig = require(ReplicatedStorage.Common.GameConfig)
local StateMachine = require(ReplicatedStorage.Common.StateMachine)

local GameController = {}

function GameController.Init()
    -- Prepare any stateful services or references the controller will need.
    GameController.Config = GameConfig
    GameController.StateMachine = StateMachine
    GameController.Remotes = Remotes

    PetService.Init()
    StarterEggService.Init(PetService)
    TrainingService.Init()

    -- Guarantee each player receives their starter companion without needing
    -- to manually trigger the NPC dialogue first.
    Players.PlayerAdded:Connect(function(player)
        task.delay(0.1, function()
            local granted, message = StarterEggService:TryAwardStarterEgg(player)
            if granted then
                Remotes.StarterGuideDialogue:FireClient(player, {
                    Granted = true,
                    Message = message,
                    Dialogue = StarterEggService:GetAwardDialogue(),
                })
            end
        end)
    end)

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
