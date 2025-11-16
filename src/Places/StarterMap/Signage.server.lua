--!strict
-- Creates a wooden placard near the training grounds so players immediately see
-- how many sessions they need for each evolution path.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MonsterConfig = require(ServerScriptService:WaitForChild("MonsterConfig"))
local TrainingConfig = require(ReplicatedStorage.Common.TrainingConfig)

local map = script.Parent
if not map or not map:IsA("Model") then
    warn("[Signage] Expected script parent to be the StarterMap model")
    return
end

local function ensurePart(model: Instance, name: string, size: Vector3, position: CFrame)
    local part = model:FindFirstChild(name)
    if not (part and part:IsA("BasePart")) then
        part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part.Material = Enum.Material.Wood
        part.Color = Color3.fromRGB(124, 92, 62)
        part.CanCollide = true
        part.Parent = model
    end

    part.Size = size
    part.CFrame = position
    return part
end

local placard = map:FindFirstChild("EvolutionPlacard")
if not placard then
    placard = Instance.new("Model")
    placard.Name = "EvolutionPlacard"
    placard.Parent = map
end

local boardPosition = CFrame.new(0, 4.5, 40) * CFrame.Angles(0, math.rad(180), 0)
local board = ensurePart(placard, "Board", Vector3.new(10, 5, 0.5), boardPosition)
local post = ensurePart(placard, "Post", Vector3.new(0.6, 5, 0.6), CFrame.new(0, 2.5, 40))
post.Color = board.Color

local function ensureSurfaceGui()
    local gui = board:FindFirstChild("EvolutionText")
    if not (gui and gui:IsA("SurfaceGui")) then
        gui = Instance.new("SurfaceGui")
        gui.Name = "EvolutionText"
        gui.Adornee = board
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(512, 256)
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.Parent = board
    end

    local label = gui:FindFirstChild("Label")
    if not (label and label:IsA("TextLabel")) then
        label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(255, 248, 224)
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextSize = 26
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Parent = gui
    end

    return label
end

local label = ensureSurfaceGui()

local function sessionsNeeded(baseStat: number, requirement: number, statName: string)
    local diff = math.max(0, requirement - baseStat)
    local gain = TrainingConfig.GetStatGain(statName)
    if gain <= 0 then
        return 0
    end

    return math.max(0, math.ceil(diff / gain))
end

local function buildText()
    local pet = MonsterConfig.Sproutling
    if not pet then
        return "Train hard to evolve!"
    end

    local lines = {
        "TRAINING BOARD",
        string.format("Each session = +%d stat points.", TrainingConfig.GetStatGain("Power")),
        "Choose a focus to decide your evolution:",
    }

    for _, evolution in pet.Evolutions do
        local reqText = {}
        for statName, requirement in pairs(evolution.Requirements or {}) do
            local base = pet.BaseStats[statName] or 0
            local sessions = sessionsNeeded(base, requirement, statName)
            table.insert(reqText, string.format("%s %d trainings", statName, sessions))
        end

        if #reqText > 0 then
            table.insert(lines, string.format("%s -> %s", table.concat(reqText, " + "), evolution.DisplayName))
        end
    end

    return table.concat(lines, "\n")
end

label.Text = buildText()
