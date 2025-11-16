--!strict
-- StarterEggService coordinates the NPC dialogue flow that awards each player
-- their very first egg.  The service keeps track of who has already been given
-- the reward through DataStoreService to ensure the giveaway only occurs once.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterEgg = require(ReplicatedStorage.Items.Eggs.StarterEgg)

local StarterEggService = {}
StarterEggService.__index = StarterEggService

StarterEggService._store = DataStoreService:GetDataStore("StarterEggReward")
StarterEggService._sessionAwards = {}
StarterEggService._historicAwards = {}
StarterEggService._petService = nil

local function datastoreKey(userId: number): string
    return string.format("starterEgg_%d", userId)
end

local function safeGetAsync(store, key)
    local success, value = pcall(function()
        return store:GetAsync(key)
    end)

    if not success then
        warn(string.format("[StarterEggService] Failed to read store for key %s: %s", key, tostring(value)))
        return nil
    end

    return value
end

local function safeSetAsync(store, key, value)
    local success, err = pcall(function()
        store:SetAsync(key, value)
    end)

    if not success then
        warn(string.format("[StarterEggService] Failed to write store for key %s: %s", key, tostring(err)))
    end
end

function StarterEggService.Init(petService)
    StarterEggService._petService = petService

    Players.PlayerAdded:Connect(function(player)
        StarterEggService:_preloadAwardFlag(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        StarterEggService._sessionAwards[player.UserId] = nil
        StarterEggService._historicAwards[player.UserId] = nil
    end)
end

function StarterEggService:_preloadAwardFlag(player: Player)
    local key = datastoreKey(player.UserId)
    local value = safeGetAsync(self._store, key)
    self._historicAwards[player.UserId] = value == true
end

function StarterEggService:HasReceivedStarterEgg(player: Player): boolean
    local userId = player.UserId
    if self._sessionAwards[userId] ~= nil then
        return self._sessionAwards[userId]
    end

    return self._historicAwards[userId] == true
end

function StarterEggService:GetAwardDialogue()
    return StarterEgg.DialogueOnAward
end

function StarterEggService:TryAwardStarterEgg(player: Player)
    local userId = player.UserId

    if self:HasReceivedStarterEgg(player) then
        return false, "You already received your starter egg."
    end

    self._sessionAwards[userId] = true
    self._historicAwards[userId] = true

    task.spawn(function()
        safeSetAsync(self._store, datastoreKey(userId), true)
    end)

    if self._petService and self._petService.GiveStarterEgg then
        self._petService:GiveStarterEgg(player, StarterEgg)
    end

    return true, StarterEgg.DialogueOnAward[2]
end

return StarterEggService
