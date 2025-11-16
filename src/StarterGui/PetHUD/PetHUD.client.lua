--!strict
-- Builds the Pet HUD at runtime and listens for remote updates about the pet's
-- stats, evolutions, and NPC dialogue.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Remotes)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0, 1)
container.Position = UDim2.new(0, 16, 1, -16)
container.Size = UDim2.new(0, 260, 0, 210)
container.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
container.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = container

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Text = "Pet Status"
title.Parent = container

local statsList = Instance.new("Frame")
statsList.Position = UDim2.new(0, 10, 0, 38)
statsList.Size = UDim2.new(1, -20, 0, 80)
statsList.BackgroundTransparency = 1
statsList.Parent = container

local statLabels: {[string]: TextLabel} = {}
local statNames = {"Power", "Vitality", "Focus", "Agility"}

for index, statName in ipairs(statNames) do
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(200, 230, 200)
    label.TextScaled = true
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 0, 0, (index - 1) * 18)
    label.Text = string.format("%s: 0", statName)
    label.Parent = statsList
    statLabels[statName] = label
end

local evolutionLabel = Instance.new("TextLabel")
evolutionLabel.BackgroundTransparency = 1
evolutionLabel.Font = Enum.Font.GothamSemibold
evolutionLabel.TextColor3 = Color3.fromRGB(255, 240, 200)
evolutionLabel.TextWrapped = true
evolutionLabel.TextXAlignment = Enum.TextXAlignment.Left
evolutionLabel.Position = UDim2.new(0, 10, 0, 122)
evolutionLabel.Size = UDim2.new(1, -20, 0, 36)
evolutionLabel.Text = "Next evolution: --"
evolutionLabel.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 0.35
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Position = UDim2.new(0, 10, 0, 162)
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Visible = false
statusLabel.Parent = container

local dialogueFrame = Instance.new("Frame")
dialogueFrame.AnchorPoint = Vector2.new(0.5, 1)
dialogueFrame.Position = UDim2.new(0.5, 0, 1, -230)
dialogueFrame.Size = UDim2.new(0, 320, 0, 120)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
dialogueFrame.BackgroundTransparency = 0.2
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = screenGui

local dialogueCorner = Instance.new("UICorner")
dialogueCorner.CornerRadius = UDim.new(0, 10)
dialogueCorner.Parent = dialogueFrame

local dialogueText = Instance.new("TextLabel")
dialogueText.BackgroundTransparency = 1
dialogueText.TextWrapped = true
dialogueText.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogueText.Font = Enum.Font.Gotham
dialogueText.TextXAlignment = Enum.TextXAlignment.Left
dialogueText.TextYAlignment = Enum.TextYAlignment.Top
dialogueText.Position = UDim2.new(0, 10, 0, 10)
dialogueText.Size = UDim2.new(1, -20, 1, -20)
dialogueText.Parent = dialogueFrame

dialogueText.Text = ""

local statusTweenId = 0
local dialogueTweenId = 0

local function showStatus(message: string)
    statusTweenId += 1
    local id = statusTweenId
    statusLabel.Visible = true
    statusLabel.Text = message
    task.delay(3, function()
        if statusTweenId == id then
            statusLabel.Visible = false
        end
    end)
end

local function showDialogue(lines)
    dialogueTweenId += 1
    local id = dialogueTweenId
    if typeof(lines) == "string" then
        lines = {lines}
    end

    dialogueFrame.Visible = true
    dialogueText.Text = table.concat(lines, "
")

    task.delay(5, function()
        if dialogueTweenId == id then
            dialogueFrame.Visible = false
        end
    end)
end

local function updateStats(payload)
    if payload.MonsterId then
        title.Text = string.format("%s Status", payload.MonsterId)
    end

    if payload.Stats then
        for statName, label in pairs(statLabels) do
            local value = payload.Stats[statName] or 0
            label.Text = string.format("%s: %d", statName, value)
        end
    end

    if payload.NextEvolution then
        local evo = payload.NextEvolution
        local reqText = {}
        for statName, requirement in pairs(evo.Requirements or {}) do
            table.insert(reqText, string.format("%s %d", statName, requirement))
        end
        evolutionLabel.Text = string.format(
            "Next evolution: %s (%s)",
            evo.DisplayName,
            table.concat(reqText, ", ")
        )
    else
        evolutionLabel.Text = "Next evolution: Final form reached"
    end
end

Remotes.PetStatUpdated.OnClientEvent:Connect(updateStats)

Remotes.PetEvolution.OnClientEvent:Connect(function(payload)
    updateStats(payload)
    showStatus(string.format("%s evolved!", payload.DisplayName))
end)

Remotes.TrainingPrompt.OnClientEvent:Connect(function(payload)
    if payload.Success then
        showStatus(string.format("+%d %s", payload.Gain or 0, payload.Stat or "Stat"))
    else
        showStatus(payload.Reason or "Training unavailable")
    end
end)

Remotes.StarterGuideDialogue.OnClientEvent:Connect(function(payload)
    if payload.Dialogue then
        showDialogue(payload.Dialogue)
    end

    if payload.Message then
        showStatus(payload.Message)
    end
end)
