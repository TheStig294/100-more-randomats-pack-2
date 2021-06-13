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
        for k, ply in pairs(self:GetAlivePlayers(true)) do
            if (ply:GetRole() == ROLE_INNOCENT) or (ply:GetRole() == ROLE_DETECTIVE) or (ply:GetRole() == ROLE_MERCENARY) or (ply:GetRole() == ROLE_GLITCH) or (ply:GetRole() == ROLE_KILLER) or (ply:GetRole() == ROLE_JESTER) or (ply:GetRole() == ROLE_SWAPPER) or (ply:GetRole() == ROLE_ZOMBIE) then
                Randomat:SetRole(ply, ROLE_PHANTOM)
            end
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    local isPhantom = false

    if isnumber(ROLE_PHANTOM) and ROLE_PHANTOM ~= -1 then
        isPhantom = true
    end

    return isPhantom
end

Randomat:register(EVENT)