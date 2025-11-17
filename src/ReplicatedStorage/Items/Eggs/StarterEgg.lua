--!strict
-- Lightweight data container representing the first egg each player receives.

local StarterEgg = {
    Id = "StarterEgg",
    DisplayName = "Companion Egg",
    Description = "A warm egg gifted by the village PNG. It contains a loyal sprout.",
    HatchPetId = "Sproutling",
    HatchDelaySeconds = 2,
    DialogueOnAward = {
        "Welcome to the meadow!",
        "Take this egg—care for it and it will hatch into your first partner.",
    },
}

return StarterEgg
