--!strict
-- Static data describing each monster species, including their base stats,
-- available attacks, and potential evolution paths.

export type Attack = {
    Name: string,
    Description: string,
    Power: number,
    Cost: number,
}

export type Evolution = {
    Id: string,
    DisplayName: string,
    Requirements: {
        Power: number?,
        Vitality: number?,
        Focus: number?,
        Agility: number?,
    },
}

export type Monster = {
    Id: string,
    DisplayName: string,
    BaseStats: {
        Power: number,
        Vitality: number,
        Focus: number,
        Agility: number,
    },
    Attacks: {Attack},
    Evolutions: {Evolution},
    ModelName: string,
}

local Monsters: {[string]: Monster} = {
    Sproutling = {
        Id = "Sproutling",
        DisplayName = "Sproutling",
        ModelName = "Sproutling",
        BaseStats = {
            Power = 5,
            Vitality = 7,
            Focus = 4,
            Agility = 6,
        },
        Attacks = {
            {
                Name = "Leaf Flick",
                Description = "A quick flurry of leaves that chips away at foes.",
                Power = 8,
                Cost = 0,
            },
            {
                Name = "Sap Guard",
                Description = "Covers the pet in sap, raising vitality for a moment.",
                Power = 0,
                Cost = 5,
            },
        },
        Evolutions = {
            {
                Id = "Bloomtail",
                DisplayName = "Bloomtail",
                Requirements = {
                    Agility = 24,
                },
            },
            {
                Id = "Thornback",
                DisplayName = "Thornback",
                Requirements = {
                    Power = 25,
                },
            },
            {
                Id = "Aurorashade",
                DisplayName = "Aurorashade",
                Requirements = {
                    Focus = 20,
                },
            },
        },
    },
    Bloomtail = {
        Id = "Bloomtail",
        DisplayName = "Bloomtail",
        ModelName = "Bloomtail",
        BaseStats = {
            Power = 12,
            Vitality = 10,
            Focus = 9,
            Agility = 18,
        },
        Attacks = {
            {
                Name = "Petal Dash",
                Description = "Darts forward leaving a trail of petals.",
                Power = 16,
                Cost = 5,
            },
            {
                Name = "Gale Bloom",
                Description = "Creates a wind burst that boosts agility temporarily.",
                Power = 0,
                Cost = 8,
            },
        },
        Evolutions = {},
    },
    Thornback = {
        Id = "Thornback",
        DisplayName = "Thornback",
        ModelName = "Thornback",
        BaseStats = {
            Power = 20,
            Vitality = 14,
            Focus = 8,
            Agility = 10,
        },
        Attacks = {
            {
                Name = "Bramble Slam",
                Description = "A heavy slam that deals bonus damage to slowed enemies.",
                Power = 22,
                Cost = 10,
            },
            {
                Name = "Thorn Shield",
                Description = "Reflects a portion of melee damage for a short period.",
                Power = 0,
                Cost = 12,
            },
        },
        Evolutions = {},
    },
    Aurorashade = {
        Id = "Aurorashade",
        DisplayName = "Aurorashade",
        ModelName = "Aurorashade",
        BaseStats = {
            Power = 11,
            Vitality = 9,
            Focus = 20,
            Agility = 12,
        },
        Attacks = {
            {
                Name = "Lumen Pulse",
                Description = "A beam of prismatic light that scales with focus.",
                Power = 18,
                Cost = 12,
            },
            {
                Name = "Veil Bloom",
                Description = "Cloaks the pet, allowing it to dodge the next attack.",
                Power = 0,
                Cost = 15,
            },
        },
        Evolutions = {},
    },
}

return Monsters
