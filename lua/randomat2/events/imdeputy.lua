local EVENT = {}
EVENT.Title = "No, I'm a deputy!"
EVENT.Description = "Pure innocents are now deputies, traitors are now impersonators"
EVENT.id = "imdeputy"

function EVENT:Begin()
    local isDetective = false

    for i, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(ply) then
            isDetective = true
        end
    end

    local promoteDeputies = false
    local promoteImpersonators = false

    if not isDetective and ConVarExists("ttt_deputy_without_detective") and GetConVar("ttt_deputy_without_detective"):GetBool() then
        promoteDeputies = true
    end

    if not isDetective and ConVarExists("ttt_impersonator_without_detective") and GetConVar("ttt_impersonator_without_detective"):GetBool() then
        promoteImpersonators = true
    end

    -- If there is a clown or jester already then there is no need to turn someone into one
    for k, ply in pairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_INNOCENT then
            Randomat:SetRole(ply, ROLE_DEPUTY)

            if promoteDeputies then
                ply:SetNWBool("HasPromotion", true)
                ply:AddCredits(GetConVar("ttt_deputy_activation_credits"):GetInt())
            end
        elseif Randomat:IsTraitorTeam(ply) then
            Randomat:SetRole(ply, ROLE_IMPERSONATOR)

            if promoteImpersonators then
                ply:SetNWBool("HasPromotion", true)
                ply:AddCredits(GetConVar("ttt_impersonator_activation_credits"):GetInt())
            end
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local innocentCount = 0

    for i, ply in ipairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_INNOCENT then
            innocentCount = innocentCount + 1
        end
    end

    return ConVarExists("ttt_deputy_enabled") and GetConVar("ttt_deputy_enabled"):GetBool() and ConVarExists("ttt_impersonator_enabled") and GetConVar("ttt_impersonator_enabled"):GetBool() and innocentCount > 1
end

Randomat:register(EVENT)