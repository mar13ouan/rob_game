--!strict
-- Script that should be parented under the StarterGuide NPC model.  It listens
-- for the player to interact via a ProximityPrompt and delegates to the
-- StarterEggService to check whether the egg can be granted.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StarterEggService = require(ServerScriptService:WaitForChild("StarterEggService"))
local Remotes = require(ReplicatedStorage.Common.Remotes)

local guideModel = script.Parent
local prompt: ProximityPrompt? = guideModel:FindFirstChildWhichIsA("ProximityPrompt", true)

if not prompt then
    prompt = Instance.new("ProximityPrompt")
    prompt.Name = "StarterGuidePrompt"
    prompt.ActionText = "Talk"
    prompt.ObjectText = "Starter Guide"
    prompt.HoldDuration = 0.5
    prompt.Parent = guideModel:FindFirstChildWhichIsA("BasePart") or guideModel
end

prompt.Triggered:Connect(function(player)
    local granted, message = StarterEggService:TryAwardStarterEgg(player)

    Remotes.StarterGuideDialogue:FireClient(player, {
        Granted = granted,
        Message = message,
        Dialogue = StarterEggService:GetAwardDialogue(),
    })
end)
