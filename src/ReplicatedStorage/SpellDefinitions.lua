local SpellDefinitions = {
    Fireball = {
        KeyCodes = {
            Enum.KeyCode.One,
            Enum.KeyCode.KeypadOne,
        },
        Name = "Fireball",
        Color = Color3.fromRGB(255, 128, 64),
        TrailColor = ColorSequence.new(Color3.fromRGB(255, 170, 85), Color3.fromRGB(255, 64, 32)),
        Speed = 130,
        Lifetime = 6,
        Cooldown = 1.25,
        Particle = {
            Color = ColorSequence.new(Color3.new(1, 0.75, 0.4)),
            LightEmission = 0.7,
            Texture = "rbxassetid://243660364",
            Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0.4) }),
        },
    },
    Thunderbolt = {
        KeyCodes = {
            Enum.KeyCode.Two,
            Enum.KeyCode.KeypadTwo,
        },
        Name = "Thunderbolt",
        Color = Color3.fromRGB(170, 213, 255),
        TrailColor = ColorSequence.new(Color3.fromRGB(200, 225, 255), Color3.fromRGB(85, 170, 255)),
        Speed = 160,
        Lifetime = 5,
        Cooldown = 1.5,
        Particle = {
            Color = ColorSequence.new(Color3.fromRGB(170, 225, 255)),
            LightEmission = 1,
            Texture = "rbxassetid://1248816150",
            Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.1), NumberSequenceKeypoint.new(1, 0.2) }),
        },
    },
    WaterBall = {
        KeyCodes = {
            Enum.KeyCode.Three,
            Enum.KeyCode.KeypadThree,
        },
        Name = "Water Ball",
        Color = Color3.fromRGB(85, 170, 255),
        TrailColor = ColorSequence.new(Color3.fromRGB(32, 170, 255), Color3.fromRGB(16, 60, 255)),
        Speed = 110,
        Lifetime = 7,
        Cooldown = 1,
        Particle = {
            Color = ColorSequence.new(Color3.fromRGB(85, 170, 255)),
            LightEmission = 0.4,
            Texture = "rbxassetid://180690242",
            Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.6) }),
        },
    },
}

return SpellDefinitions
