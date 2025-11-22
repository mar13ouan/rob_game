local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local SpellCastEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpellCast")
local SpellDefinitions = require(ReplicatedStorage:WaitForChild("SpellDefinitions"))

local function createTrail(parent, colorSequence)
    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "TrailAttachment0"
    attachment0.Position = Vector3.new(0, 0.75, 0)
    attachment0.Parent = parent

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "TrailAttachment1"
    attachment1.Position = Vector3.new(0, -0.75, 0)
    attachment1.Parent = parent

    local trail = Instance.new("Trail")
    trail.Lifetime = 0.35
    trail.Color = colorSequence
    trail.LightEmission = 1
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Parent = parent
end

local function applyParticleEffect(parent, particleConfig)
    local particle = Instance.new("ParticleEmitter")
    particle.Color = particleConfig.Color
    particle.LightEmission = particleConfig.LightEmission
    particle.Texture = particleConfig.Texture
    particle.Size = particleConfig.Size
    particle.Rate = 12
    particle.Speed = NumberRange.new(3, 5)
    particle.Lifetime = NumberRange.new(0.35, 0.75)
    particle.Parent = parent
end

local function launchSpell(player, spellName)
    local spell = SpellDefinitions[spellName]
    if not spell then
        return
    end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local projectile = Instance.new("Part")
    projectile.Name = spellName .. "Projectile"
    projectile.Shape = Enum.PartType.Ball
    projectile.Color = spell.Color
    projectile.Material = Enum.Material.Neon
    projectile.Size = Vector3.new(2, 2, 2)
    projectile.CFrame = rootPart.CFrame * CFrame.new(0, 2, -4)
    projectile.CanCollide = false
    projectile.Parent = workspace

    createTrail(projectile, spell.TrailColor)
    applyParticleEffect(projectile, spell.Particle)

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = rootPart.CFrame.LookVector * spell.Speed
    bodyVelocity.Parent = projectile

    projectile.Touched:Connect(function()
        if not projectile or not projectile.Parent then
            return
        end

        local flash = Instance.new("PointLight")
        flash.Color = spell.Color
        flash.Brightness = 4
        flash.Range = 12
        flash.Parent = projectile

        projectile.Size = projectile.Size + Vector3.new(0.5, 0.5, 0.5)
        task.delay(0.15, function()
            if flash.Parent then
                flash:Destroy()
            end
        end)
    end)

    Debris:AddItem(projectile, spell.Lifetime)
end

SpellCastEvent.OnServerEvent:Connect(launchSpell)
