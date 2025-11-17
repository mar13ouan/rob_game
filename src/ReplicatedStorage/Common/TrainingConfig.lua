--!strict
-- Shared numbers for training stations so server scripts, UI, and signage stay
-- consistent when we communicate how many sessions a player needs.

local TrainingConfig = {}

TrainingConfig.DEFAULT_SESSION_LENGTH = 1.5
TrainingConfig.DEFAULT_COOLDOWN = 4

local DEFAULT_STAT_GAIN = 2

TrainingConfig.StatGainPerSession = {
    Power = DEFAULT_STAT_GAIN,
    Vitality = DEFAULT_STAT_GAIN,
    Focus = DEFAULT_STAT_GAIN,
    Agility = DEFAULT_STAT_GAIN,
}

function TrainingConfig.GetStatGain(statName: string): number
    return TrainingConfig.StatGainPerSession[statName] or DEFAULT_STAT_GAIN
end

return TrainingConfig
