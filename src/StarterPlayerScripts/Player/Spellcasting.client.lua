--!strict
-- Allows the player to swap between three spells (fireball, lightning, and water jet)
-- and cast the equipped spell with a left mouse click.

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

export type SpellDefinition = {
    id: string,
    key: Enum.KeyCode,
    name: string,
    color: Color3,
    speed: number,
    size: number,
    lifetime: number,
    setup: (Part) -> (),
}

local function addTrail(part: Part, color: Color3)
    local attachment0 = Instance.new("Attachment")
    attachment0.Position = Vector3.new(0, 0, -part.Size.Z / 2)
    attachment0.Parent = part

    local attachment1 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(0, 0, part.Size.Z / 2)
    attachment1.Parent = part

    local trail = Instance.new("Trail")
    trail.Color = ColorSequence.new(color)
    trail.Lifetime = 0.35
    trail.LightEmission = 1
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Parent = part
end

local spells: { SpellDefinition } = {
    {
        id = "fireball",
        key = Enum.KeyCode.One,
        name = "Boule de feu",
        color = Color3.fromRGB(255, 140, 0),
        speed = 120,
        size = 1.8,
        lifetime = 4,
        setup = function(part: Part)
            part.Material = Enum.Material.Neon
            part.Shape = Enum.PartType.Ball

            local fire = Instance.new("Fire")
            fire.Heat = 6
            fire.Size = 12
            fire.Color = Color3.fromRGB(255, 200, 80)
            fire.SecondaryColor = Color3.fromRGB(255, 120, 40)
            fire.Parent = part

            addTrail(part, part.Color)
        end,
    },
    {
        id = "lightning",
        key = Enum.KeyCode.Two,
        name = "Éclair",
        color = Color3.fromRGB(255, 255, 120),
        speed = 150,
        size = 1.2,
        lifetime = 2.5,
        setup = function(part: Part)
            part.Material = Enum.Material.ForceField
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(part.Size.X * 0.4, part.Size.Y, part.Size.Z * 2)

            local light = Instance.new("PointLight")
            light.Brightness = 4
            light.Range = 18
            light.Color = part.Color
            light.Parent = part

            addTrail(part, Color3.fromRGB(255, 255, 220))
        end,
    },
    {
        id = "water_jet",
        key = Enum.KeyCode.Three,
        name = "Pistolet à eau",
        color = Color3.fromRGB(80, 180, 255),
        speed = 100,
        size = 1,
        lifetime = 3,
        setup = function(part: Part)
            part.Material = Enum.Material.Glass
            part.Shape = Enum.PartType.Ball

            local particles = Instance.new("ParticleEmitter")
            particles.Rate = 60
            particles.Speed = NumberRange.new(10, 16)
            particles.Lifetime = NumberRange.new(0.4, 0.7)
            particles.Texture = "rbxassetid://4835879088" -- water droplet
            particles.Color = ColorSequence.new(part.Color)
            particles.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.45),
                NumberSequenceKeypoint.new(0.6, 0.35),
                NumberSequenceKeypoint.new(1, 0),
            })
            particles.Parent = part

            addTrail(part, part.Color)
        end,
    },
}

local equippedSpell: SpellDefinition = spells[1]

local function ensureCharacter()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
    return character, humanoidRootPart
end

local function notifySpellChange(spell: SpellDefinition)
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Sort équipé",
            Text = string.format("%s (%s)", spell.name, tostring(spell.key.Name)),
            Duration = 2,
        })
    end)
end

local function equipSpellByKey(keyCode: Enum.KeyCode)
    for _, spell in ipairs(spells) do
        if spell.key == keyCode then
            equippedSpell = spell
            notifySpellChange(spell)
            break
        end
    end
end

local function spawnProjectile(spell: SpellDefinition)
    local character, root = ensureCharacter()
    local targetPosition = mouse.Hit and mouse.Hit.Position or (root.Position + root.CFrame.LookVector * 60)
    local direction = (targetPosition - root.Position)
    if direction.Magnitude < 1 then
        direction = root.CFrame.LookVector
    else
        direction = direction.Unit
    end

    local spawnPosition = root.Position + Vector3.new(0, 1.5, 0) + (direction * 4)

    local projectile = Instance.new("Part")
    projectile.Name = spell.name
    projectile.Color = spell.color
    projectile.Size = Vector3.new(spell.size, spell.size, spell.size)
    projectile.CFrame = CFrame.new(spawnPosition, spawnPosition + direction)
    projectile.CanCollide = false
    projectile.Anchored = false
    projectile.Massless = true
    projectile.Parent = workspace

    spell.setup(projectile)

    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    velocity.Velocity = direction * spell.speed
    velocity.Parent = projectile

    projectile.Touched:Connect(function(hit: BasePart)
        if not projectile or not projectile.Parent then
            return
        end

        if hit:IsDescendantOf(character) then
            return
        end

        local flash = Instance.new("Explosion")
        flash.Position = projectile.Position
        flash.BlastRadius = 4
        flash.BlastPressure = 0
        flash.DestroyJointRadiusPercent = 0
        flash.Parent = workspace

        projectile:Destroy()
    end)

    Debris:AddItem(projectile, spell.lifetime)
end

local function onInputBegan(input: InputObject, processed: boolean)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Dollar or input.KeyCode == Enum.KeyCode.Four then
            spawnProjectile(equippedSpell)
        else
            equipSpellByKey(input.KeyCode)
        end
    end
end

mouse.Button1Down:Connect(function()
    spawnProjectile(equippedSpell)
end)

UserInputService.InputBegan:Connect(onInputBegan)

-- Equip the default spell at startup so the player knows what is active
notifySpellChange(equippedSpell)
