--!strict
-- PetService manages the lifecycle of each player's companion: hatching,
-- stat tracking, and evolution checks.  It exposes remote updates so the
-- client HUD can reflect stat changes in real time.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Remotes)
local TrainingConfig = require(ReplicatedStorage.Common.TrainingConfig)
local MonsterConfig = require(script.Parent:WaitForChild("MonsterConfig"))

export type PetState = {
    Owner: Player,
    MonsterId: string,
    Stats: {
        Power: number,
        Vitality: number,
        Focus: number,
        Agility: number,
    },
    Experience: number,
}

local PetService = {}
PetService.__index = PetService
PetService._pets = {}

local function cloneStats(stats)
    return {
        Power = stats.Power,
        Vitality = stats.Vitality,
        Focus = stats.Focus,
        Agility = stats.Agility,
    }
end

local function getMonster(monsterId: string)
    local monster = MonsterConfig[monsterId]
    if not monster then
        error(string.format("[PetService] Unknown monster id '%s'", tostring(monsterId)))
    end

    return monster
end

function PetService:_buildEvolutionTargets(petState: PetState)
    local monster = getMonster(petState.MonsterId)
    local targets = {}

    for _, evolution in monster.Evolutions do
        local requirements = evolution.Requirements or {}
        local progress = {}
        local ready = true

        for stat, requirement in pairs(requirements) do
            local current = petState.Stats[stat] or 0
            local diff = math.max(0, requirement - current)
            if diff > 0 then
                ready = false
            end

            local statGain = TrainingConfig.GetStatGain(stat)
            local sessions = statGain > 0 and math.ceil(diff / statGain) or 0

            progress[stat] = {
                Current = current,
                Required = requirement,
                SessionsRemaining = diff <= 0 and 0 or sessions,
                StatGain = statGain,
            }
        end

        table.insert(targets, {
            Id = evolution.Id,
            DisplayName = evolution.DisplayName,
            Requirements = requirements,
            Progress = progress,
            Ready = ready,
        })
    end

    return targets
end

local function targetMargin(target)
    local margin = -math.huge
    for _, info in pairs(target.Progress or {}) do
        local diff = (info.Current or 0) - (info.Required or 0)
        if diff > margin then
            margin = diff
        end
    end

    if margin == -math.huge then
        margin = 0
    end

    return margin
end

function PetService:_publishPetState(player: Player, petState: PetState, targets)
    if not petState then
        return
    end

    local monster = getMonster(petState.MonsterId)
    Remotes.PetStatUpdated:FireClient(player, {
        MonsterId = petState.MonsterId,
        Stats = petState.Stats,
        Attacks = monster.Attacks,
        EvolutionTargets = targets or self:_buildEvolutionTargets(petState),
    })
end

function PetService:_tryEvolve(player: Player, petState: PetState, targets)
    local monster = getMonster(petState.MonsterId)
    if #monster.Evolutions == 0 then
        return false
    end

    targets = targets or self:_buildEvolutionTargets(petState)

    local bestTarget = nil
    local bestMargin = -math.huge

    for _, target in targets do
        if target.Ready then
            local margin = targetMargin(target)
            if margin > bestMargin then
                bestMargin = margin
                bestTarget = target
            end
        end
    end

    if bestTarget then
        self:_applyEvolution(player, petState, bestTarget.Id)
        return true
    end

    return false
end

function PetService.Init()
    Players.PlayerRemoving:Connect(function(player)
        PetService._pets[player.UserId] = nil
    end)
end

function PetService:GetPetState(player: Player): PetState?
    return self._pets[player.UserId]
end

function PetService:GiveStarterEgg(player: Player, eggData)
    if not eggData then
        warn("[PetService] Starter egg data missing")
        return
    end

    local delaySeconds = eggData.HatchDelaySeconds or 0
    task.delay(delaySeconds, function()
        self:_hatchEgg(player, eggData.HatchPetId)
    end)
end

function PetService:_hatchEgg(player: Player, petId: string)
    local monster = getMonster(petId)
    local petState: PetState = {
        Owner = player,
        MonsterId = petId,
        Stats = cloneStats(monster.BaseStats),
        Experience = 0,
    }

    self._pets[player.UserId] = petState

    self:_publishPetState(player, petState)
end

function PetService:AddExperience(player: Player, amount: number)
    local petState = self:GetPetState(player)
    if not petState then
        return
    end

    petState.Experience += amount
end

function PetService:AddStat(player: Player, statName: string, delta: number)
    local petState = self:GetPetState(player)
    if not petState then
        return
    end

    if petState.Stats[statName] == nil then
        warn(string.format("[PetService] Stat %s does not exist", tostring(statName)))
        return
    end

    petState.Stats[statName] += delta

    local targets = self:_buildEvolutionTargets(petState)
    if not self:_tryEvolve(player, petState, targets) then
        self:_publishPetState(player, petState, targets)
    end
end

function PetService:_applyEvolution(player: Player, petState: PetState, nextId: string)
    if petState.MonsterId == nextId then
        return
    end

    local evolvedMonster = getMonster(nextId)
    petState.MonsterId = evolvedMonster.Id
    local newStats = cloneStats(petState.Stats)
    for statName, baseValue in pairs(evolvedMonster.BaseStats) do
        local current = newStats[statName]
        if current == nil or current < baseValue then
            newStats[statName] = baseValue
        end
    end
    petState.Stats = newStats
    petState.Experience = 0

    Remotes.PetEvolution:FireClient(player, {
        MonsterId = petState.MonsterId,
        DisplayName = evolvedMonster.DisplayName,
    })

    self:_publishPetState(player, petState)
end

return PetService
