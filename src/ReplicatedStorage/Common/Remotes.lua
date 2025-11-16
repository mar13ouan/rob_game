--!strict
-- Simple helper that returns typed references to every RemoteEvent/Function.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local PetEvents = RemotesFolder:WaitForChild("PetEvents")

local Remotes = {
    Folder = RemotesFolder,
    StarterGuideDialogue = RemotesFolder:WaitForChild("StarterGuideDialogue"),
    PetEvents = PetEvents,
    PetStatUpdated = PetEvents:WaitForChild("PetStatUpdated"),
    PetEvolution = PetEvents:WaitForChild("PetEvolution"),
    TrainingPrompt = PetEvents:WaitForChild("TrainingPrompt"),
}

return Remotes
