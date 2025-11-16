--!strict
-- Utility functions for spawning simple placeholder pet models on the client.

local PetLibrary = {}

local function createPetModel(name: string, color: Color3, size: Vector3)
    local model = Instance.new("Model")
    model.Name = name

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = size
    body.Color = color
    body.Material = Enum.Material.SmoothPlastic
    body.CanCollide = false
    body.Anchored = true
    body.Parent = model

    model.PrimaryPart = body
    return model
end

local builders: {[string]: () -> Model} = {
    Sproutling = function()
        local model = createPetModel("Sproutling", Color3.fromRGB(121, 201, 97), Vector3.new(1.5, 1.5, 1.5))
        local leaf = Instance.new("Part")
        leaf.Name = "Leaf"
        leaf.Size = Vector3.new(0.2, 0.8, 1.2)
        leaf.Color = Color3.fromRGB(56, 142, 60)
        leaf.Material = Enum.Material.Grass
        leaf.CanCollide = false
        leaf.Anchored = true
        leaf.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 1, 0)
        leaf.Parent = model
        return model
    end,
    Bloomtail = function()
        return createPetModel("Bloomtail", Color3.fromRGB(255, 176, 189), Vector3.new(1.2, 1.2, 2))
    end,
    Thornback = function()
        return createPetModel("Thornback", Color3.fromRGB(108, 74, 47), Vector3.new(2, 1.2, 1.6))
    end,
    Aurorashade = function()
        return createPetModel("Aurorashade", Color3.fromRGB(123, 190, 255), Vector3.new(1.2, 1.2, 1.2))
    end,
}

function PetLibrary.CreatePetModel(monsterId: string): Model
    local builder = builders[monsterId] or builders.Sproutling
    local model = builder():Clone()
    return model
end

return PetLibrary
