--!strict
-- Spawns placeholder training stations inside the StarterMap so players can
-- boost pet stats on day one.  Designers can replace these with bespoke models
-- later; the service simply wires up ProximityPrompts to PetService.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local PetService = require(ServerScriptService:WaitForChild("PetService"))

local TrainingService = {}

local STATIONS = {
    {
        Name = "PowerDummy",
        Label = "Punch Dummy",
        Position = Vector3.new(-10, 2, 50),
        Stat = "Power",
        Gain = 2,
    },
    {
        Name = "VitalityRings",
        Label = "Endurance Rings",
        Position = Vector3.new(0, 2, 55),
        Stat = "Vitality",
        Gain = 2,
    },
    {
        Name = "FocusStone",
        Label = "Focus Stone",
        Position = Vector3.new(10, 2, 50),
        Stat = "Focus",
        Gain = 2,
    },
}

local function createStation(parent: Instance, definition)
    local part = Instance.new("Part")
    part.Name = definition.Name
    part.Size = Vector3.new(4, 4, 4)
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.Slate
    part.CFrame = CFrame.new(definition.Position)
    part:SetAttribute("TrainingStat", definition.Stat)
    part:SetAttribute("StatGain", definition.Gain)
    part:SetAttribute("Cooldown", 4)
    part:SetAttribute("SessionLength", 1.5)
    part.Parent = parent

    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = definition.Label
    prompt.ActionText = "Train"
    prompt.HoldDuration = 1
    prompt.MaxActivationDistance = 8
    prompt.Parent = part

    local lastUse = {}
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        local previous = lastUse[player.UserId] or 0
        if now - previous < 4 then
            Remotes.TrainingPrompt:FireClient(player, {
                Success = false,
                Reason = "Catch your breath first!",
            })
            return
        end

        lastUse[player.UserId] = now
        task.delay(1.5, function()
            PetService:AddStat(player, definition.Stat, definition.Gain)
            Remotes.TrainingPrompt:FireClient(player, {
                Success = true,
                Stat = definition.Stat,
                Gain = definition.Gain,
            })
        end)
    end)
end

function TrainingService.Init()
    local map = Workspace:WaitForChild("StarterMap")
    local folder = map:FindFirstChild("TrainingStations") or Instance.new("Folder")
    folder.Name = "TrainingStations"
    folder.Parent = map

    for _, child in folder:GetChildren() do
        child:Destroy()
    end

    for _, definition in STATIONS do
        createStation(folder, definition)
    end
end

return TrainingService
