local EVENT = {}
EVENT.Title = "I'll be back..."
EVENT.Description = "Turns everyone but traitors into phantoms"
EVENT.id = "beback"

function EVENT:Begin()
    if TTT2 then
        for k, ply in pairs(self:GetAlivePlayers(true)) do
            if (ply:GetTeam() ~= TEAM_TRAITOR) then
                ply:SetRole(ROLE_SPECTRE)
            end
        end
    else
        -- If not TTT2, for all alive players,
        for k, ply in pairs(self:GetAlivePlayers(true)) do
            -- That aren't traitors
            if not Randomat:IsTraitorTeam() then
                -- Turn them into phantoms
                Randomat:SetRole(ply, ROLE_PHANTOM)
            end
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local isPhantom = false

    -- If the phantom role's enumerator exists and isn't -1, the role exists and this randomat can trigger
    if isnumber(ROLE_PHANTOM) and ROLE_PHANTOM ~= -1 then
        isPhantom = true
    end

    return isPhantom
end

Randomat:register(EVENT)