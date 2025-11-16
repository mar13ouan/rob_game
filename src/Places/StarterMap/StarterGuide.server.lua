--!strict
-- Script that should be parented under the StarterGuide NPC model.  It listens
-- for the player to interact via a ProximityPrompt and delegates to the
-- StarterEggService to check whether the egg can be granted.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StarterEggService = require(ServerScriptService:WaitForChild("StarterEggService"))
local Remotes = require(ReplicatedStorage.Common.Remotes)

local guideModel = script.Parent:WaitForChild("StarterGuideNPC", 10)
if not guideModel or not guideModel:IsA("Model") then
    warn("[StarterGuide] Unable to find StarterGuideNPC model in StarterMap")
    return
end

local prompt: ProximityPrompt? = guideModel:FindFirstChildWhichIsA("ProximityPrompt", true)

if not prompt then
    warn("[StarterGuide] No ProximityPrompt found under StarterGuide NPC.")
    return
end

prompt.Triggered:Connect(function(player)
    local granted, message = StarterEggService:TryAwardStarterEgg(player)

    Remotes.StarterGuideDialogue:FireClient(player, {
        Granted = granted,
        Message = message,
        Dialogue = StarterEggService:GetAwardDialogue(),
    })
end)
