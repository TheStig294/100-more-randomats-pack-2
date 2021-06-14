local EVENT = {}
EVENT.Title = "I'll be back..."
EVENT.Description = "Turns everyone but traitors into phantoms"
EVENT.id = "beback"

function EVENT:Begin()
    -- For all alive players,
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        -- That aren't traitors
        if not Randomat:IsTraitorTeam() then
            -- Turn them into phantoms
            Randomat:SetRole(ply, ROLE_PHANTOM)
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    -- If the phantom role's enumerator exists and isn't -1, the role exists and this randomat can trigger
    return isnumber(ROLE_PHANTOM) and ROLE_PHANTOM ~= -1
end

Randomat:register(EVENT)