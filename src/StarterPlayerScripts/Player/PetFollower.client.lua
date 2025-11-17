--!strict
-- Keeps the player's companion model spawned and following slightly behind.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local PetLibrary = require(ReplicatedStorage:WaitForChild("Pets"))

local localPlayer = Players.LocalPlayer
local currentPetModel: Model? = nil
local followConnection: RBXScriptConnection? = nil

local function cleanupPet()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end

    if currentPetModel then
        currentPetModel:Destroy()
        currentPetModel = nil
    end
end

local function ensureCharacter()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
    return character, humanoidRootPart
end

local function startFollow()
    if followConnection then
        followConnection:Disconnect()
    end

    followConnection = RunService.Heartbeat:Connect(function()
        if not currentPetModel then
            return
        end

        local character = localPlayer.Character
        if not character then
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
            return
        end

        local targetCFrame = root.CFrame * CFrame.new(0, -1.5, 4)
        local currentCFrame = currentPetModel:GetPivot()
        local lerped = currentCFrame:Lerp(targetCFrame, 0.2)
        currentPetModel:PivotTo(lerped)
    end)
end

local function spawnPet(monsterId: string?)
    cleanupPet()
    if not monsterId then
        return
    end

    local _, root = ensureCharacter()
    local model = PetLibrary.CreatePetModel(monsterId)
    model.Parent = workspace
    currentPetModel = model
    model:PivotTo(root.CFrame * CFrame.new(0, -1.5, 4))
    startFollow()
end

localPlayer.CharacterAdded:Connect(function()
    if currentPetModel then
        startFollow()
    end
end)

Remotes.PetStatUpdated.OnClientEvent:Connect(function(payload)
    if payload.MonsterId then
        if currentPetModel and currentPetModel.Name == payload.MonsterId then
            return
        end

        spawnPet(payload.MonsterId)
    end
end)
