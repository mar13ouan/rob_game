--!strict
-- StateMachine formalizes the high-level phases of the game. Server scripts can
-- use it to transition between phases while client scripts can observe the
-- current state to adjust their UI or gameplay accordingly.

local StateMachine = {}

StateMachine.States = {
    Lobby = "Lobby",
    InProgress = "InProgress",
    Ended = "Ended",
}

-- Tracks the current state. Server code can replicate this value through
-- RemoteEvents/Attributes as needed so that clients stay in sync.
StateMachine.CurrentState = StateMachine.States.Lobby

-- Called when the experience is ready for players to gather, configure their
-- loadouts, or wait for additional participants. Use this to reset scores,
-- spawn players in the lobby area, and start a countdown timer.
function StateMachine.StartLobby()
    StateMachine.CurrentState = StateMachine.States.Lobby
    -- TODO: Add logic to reset match data, teleport players, and schedule match start.
end

-- Transitions the game into the active match state. Invoke this once the lobby
-- timer finishes or enough players have joined. Responsible for spawning
-- objectives, enabling combat, and initializing round-specific systems.
function StateMachine.StartMatch()
    StateMachine.CurrentState = StateMachine.States.InProgress
    -- TODO: Add logic to spawn collectibles, enable damage, and track round stats.
end

-- Called whenever the match concludes either from victory conditions, time
-- expiry, or lack of players. Use this to show results, award currency, and
-- return players to the lobby after a delay.
function StateMachine.EndMatch()
    StateMachine.CurrentState = StateMachine.States.Ended
    -- TODO: Add logic to compute placement, grant rewards, and schedule lobby restart.
end

return StateMachine
