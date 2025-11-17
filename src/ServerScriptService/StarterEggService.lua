--!strict
-- StarterEggService coordinates the NPC dialogue flow that awards each player
-- their very first egg.  The service keeps track of who has already been given
-- the reward through DataStoreService to ensure the giveaway only occurs once.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StarterEgg = require(ReplicatedStorage.Items.Eggs.StarterEgg)

local StarterEggService = {}
StarterEggService.__index = StarterEggService

StarterEggService._store = DataStoreService:GetDataStore("StarterEggReward")
StarterEggService._sessionAwards = {}
StarterEggService._historicAwards = {}
StarterEggService._petService = nil
StarterEggService._initialized = false

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

local function resolvePetService()
    if StarterEggService._petService then
        return StarterEggService._petService
    end

    local ok, moduleOrErr = pcall(function()
        return require(ServerScriptService:WaitForChild("PetService"))
    end)

    if ok then
        StarterEggService._petService = moduleOrErr
        return StarterEggService._petService
    end

    warn(string.format("[StarterEggService] Unable to load PetService: %s", tostring(moduleOrErr)))
    return nil
end

function StarterEggService.Init(petService)
    if petService then
        StarterEggService._petService = petService
    end

    if StarterEggService._initialized then
        return
    end

    StarterEggService._initialized = true
    resolvePetService()

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

    if self._historicAwards[userId] == nil then
        self:_preloadAwardFlag(player)
    end

    return self._historicAwards[userId] == true
end

function StarterEggService:GetAwardDialogue()
    return StarterEgg.DialogueOnAward
end

function StarterEggService:TryAwardStarterEgg(player: Player)
    local userId = player.UserId
    local petService = resolvePetService()
    local existingPet = petService and petService.GetPetState and petService:GetPetState(player)
    local alreadyAwarded = self:HasReceivedStarterEgg(player)

    if alreadyAwarded and existingPet then
        return false, "You already received your starter egg."
    end

    if not alreadyAwarded then
        self._sessionAwards[userId] = true
        self._historicAwards[userId] = true

        task.spawn(function()
            safeSetAsync(self._store, datastoreKey(userId), true)
        end)
    end

    if petService and petService.GiveStarterEgg then
        petService:GiveStarterEgg(player, StarterEgg)
    else
        warn("[StarterEggService] PetService missing, cannot award starter egg")
        return false, "Hmm, something went wrong. Please try again in a moment."
    end

    if alreadyAwarded then
        return true, "Your companion rushes back to your side."
    end

    return true, StarterEgg.DialogueOnAward[2]
end

StarterEggService.Init()

return StarterEggService
