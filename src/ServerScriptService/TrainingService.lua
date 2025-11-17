--!strict
-- Wires up the hand-crafted training stations that live inside the StarterMap.
-- Each station is a BasePart with TrainingStat/StatGain attributes and a
-- ProximityPrompt child that lets the player start a mini session.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local TrainingConfig = require(ReplicatedStorage.Common.TrainingConfig)
local PetService = require(ServerScriptService:WaitForChild("PetService"))

local TrainingService = {}

local WIRED_STATIONS: {[Instance]: boolean} = {}

local function getPrompt(station: BasePart)
    local prompt = station:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Name = "TrainPrompt"
        prompt.ActionText = "Train"
        prompt.ObjectText = station.Name
        prompt.HoldDuration = 1
        prompt.MaxActivationDistance = 8
        prompt.Parent = station
    end

    return prompt
end

local function wireStation(station: BasePart)
    if WIRED_STATIONS[station] then
        return
    end

    local statToTrain = station:GetAttribute("TrainingStat") or "Power"
    local statGain = station:GetAttribute("StatGain") or TrainingConfig.GetStatGain(statToTrain)
    local cooldown = station:GetAttribute("Cooldown") or TrainingConfig.DEFAULT_COOLDOWN
    local sessionLength = station:GetAttribute("SessionLength") or TrainingConfig.DEFAULT_SESSION_LENGTH

    local prompt = getPrompt(station)
    prompt.ObjectText = station:GetAttribute("DisplayName") or prompt.ObjectText
    prompt.ActionText = string.format("+%d %s", statGain, statToTrain)

    local lastUse: {[number]: number} = {}
    prompt.Triggered:Connect(function(player)
        local now = os.clock()
        local previous = lastUse[player.UserId] or 0
        if now - previous < cooldown then
            Remotes.TrainingPrompt:FireClient(player, {
                Success = false,
                Reason = "Catch your breath first!",
            })
            return
        end

        lastUse[player.UserId] = now
        task.delay(sessionLength, function()
            PetService:AddStat(player, statToTrain, statGain)
            Remotes.TrainingPrompt:FireClient(player, {
                Success = true,
                Stat = statToTrain,
                Gain = statGain,
            })
        end)
    end)

    WIRED_STATIONS[station] = true
end

local function connectFolder(folder: Instance)
    local function tryWire(instance: Instance)
        if instance:IsA("BasePart") and instance:GetAttribute("TrainingStat") then
            wireStation(instance)
        end
    end

    for _, descendant in folder:GetDescendants() do
        tryWire(descendant)
    end

    folder.DescendantAdded:Connect(tryWire)
end

function TrainingService.Init()
    local map = Workspace:WaitForChild("StarterMap")
    local stations = map:WaitForChild("TrainingStations", 10)
    if not stations then
        warn("[TrainingService] Could not find TrainingStations folder")
        return
    end

    connectFolder(stations)
end

return TrainingService
