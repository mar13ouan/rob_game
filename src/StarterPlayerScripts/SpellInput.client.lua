local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SpellCastEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpellCast")
local SpellDefinitions = require(ReplicatedStorage:WaitForChild("SpellDefinitions"))

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

local activeCooldowns = {}

local function setCooldown(spellName, cooldown)
    activeCooldowns[spellName] = true
    task.delay(cooldown, function()
        activeCooldowns[spellName] = nil
    end)
end

local function playCastAnimation()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://507771019" -- simple arm swing

    local track = humanoid:LoadAnimation(animation)
    track:Play(0.1, 1, 1.25)
    track.Stopped:Connect(function()
        animation:Destroy()
    end)
end

local function bindSpellAction(spellName)
    return function(_, inputState)
        if inputState ~= Enum.UserInputState.Begin then
            return Enum.ContextActionResult.Pass
        end

        if activeCooldowns[spellName] then
            return Enum.ContextActionResult.Sink
        end

        if not character or not character.Parent then
            return Enum.ContextActionResult.Pass
        end

        SpellCastEvent:FireServer(spellName)
        playCastAnimation()

        local spell = SpellDefinitions[spellName]
        if spell then
            setCooldown(spellName, spell.Cooldown)
        end

        return Enum.ContextActionResult.Sink
    end
end

for spellName, config in pairs(SpellDefinitions) do
    for _, keyCode in ipairs(config.KeyCodes) do
        ContextActionService:BindAction(spellName .. "_cast", bindSpellAction(spellName), false, keyCode)
    end
end

game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "Press 1/2/3 (AZERTY: &/Ã©/\") or numpad 1/2/3 to cast Fireball, Thunderbolt, and Water Ball!",
    Color = Color3.fromRGB(255, 255, 255),
})
