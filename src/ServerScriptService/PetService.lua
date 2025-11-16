--!strict
-- PetService manages the lifecycle of each player's companion: hatching,
-- stat tracking, and evolution checks.  It exposes remote updates so the
-- client HUD can reflect stat changes in real time.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Remotes)
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

function PetService:_getNextEvolution(petState: PetState)
    local monster = getMonster(petState.MonsterId)
    for _, evolution in monster.Evolutions do
        local requirementsMet = true
        for stat, requirement in evolution.Requirements do
            if requirement and petState.Stats[stat] < requirement then
                requirementsMet = false
                break
            end
        end

        if not requirementsMet then
            return evolution
        end
    end

    return monster.Evolutions[1]
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

    Remotes.PetStatUpdated:FireClient(player, {
        MonsterId = petState.MonsterId,
        Stats = petState.Stats,
        Attacks = monster.Attacks,
        NextEvolution = self:_getNextEvolution(petState),
    })
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

    local monster = getMonster(petState.MonsterId)
    Remotes.PetStatUpdated:FireClient(player, {
        MonsterId = petState.MonsterId,
        Stats = petState.Stats,
        Attacks = monster.Attacks,
        NextEvolution = self:_getNextEvolution(petState),
    })

    self:_tryEvolve(player, petState)
end

function PetService:_tryEvolve(player: Player, petState: PetState)
    local monster = getMonster(petState.MonsterId)
    if #monster.Evolutions == 0 then
        return
    end

    for _, evolution in monster.Evolutions do
        local requirementsMet = true
        for stat, requirement in evolution.Requirements do
            if requirement and petState.Stats[stat] < requirement then
                requirementsMet = false
                break
            end
        end

        if requirementsMet then
            self:_applyEvolution(player, petState, evolution.Id)
            break
        end
    end
end

function PetService:_applyEvolution(player: Player, petState: PetState, nextId: string)
    if petState.MonsterId == nextId then
        return
    end

    local evolvedMonster = getMonster(nextId)
    petState.MonsterId = evolvedMonster.Id
    petState.Stats = cloneStats(evolvedMonster.BaseStats)
    petState.Experience = 0

    Remotes.PetEvolution:FireClient(player, {
        MonsterId = petState.MonsterId,
        DisplayName = evolvedMonster.DisplayName,
    })

    Remotes.PetStatUpdated:FireClient(player, {
        MonsterId = petState.MonsterId,
        Stats = petState.Stats,
        Attacks = evolvedMonster.Attacks,
    })
end

return PetService
