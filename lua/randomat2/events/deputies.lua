local EVENT = {}
EVENT.Title = "Oops! All deputies!"
EVENT.Description = "All innocents are deputies, all traitors are impersonators!"
EVENT.id = "deputies"

EVENT.Categories = {"biased_innocent", "biased", "rolechange", "largeimpact"}

function EVENT:Begin()
    for k, ply in pairs(self:GetAlivePlayers()) do
        -- True argument is to skip the detective
        if Randomat:IsInnocentTeam(ply, true) then
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_DEPUTY)
            ply:SetDefaultCredits()
        elseif Randomat:IsTraitorTeam(ply) then
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_IMPERSONATOR)
            ply:SetDefaultCredits()
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local innocentCount = 0
    local traitorCount = 0

    for i, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsInnocentTeam(ply, true) then
            innocentCount = innocentCount + 1
        end

        if Randomat:IsTraitorTeam(ply) then
            traitorCount = traitorCount + 1
        end
    end

    return ConVarExists("ttt_deputy_enabled") and GetConVar("ttt_deputy_enabled"):GetBool() and ConVarExists("ttt_impersonator_enabled") and GetConVar("ttt_impersonator_enabled"):GetBool() and innocentCount > 1 and traitorCount > 1
end

Randomat:register(EVENT)