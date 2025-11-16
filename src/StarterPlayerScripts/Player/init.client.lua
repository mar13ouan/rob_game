--!strict
-- Minimal client bootstrap to verify Rojo linking and future remote connectivity.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

print(string.format("[Player] Connected to ReplicatedStorage.Remotes (%d children).", #Remotes:GetChildren()))
