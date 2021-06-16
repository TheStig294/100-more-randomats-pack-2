local EVENT = {}
EVENT.Title = "I'll be back..."
EVENT.Description = "Turns everyone but traitors into phantoms"
EVENT.id = "beback"

function EVENT:Begin()
    -- For all alive players,
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        -- That aren't traitors
        if not Randomat:IsTraitorTeam(ply) then
            -- Turn them into phantoms
            Randomat:SetRole(ply, ROLE_PHANTOM)
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    -- Check if the phantom exists and is enabled
    return ConVarExists("ttt_phantom_enabled") and GetConVar("ttt_phantom_enabled"):GetBool()
end

Randomat:register(EVENT)