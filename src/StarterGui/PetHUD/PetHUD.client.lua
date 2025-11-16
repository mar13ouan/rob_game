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
container.Size = UDim2.new(0, 280, 0, 240)
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

local evolutionSection = Instance.new("Frame")
evolutionSection.Position = UDim2.new(0, 10, 0, 126)
evolutionSection.Size = UDim2.new(1, -20, 0, 92)
evolutionSection.BackgroundTransparency = 0.2
evolutionSection.BackgroundColor3 = Color3.fromRGB(15, 20, 26)
evolutionSection.Parent = container

local evolutionCorner = Instance.new("UICorner")
evolutionCorner.CornerRadius = UDim.new(0, 6)
evolutionCorner.Parent = evolutionSection

local evolutionTitle = Instance.new("TextLabel")
evolutionTitle.BackgroundTransparency = 1
evolutionTitle.Font = Enum.Font.GothamSemibold
evolutionTitle.TextColor3 = Color3.fromRGB(255, 240, 200)
evolutionTitle.TextXAlignment = Enum.TextXAlignment.Left
evolutionTitle.Text = "Evolution Goals"
evolutionTitle.Size = UDim2.new(1, -10, 0, 20)
evolutionTitle.Position = UDim2.new(0, 6, 0, 4)
evolutionTitle.Parent = evolutionSection

local evolutionList = Instance.new("Frame")
evolutionList.BackgroundTransparency = 1
evolutionList.Position = UDim2.new(0, 6, 0, 26)
evolutionList.Size = UDim2.new(1, -12, 1, -32)
evolutionList.Parent = evolutionSection

local evolutionLayout = Instance.new("UIListLayout")
evolutionLayout.FillDirection = Enum.FillDirection.Vertical
evolutionLayout.Padding = UDim.new(0, 2)
evolutionLayout.Parent = evolutionList

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 0.35
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Position = UDim2.new(0, 10, 1, -44)
statusLabel.Size = UDim2.new(1, -20, 0, 34)
statusLabel.Visible = false
statusLabel.Parent = container

local dialogueFrame = Instance.new("Frame")
dialogueFrame.AnchorPoint = Vector2.new(0.5, 1)
dialogueFrame.Position = UDim2.new(0.5, 0, 1, -260)
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
local evolutionEntries: {[string]: TextLabel} = {}

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

local function formatEvolutionText(target)
    local progress = target.Progress or {}
    local statSegments = {}

    for statName, info in pairs(progress) do
        local current = info.Current or 0
        local required = info.Required or 0
        local remaining = info.SessionsRemaining or 0
        if remaining <= 0 then
            table.insert(statSegments, string.format("%s ready (%d/%d)", statName, current, required))
        else
            local plural = remaining == 1 and "training" or "trainings"
            table.insert(statSegments, string.format("%s %d/%d (%d %s left)", statName, current, required, remaining, plural))
        end
    end

    local requirementsText = #statSegments > 0 and table.concat(statSegments, " | ") or "Train to unlock"

    if target.Ready then
        return string.format("%s ready to evolve!", target.DisplayName), Color3.fromRGB(126, 255, 191)
    end

    return string.format("%s: %s", target.DisplayName, requirementsText), Color3.fromRGB(255, 214, 170)
end

local function syncEvolutions(targets)
    local active: {[string]: boolean} = {}
    for _, target in ipairs(targets or {}) do
        local label = evolutionEntries[target.Id]
        if not label then
            label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Parent = evolutionList
            evolutionEntries[target.Id] = label
        end

        local text, color = formatEvolutionText(target)
        label.Text = text
        label.TextColor3 = color
        label.Visible = true
        active[target.Id] = true
    end

    for id, label in pairs(evolutionEntries) do
        if not active[id] then
            label.Visible = false
        end
    end

    if not targets or #targets == 0 then
        evolutionTitle.Text = "Evolution Goals"
    end
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

    syncEvolutions(payload.EvolutionTargets)
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
