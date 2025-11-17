--!strict
-- Minimal client bootstrap to verify Rojo linking and future remote connectivity.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Common.Remotes)

print(string.format("[Player] Connected to Remotes. Pet events ready: %s", Remotes.PetEvents.Name))
