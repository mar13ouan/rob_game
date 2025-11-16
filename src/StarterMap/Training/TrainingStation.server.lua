--!strict
-- Generic training station script.  Place it under a training prop with a
-- ProximityPrompt and set the attributes below to configure the stat gains.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local PetService = require(ServerScriptService:WaitForChild("PetService"))

local station = script.Parent
local prompt: ProximityPrompt? = station:FindFirstChildWhichIsA("ProximityPrompt", true)

if not prompt then
    warn("[TrainingStation] Missing ProximityPrompt under", station:GetFullName())
    return
end

local statToTrain = station:GetAttribute("TrainingStat") or "Power"
local statGain = station:GetAttribute("StatGain") or 1
local cooldown = station:GetAttribute("Cooldown") or 4
local sessionLength = station:GetAttribute("SessionLength") or 1.5

local cooldowns: {[number]: number} = {}

prompt.Triggered:Connect(function(player)
    local now = os.clock()
    local last = cooldowns[player.UserId] or 0
    if now - last < cooldown then
        Remotes.TrainingPrompt:FireClient(player, {
            Success = false,
            Reason = "Training station is recharging.",
        })
        return
    end

    cooldowns[player.UserId] = now
    task.delay(sessionLength, function()
        PetService:AddStat(player, statToTrain, statGain)
        Remotes.TrainingPrompt:FireClient(player, {
            Success = true,
            Stat = statToTrain,
            Gain = statGain,
        })
    end)
end)
